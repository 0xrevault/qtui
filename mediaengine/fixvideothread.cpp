/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         fixvideothread.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-09
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "fixvideothread.h"
#include <QFileInfo>
#include <QDir>
#include <QFile>
#include <QDebug>
FixVideoThread::FixVideoThread(QObject *parent)
    : QThread{parent}
{}

QString FixVideoThread::videoFile() const
{
    return m_videoFile;
}

void FixVideoThread::setVideoFile(const QString &newVideoFile)
{
    if (m_videoFile == newVideoFile)
        return;
    m_videoFile = newVideoFile;
    emit videoFileChanged();
}

QString FixVideoThread::backupFile() const
{
    return m_backupFile;
}

void FixVideoThread::setBackupFile(const QString &newBackupFile)
{
    if (m_backupFile == newBackupFile)
        return;
    m_backupFile = newBackupFile;
    emit backupFileChanged();
    this->start();
}

void FixVideoThread::run()
{
    QString cmd = tr("ffmpeg -loglevel error -i %1  -c:v copy %2 -y").arg(m_backupFile).arg(m_videoFile);

    system(cmd.toStdString().c_str());

    QFile file(m_backupFile);
    file.remove();
}
