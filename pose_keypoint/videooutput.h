/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         videooutput.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-24
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef VIDEOOUTPUT_H
#define VIDEOOUTPUT_H

#include <QObject>
#include <QQuickPaintedItem>
#include <QPainter>
#include <QImage>
#include <QPixmap>
#include <QTimer>

class VideoOutput : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QImage source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString frameRateInfo READ frameRateInfo NOTIFY frameRateInfoChanged)
public:
    VideoOutput(QQuickPaintedItem *parent = nullptr);
    QImage source() const;
    void setSource(const QImage &newSource);

    QString frameRateInfo() const;
    void setFrameRateInfo(const QString &newFrameRateInfo);

signals:
    void sourceChanged();
    void frameRateInfoChanged();

private:
    void paint(QPainter *painter) override;
    QImage m_source;
    QString m_frameRateInfo;
    int frameCount;
    QTimer *timer;

};

#endif // VIDEOOUTPUT_H
