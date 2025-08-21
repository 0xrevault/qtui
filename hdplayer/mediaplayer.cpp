/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mediaplay.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-06
* @link          http://www.alientek.com
*******************************************************************/
#include "mediaplayer.h"
#include <QUrl>
#include <QString>
#include <QDebug>

gboolean MediaPlayer::busCallback(GstBus *bus, GstMessage *msg, gpointer data) {
    MediaPlayer* instance = static_cast<MediaPlayer*>(data);
    Q_UNUSED(bus);
    switch (GST_MESSAGE_TYPE(msg)) {
    case GST_MESSAGE_EOS:
        instance->setState(State::StoppedState);
        instance->timer->stop();
        break;
    case GST_MESSAGE_STATE_CHANGED:
        GstState new_state;
        gst_element_get_state(instance->pipeline, &new_state, NULL, 0);
        switch (new_state) {
        case GST_STATE_PAUSED:
            instance->setState(State::PausedState);
            break;
        case GST_STATE_PLAYING:
            instance->timer->start();
            instance->setState(State::PlayingState);
        case GST_STATE_READY:
            if (instance->pipeline) {
                gint64 duration;
                if (gst_element_query_duration(instance->pipeline, GST_FORMAT_TIME,
                                               &duration)) {
                    instance->setDuration(duration / 1000000);
                }
            }
            break;
        default:
            break;
        }
        break;
    default:
        break;
    }
    return TRUE;
}

void MediaPlayer::play()
{
    if (m_source.isValid()) {
        if (pipeline) {
            GstState state;
            gst_element_get_state(pipeline, &state, NULL, 0);
            if (state == GST_STATE_PAUSED) {
                gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
                return;
            }
        }
        if (pipeline) {
            gst_element_set_state(pipeline, GST_STATE_NULL);
            gst_element_get_state(pipeline, NULL, NULL,
                                  GST_CLOCK_TIME_NONE);
            gst_object_unref(pipeline);
            pipeline = NULL;
        }

        QString playCmd = tr("uridecodebin uri=%1  name=decoder decoder. ! queue !"
                             " waylandsink fullscreen=true decoder. ! queue ! audioconvert"
                             " ! volume name=audiovolume ! autoaudiosink").arg(m_source.toString());
        pipeline = gst_parse_launch(playCmd.toStdString().c_str(), nullptr);
        GstElement *volume = gst_bin_get_by_name(GST_BIN(pipeline), "audiovolume");
        if (volume) {
            g_object_set(G_OBJECT(volume), "volume", m_volume, NULL);
            gst_object_unref(volume);
        }
        GstBus *bus = gst_element_get_bus(pipeline);
        gst_bus_add_watch(bus, busCallback, this);
        gst_object_unref(bus);

    }
    if (pipeline) {
        gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
    }
}

void MediaPlayer::pause()
{
    if (pipeline) {
        gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PAUSED);
    }
}

MediaPlayer::MediaPlayer(QObject *parent) : QObject(parent)
{
    gst_init(nullptr, nullptr);
    timer = new QTimer(this);
    timer->setInterval(1000);
    QObject::connect(timer, &QTimer::timeout, [&](){
        if (pipeline) {
            gint64 position = 0;
            gst_element_query_position(pipeline, GST_FORMAT_TIME,
                                       &position);
            m_position = position / 1000000;
            emit positionChanged();
        }
    });
}

MediaPlayer::~MediaPlayer()
{
    if (pipeline) {
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_element_get_state(pipeline, NULL, NULL,
                              GST_CLOCK_TIME_NONE);
        gst_object_unref(pipeline);
        pipeline = NULL;
    }
}

QUrl MediaPlayer::source() const
{
    return m_source;
}

void MediaPlayer::setSource(const QUrl &newSource)
{
    if (m_source == newSource)
        return;
    m_source = newSource;
    emit sourceChanged();
}

int MediaPlayer::duration() const
{
    return m_duration;
}

void MediaPlayer::setDuration(int newDuration)
{
    if (m_duration == newDuration)
        return;
    m_duration = newDuration;
    emit durationChanged();
}

int MediaPlayer::position() const
{
    return m_position;
}

void MediaPlayer::setPosition(int newPosition)
{
    if (m_position == newPosition)
        return;
    m_position = newPosition;

    gint64 target_position = (gint64)newPosition * 1000000;
    gst_element_seek(pipeline, 1.0, GST_FORMAT_TIME,
                     GST_SEEK_FLAG_FLUSH, GST_SEEK_TYPE_SET,
                     target_position, GST_SEEK_TYPE_NONE,
                     GST_CLOCK_TIME_NONE);
    emit positionChanged();
}

int MediaPlayer::state() const
{
    return m_state;
}

void MediaPlayer::setState(int newState)
{
    if (m_state == newState)
        return;
    m_state = newState;
    emit stateChanged();
}

float MediaPlayer::volume() const
{
    return m_volume;
}

void MediaPlayer::setVolume(float newVolume)
{
    if (newVolume > 1)
        newVolume = 1;
    if (newVolume < 0)
        newVolume = 0;
    if (qFuzzyCompare(m_volume, newVolume))
        return;
    m_volume = newVolume;
    if (pipeline) {
        GstElement *volume = gst_bin_get_by_name(GST_BIN(pipeline), "audiovolume");
        if (volume) {
            g_object_set(G_OBJECT(volume), "volume", newVolume, NULL);
            gst_object_unref(volume);
        }
    }
    emit volumeChanged();
}
