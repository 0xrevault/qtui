/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         videooutput.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-24
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "videooutput.h"
#include <QDebug>

VideoOutput::VideoOutput(QQuickPaintedItem *parent) : QQuickPaintedItem(parent), frameCount(0)
{
    setFlag(ItemHasContents, true);
    this->setRenderTarget(QQuickPaintedItem::FramebufferObject);
    timer = new QTimer(this);
    timer->start(1000);
    QObject::connect(timer, &QTimer::timeout, [this]() {
        setFrameRateInfo("显示帧率:" + QString::number(frameCount) + "fps");
        frameCount = 0;
    });
}

void VideoOutput::paint(QPainter *painter)
{
    if (painter == nullptr) {
        return;
    }
    QPixmap m_pixmapsrc = QPixmap::fromImage(m_source);
    painter->drawPixmap(0, 0, width(), height(), m_pixmapsrc);
    frameCount++;
}

QString VideoOutput::frameRateInfo() const
{
    return m_frameRateInfo;
}

void VideoOutput::setFrameRateInfo(const QString &newFrameRateInfo)
{
    if (m_frameRateInfo == newFrameRateInfo)
        return;
    m_frameRateInfo = newFrameRateInfo;
    emit frameRateInfoChanged();
}

QImage VideoOutput::source() const
{
    return m_source;
}

void VideoOutput::setSource(const QImage &newSource)
{
    if (m_source == newSource)
        return;
    m_source = newSource;
    emit sourceChanged();
    this->update();
}
