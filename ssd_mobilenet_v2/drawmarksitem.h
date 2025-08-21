/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         drawmarksitem.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef DRAWMARKSITEM_H
#define DRAWMARKSITEM_H

#include <QObject>
#include <QQuickPaintedItem>
#include <QColor>
#include "mark.h"

class DrawMarksItem : public QQuickPaintedItem
{
    Q_OBJECT
public:
    DrawMarksItem(QQuickItem *parent = nullptr);
    Marks marks() const;
    void setMarks(const Marks &newMarks);
    void resetMarks();

    Q_PROPERTY(Marks marks READ marks WRITE setMarks NOTIFY marksChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

    QColor color() const;
    void setColor(const QColor &newColor);

signals:
    void marksChanged();

    void colorChanged();

private:
    Marks m_marks;
    void paint(QPainter *painter) override;
    QColor m_color;
};

#endif // DRAWMARKSITEM_H
