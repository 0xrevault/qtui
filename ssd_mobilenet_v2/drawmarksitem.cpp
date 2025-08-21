/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         drawmarksitem.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "drawmarksitem.h"
#include <QPen>
#include <QPainter>
#include <QDebug>
DrawMarksItem::DrawMarksItem(QQuickItem *parent) : QQuickPaintedItem(parent), m_color(Qt::red)
{
    setFlag(ItemHasContents, true);
    this->setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

Marks DrawMarksItem::marks() const
{
    return m_marks;
}

void DrawMarksItem::setMarks(const Marks &newMarks)
{
    if (m_marks == newMarks)
        return;
    m_marks = newMarks;
    emit marksChanged();
    this->update();
}

void DrawMarksItem::paint(QPainter *painter)
{
    if (painter == nullptr) {
        return;
    }

    QPen pen;
    pen.setWidth(5);
    QFont font;
    font.setPixelSize(25);
    painter->setFont(font);
    pen.setColor(m_color);
    painter->setPen(pen);

    qreal xScale = this->width() / 640;
    qreal yScale = this->height() / 480;
    foreach (Mark mark, m_marks) {
        painter->drawRect(mark.x * xScale, mark.y * yScale, mark.width * xScale, mark.height * yScale);
        painter->drawText(mark.x * xScale + 25, mark.y * yScale + 25, mark.text);
    }
}

QColor DrawMarksItem::color() const
{
    return m_color;
}

void DrawMarksItem::setColor(const QColor &newColor)
{
    if (m_color == newColor)
        return;
    m_color = newColor;
    emit colorChanged();
    this->update();
}
