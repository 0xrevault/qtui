/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ispctrolthread.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-07
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef ISPCTROLTHREAD_H
#define ISPCTROLTHREAD_H

#include <QObject>
#include <QThread>

class ISPCtrolThread : public QThread
{
    Q_OBJECT
public:
    explicit ISPCtrolThread(QObject *parent = nullptr);

private:
    void run() override;
signals:
};

#endif // ISPCTROLTHREAD_H
