/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ispctrolthread.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-07
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "ispctrolthread.h"

ISPCtrolThread::ISPCtrolThread(QObject *parent)
    : QThread{parent}
{}

void ISPCtrolThread::run()
{
    system("/usr/local/demo/bin/dcmipp-isp-ctrl -i0");
    system("/usr/local/demo/bin/dcmipp-isp-ctrl -i0 -g  > /dev/null");
}
