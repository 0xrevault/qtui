/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         videodata.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-09
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "videodata.h"

VideoData::VideoData(QObject *parent) : QObject{ parent },m_checked(false)
{
}

QUrl VideoData::coverArtUrl() const
{
    return m_coverArtUrl;
}

void VideoData::setCoverArtUrl(const QUrl &newCoverArtUrl)
{
    if (m_coverArtUrl == newCoverArtUrl)
        return;
    m_coverArtUrl = newCoverArtUrl;
    emit coverArtUrlChanged();
}

QUrl VideoData::sourceUrl() const
{
    return m_sourceUrl;
}

void VideoData::setSourceUrl(const QUrl &newSourceUrl)
{
    if (m_sourceUrl == newSourceUrl)
        return;
    m_sourceUrl = newSourceUrl;
    emit sourceUrlChanged();
}

QString VideoData::duration() const
{
    return m_duration;
}

void VideoData::setDuration(const QString &newDuration)
{
    if (m_duration == newDuration)
        return;
    m_duration = newDuration;
    emit durationChanged();
}

bool VideoData::checked() const
{
    return m_checked;
}

void VideoData::setChecked(bool newChecked)
{
    if (m_checked == newChecked)
        return;
    m_checked = newChecked;
    emit checkedChanged();
}
