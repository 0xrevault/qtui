/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         drawmarksitem.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "drawmarkitem.h"
#include <QPen>
#include <QPainter>
#include <QDebug>
#include <QPointF>
DrawMarkItem::DrawMarkItem(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    setFlag(ItemHasContents, true);
    this->setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

Mark DrawMarkItem::mark() const
{
    return m_mark;
}

void DrawMarkItem::setMark(const Mark &newMark)
{
    if (m_mark == newMark)
        return;
    m_mark = newMark;
    emit markChanged();
    this->update();
}

QColor DrawMarkItem::color() const
{
    return m_color;
}

void DrawMarkItem::setColor(const QColor &newColor)
{
    if (m_color == newColor)
        return;
    m_color = newColor;
    emit colorChanged();
}

void DrawMarkItem::paint(QPainter *painter)
{
    if (painter == nullptr) {
        return;
    }
    qreal xScale = this->width() / 640;
    qreal yScale = this->height() / 480;
    QPen pen;
    pen.setWidth(20);
    pen.setColor(m_color);
    painter->setPen(pen);
    for (const auto& point : m_mark.keypoints_xy) {
        painter->drawPoint(point.x * xScale, point.y * yScale);
    }
    pen.setWidth(10);
    for (size_t i = 0; i < m_mark.edges_xy.size(); ++i) {
        pen.setColor(QColor(m_mark.edge_colors[i][2], m_mark.edge_colors[i][1], m_mark.edge_colors[i][0]));
        painter->setPen(pen);
        if (!(m_mark.edges_xy[i][2] <= 0 &&  m_mark.edges_xy[i][3] <= 0)) // ?
            painter->drawLine(QPoint(m_mark.edges_xy[i][0] * xScale, m_mark.edges_xy[i][1] * yScale), QPoint(m_mark.edges_xy[i][2] * xScale, m_mark.edges_xy[i][3] * yScale));
    }
}
