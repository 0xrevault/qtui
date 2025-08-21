/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mark.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef MARK_H
#define MARK_H
#include <QObject>
#include <QString>

class Mark
{
public:
    Mark();
    float x;
    float y;
    float width;
    float height;
    QString text;

    bool operator==(const Mark& other) const {
        return x == other.x && y == other.y
                   && width == other.width
                   && height == other.height
                   && text == other.text;
    }
};
typedef QVector<Mark> Marks;
#endif // MARK_H
