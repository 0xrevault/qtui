/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mediaplaylist.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-09
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "mediaplaylist.h"
#include <QFileInfo>
#include <QStringList>
#include <QString>
#include <QFile>
#include <QImage>
#include <QProcess>
#include <QDebug>

MediaPlayerList::MediaPlayerList(QObject *parent) : QAbstractListModel(parent)
{
}


int MediaPlayerList::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    Q_UNUSED(parent);
    return m_videoDataArr.count();
}

QVariant MediaPlayerList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    switch (role) {
    case VideoDataRole:
        return QVariant::fromValue(static_cast<QObject *>(m_videoDataArr.value(index.row())));
    }

    return QVariant();
}

QHash<int, QByteArray> MediaPlayerList::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[VideoDataRole] = "media";
    return roles;
}

int MediaPlayerList::count() const
{
    return m_videoDataArr.count();
}

QString MediaPlayerList::sourcePath() const
{
    return m_sourcePath;
}

void MediaPlayerList::setSourcePath(const QString &newSourcePath)
{
    if (m_sourcePath == newSourcePath)
        return;
    m_sourcePath = newSourcePath;
    emit sourcePathChanged();
}

void MediaPlayerList::updateModel()
{
    QDir dir(m_sourcePath + "cameravideos");
    if(!dir.exists()) {
        qDebug()<< m_sourcePath + "cameravideos" << "does not exist";
        return ;
    }

    QStringList filter;
    filter <<"*.mkv" << "*.mp4" << "*.wmv" << "*.avi" << "*.ogg" << "*.mov" << "*.3gp" << "*.webm";
    QFileInfoList files = dir.entryInfoList(filter, QDir::Files);
    for (int i = 0; i < files.count(); i++) {
        VideoData *data = new VideoData;
        QFileInfo fileif(files.at(i).filePath());
        data->setSourceUrl(QString::fromUtf8((QString("file://" + fileif.filePath()).toUtf8().data())));
        data->setCoverArtUrl(QString::fromUtf8((QString("file://" + m_sourcePath + "jpg" + "/" + fileif.baseName() + ".jpg").toUtf8().data())));
        bool alreadExits = false;
        foreach (VideoData *tmpVideoData, m_videoDataArr) {
            if (tmpVideoData->sourceUrl() == data->sourceUrl()) {
                alreadExits = true;
                break;
            }
        }
        if (alreadExits)
            continue;
        QFile file(m_sourcePath + "jpg" + "/" + fileif.baseName() + ".jpg");
        QProcess pro;
        QImage image(m_sourcePath + "jpg" + "/" + fileif.baseName() +".jpg");
        if (!file.exists() || image.isNull()) {
            QString cmd1 = m_sourcePath + "shell" + "/generate_coverart.sh ";
            QString cmd2 = "\"" + fileif.filePath() + "\"" + " ";
            QString cmd3 =  "\"" + file.fileName() + "\"" ;
            pro.start(cmd1 + cmd2 + cmd3);
            pro.waitForFinished(3000);
        }
        pro.start(m_sourcePath + "shell" + "/get_duration.sh " + files.at(i).filePath());
        pro.waitForFinished(1500);
        pro.waitForReadyRead(1500);
        data->setDuration(pro.readLine().simplified());
        system("sync");
        beginInsertRows(QModelIndex(), m_videoDataArr.count(), m_videoDataArr.count());
        m_videoDataArr.append(data);
        endInsertRows();
    }
    emit countChanged();
}

void MediaPlayerList::deleteSelectVideoFiles()
{
    int tmpCount = m_videoDataArr.count() - 1;
    for (int i = tmpCount; i >= 0 ; --i) {
        if (m_videoDataArr[i]->checked()) {
            QString localFilePath = m_videoDataArr[i]->sourceUrl().toLocalFile();
            QFile file(localFilePath);
            if (file.exists())
                file.remove();
            localFilePath = m_videoDataArr[i]->coverArtUrl().toLocalFile();
            file.setFileName(localFilePath);
            if (file.exists())
                file.remove();
            beginRemoveRows(QModelIndex(), i, i);
            m_videoDataArr.remove(i);
            endRemoveRows();
        }
    }
    Q_EMIT countChanged();
}
