/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         drawmarksitem.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef DRAWMARKITEM_H
#define DRAWMARKITEM_H

#include <QObject>
#include <QQuickPaintedItem>
#include <QColor>
#include "mark.h"

class DrawMarkItem : public QQuickPaintedItem
{
    Q_OBJECT
public:
    DrawMarkItem(QQuickItem *parent = nullptr);
    Mark mark() const;
    void setMark(const Mark &newMark);

    Q_PROPERTY(Mark mark READ mark WRITE setMark NOTIFY markChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

    QColor color() const;
    void setColor(const QColor &newColor);

signals:
    void markChanged();

    void colorChanged();

private:
    Mark m_mark;
    QColor m_color;
    void paint(QPainter *painter) override;
};

#endif // DRAWMARKITEM_H
