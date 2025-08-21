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

class MemoryWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int memoryUsedPercent READ memoryUsedPercent NOTIFY memoryUsedPercentChanged FINAL)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged FINAL)
public:
    explicit MemoryWatcher(QObject *parent = nullptr);

    int memoryUsedPercent() const;
    void setMemoryUsedPercent(int newMemoryUsedPercent);

    bool running() const;
    void setRunning(bool newRunning);

signals:
    void memoryUsedPercentChanged();

    void runningChanged();

private:
    int m_memoryUsedPercent;
    QTimer *m_timer;
    bool m_running;

private slots:
    void onTimerTimeOunt();
public slots:
    void clearCache();
};

#endif // MEMORYWATCHER_H
