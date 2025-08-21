/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         memorywatcher.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-23
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "memorywatcher.h"
#include <QCoreApplication>
#include <QProcess>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QThread>

MemoryWatcher::MemoryWatcher(QObject *parent)
    : QObject{parent}, m_running(false)
{
    m_timer = new QTimer(this);
    m_timer->setInterval(1000);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(onTimerTimeOunt()));
}

int MemoryWatcher::memoryUsedPercent() const
{
    return m_memoryUsedPercent;
}

void MemoryWatcher::setMemoryUsedPercent(int newMemoryUsedPercent)
{
    if (m_memoryUsedPercent == newMemoryUsedPercent)
        return;
    m_memoryUsedPercent = newMemoryUsedPercent;
    emit memoryUsedPercentChanged();
}

bool MemoryWatcher::running() const
{
    return m_running;
}

void MemoryWatcher::setRunning(bool newRunning)
{
    if (m_running == newRunning)
        return;
    m_running = newRunning;
    emit runningChanged();
    if (m_running)
        m_timer->start();
    else
        m_timer->stop();
}

void MemoryWatcher::onTimerTimeOunt()
{
    // Memory percent (keep existing shell script, fallback to /proc/meminfo)
    int memPercent = 0;
    {
        QProcess pro;
        QString cmd = QCoreApplication::applicationDirPath() + "/src/apps/resource/shell/memory_usage_percent.sh";
        pro.start(cmd);
        pro.waitForFinished(500);
        QString str = pro.readAllStandardOutput().simplified();
        bool ok = false;
        int v = str.toInt(&ok);
        if (ok && v >= 0 && v <= 100) {
            memPercent = v;
        } else {
            QFile f("/proc/meminfo");
            if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                qint64 memTotal = 0, memAvailable = 0;
                while (!f.atEnd()) {
                    QByteArray line = f.readLine();
                    if (line.startsWith("MemTotal:")) {
                        memTotal = line.split(':').last().simplified().split(' ').first().toLongLong();
                    } else if (line.startsWith("MemAvailable:")) {
                        memAvailable = line.split(':').last().simplified().split(' ').first().toLongLong();
                    }
                }
                if (memTotal > 0) {
                    memPercent = int(((memTotal - memAvailable) * 100) / memTotal);
                }
            }
        }
    }
    setMemoryUsedPercent(memPercent);

    // CPU usage percent (overall): read /proc/stat once per tick, diff with previous
    auto readCpuTotals = []() -> QPair<quint64, quint64> {
        QFile f("/proc/stat");
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return {0,0};
        QByteArray line = f.readLine(); // first line: cpu ...
        QList<QByteArray> parts = line.split(' ');
        QList<quint64> vals; vals.reserve(10);
        for (auto &p : parts) {
            bool ok=false; quint64 v = p.toULongLong(&ok); if (ok) vals.append(v);
        }
        // user nice system idle iowait irq softirq steal guest guest_nice
        quint64 idle = 0, total = 0;
        for (int i=0;i<vals.size();++i) {
            total += vals[i];
            if (i==3 /*idle*/ || i==4 /*iowait*/ ) idle += vals[i];
        }
        return {total, idle};
    };
    QPair<quint64,quint64> cur = readCpuTotals();
    quint64 totald = (m_prevTotal==0 ? 0 : (cur.first - m_prevTotal));
    quint64 idled  = (m_prevIdle==0  ? 0 : (cur.second - m_prevIdle));
    int cpuPercent = 0;
    if (totald > 0 && totald >= idled) cpuPercent = int(((totald - idled) * 100) / totald);
    m_cpuUsagePercent = cpuPercent;
    emit cpuUsagePercentChanged();
    m_prevTotal = cur.first;
    m_prevIdle  = cur.second;

    // CPU freq MHz per core (current) + governor
    {
        QStringList freqs;
        QDir cpus("/sys/devices/system/cpu");
        QStringList entries = cpus.entryList(QStringList() << "cpu[0-9]*", QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
        for (const QString &cpuDir : entries) {
            QString path = cpus.absoluteFilePath(cpuDir + "/cpufreq/scaling_cur_freq");
            QFile f(path);
            if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                bool ok=false; qint64 khz = QString::fromLatin1(f.readAll()).simplified().toLongLong(&ok);
                if (ok && khz>0) freqs << QString::number(khz/1000);
            }
        }
        QString freqStr = freqs.join("/");
        if (m_cpuFreqMHz != freqStr) { m_cpuFreqMHz = freqStr; emit cpuFreqMHzChanged(); }

        QFile g("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor");
        if (g.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QString gov = QString::fromLatin1(g.readAll()).simplified();
            if (m_governor != gov) { m_governor = gov; emit governorChanged(); }
        }
    }

    // Temperatures (thermal zones)
    {
        QStringList temps;
        QDir tz("/sys/class/thermal");
        QStringList zones = tz.entryList(QStringList() << "thermal_zone*", QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
        for (const QString &z : zones) {
            QFile f(tz.absoluteFilePath(z + "/temp"));
            if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                bool ok=false; qint64 millic = QString::fromLatin1(f.readAll()).simplified().toLongLong(&ok);
                if (ok) temps << QString::number(millic/1000);
            }
        }
        QString tStr = temps.join("/");
        if (m_temperatureC != tStr) { m_temperatureC = tStr; emit temperatureCChanged(); }
    }

    // devfreq (GPU/DDR等，如存在)
    {
        QStringList freqs;
        QDir df("/sys/class/devfreq");
        if (df.exists()) {
            QStringList nodes = df.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
            for (const QString &n : nodes) {
                QFile f(df.absoluteFilePath(n + "/cur_freq"));
                if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                    bool ok=false; qint64 hz = QString::fromLatin1(f.readAll()).simplified().toLongLong(&ok);
                    if (ok && hz>0) freqs << (n + ":" + QString::number(hz/1000000) + "MHz");
                }
            }
        }
        QString dfStr = freqs.join(" ");
        if (m_devfreqMHz != dfStr) { m_devfreqMHz = dfStr; emit devfreqMHzChanged(); }
    }

    // Compose overlay text
    QString text = QString("CPU:%1%  Freq:%2MHz  Gov:%3\nMem:%4%  Temp:%5°C  Devfreq:%6")
            .arg(m_cpuUsagePercent)
            .arg(m_cpuFreqMHz)
            .arg(m_governor)
            .arg(m_memoryUsedPercent)
            .arg(m_temperatureC)
            .arg(m_devfreqMHz);
    if (m_overlayText != text) { m_overlayText = text; emit overlayTextChanged(); }
}

void MemoryWatcher::clearCache()
{
    system("echo 3 > /proc/sys/vm/drop_caches");
}
