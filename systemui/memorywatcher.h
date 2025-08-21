/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         memorywatcher.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-23
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef MEMORYWATCHER_H
#define MEMORYWATCHER_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <QtGlobal>

class MemoryWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int memoryUsedPercent READ memoryUsedPercent NOTIFY memoryUsedPercentChanged FINAL)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged FINAL)
    Q_PROPERTY(int cpuUsagePercent READ cpuUsagePercent NOTIFY cpuUsagePercentChanged FINAL)
    Q_PROPERTY(QString cpuFreqMHz READ cpuFreqMHz NOTIFY cpuFreqMHzChanged FINAL)
    Q_PROPERTY(QString governor READ governor NOTIFY governorChanged FINAL)
    Q_PROPERTY(QString temperatureC READ temperatureC NOTIFY temperatureCChanged FINAL)
    Q_PROPERTY(QString devfreqMHz READ devfreqMHz NOTIFY devfreqMHzChanged FINAL)
    Q_PROPERTY(QString overlayText READ overlayText NOTIFY overlayTextChanged FINAL)
    Q_PROPERTY(int fps READ fps WRITE setFps NOTIFY fpsChanged FINAL)
    Q_PROPERTY(QString gpuInfo READ gpuInfo NOTIFY gpuInfoChanged FINAL)
public:
    explicit MemoryWatcher(QObject *parent = nullptr);

    int memoryUsedPercent() const;
    void setMemoryUsedPercent(int newMemoryUsedPercent);

    bool running() const;
    void setRunning(bool newRunning);

    int cpuUsagePercent() const { return m_cpuUsagePercent; }
    QString cpuFreqMHz() const { return m_cpuFreqMHz; }
    QString governor() const { return m_governor; }
    QString temperatureC() const { return m_temperatureC; }
    QString devfreqMHz() const { return m_devfreqMHz; }
    QString overlayText() const { return m_overlayText; }
    int fps() const { return m_fps; }
    Q_INVOKABLE void setFps(int value) { if (m_fps == value) return; m_fps = value; emit fpsChanged(); }
    QString gpuInfo() const { return m_gpuInfo; }

signals:
    void memoryUsedPercentChanged();

    void runningChanged();

    void cpuUsagePercentChanged();
    void cpuFreqMHzChanged();
    void governorChanged();
    void temperatureCChanged();
    void devfreqMHzChanged();
    void overlayTextChanged();
    void fpsChanged();
    void gpuInfoChanged();

private:
    int m_memoryUsedPercent;
    QTimer *m_timer;
    bool m_running;
    // CPU usage calculation cache
    quint64 m_prevTotal = 0;
    quint64 m_prevIdle = 0;

    int m_cpuUsagePercent = 0;
    QString m_cpuFreqMHz;
    QString m_governor;
    QString m_temperatureC;
    QString m_devfreqMHz;
    QString m_overlayText;
    int m_fps = 0;
    QString m_gpuInfo;

private slots:
    void onTimerTimeOunt();
public slots:
    void clearCache();
};

#endif // MEMORYWATCHER_H
