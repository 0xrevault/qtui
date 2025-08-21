/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mediaplay.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-06
* @link          http://www.alientek.com
*******************************************************************/
#ifndef MEDIAPLAYER_H
#define MEDIAPLAYER_H

#include <QObject>
#include <QUrl>
#include <QTimer>
#include <QDebug>
#include <QtGlobal>
#include <gst/gst.h>
#include <gst/app/gstappsink.h>

class MediaPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(int position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(int state READ state NOTIFY stateChanged)
    Q_PROPERTY(float volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_ENUMS(State)

public:
    explicit MediaPlayer(QObject *parent = nullptr);
    ~MediaPlayer();
    QUrl source() const;
    void setSource(const QUrl &newSource);
    int duration() const;
    void setDuration(int newDuration);
    int position() const;

    enum State
    {
        StoppedState,
        PlayingState,
        PausedState,
    };


    int state() const;
    void setState(int newState);

    float volume() const;
    void setVolume(float newVolume);

signals:
    void sourceChanged();
    void durationChanged();
    void positionChanged();
    void stateChanged();
    void volumeChanged();

private:
    GstElement *pipeline;
    QUrl m_source;
    QTimer *timer;
    int m_duration;
    int m_position;
    int m_state;
    float m_volume;

    static gboolean busCallback(GstBus *bus, GstMessage *msg, gpointer data);

public slots:
    void play();
    void pause();
    void setPosition(int newPosition);
};

#endif // MEDIAPLAYER_H
