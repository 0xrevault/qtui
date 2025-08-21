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

MemoryWatcher::MemoryWatcher(QObject *parent)
    : QObject{parent}, m_running(false)
{
    m_timer = new QTimer(this);
    m_timer->setInterval(3000);
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
    QProcess pro;
    QString cmd = QCoreApplication::applicationDirPath() + "/src/apps/resource/shell/memory_usage_percent.sh";
    pro.start(cmd);
    pro.waitForFinished();
    QString str = pro.readAllStandardOutput();
    setMemoryUsedPercent(str.simplified().toInt());
}

void MemoryWatcher::clearCache()
{
    system("echo 3 > /proc/sys/vm/drop_caches");
}
