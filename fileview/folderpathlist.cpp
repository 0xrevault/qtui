/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   fileview
* @brief         folderpathlist.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-11-27
*******************************************************************/
#include "folderpathlist.h"
#include <QDir>
#include <QDebug>
FolderPathList::FolderPathList(QObject *parent)
    : QAbstractListModel(parent)
{
    m_filesystemwatcher = new QFileSystemWatcher(this);
}

int FolderPathList::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    Q_UNUSED(parent);
    return m_mediaInfoArr.count();
}

QVariant FolderPathList::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    switch (role) {
    case FolderPathRole:
        return QVariant::fromValue(static_cast<QObject *>(m_mediaInfoArr.value(index.row())));
    }

    return QVariant();
}

QHash<int, QByteArray> FolderPathList::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FolderPathRole] = "mediaInfo";
    return roles;
}

const QString &FolderPathList::currentMediaPath() const
{
    if (m_currentIndex < 0)
        return m_currentMediaPath;
    if (m_currentIndex <= m_mediaInfoArr.count() - 1)
        return m_mediaInfoArr[m_currentIndex]->path();
    else {
        return m_currentMediaPath;
    }
}

void FolderPathList::setCurrentMediaPath(const QString &newCurrentMediaPath)
{
    if (m_currentMediaPath == newCurrentMediaPath)
        return;
    m_currentMediaPath = newCurrentMediaPath;
    emit currentMediaPathChanged();
}

int FolderPathList::currentIndex() const
{
    return m_currentIndex;
}

void FolderPathList::setCurrentIndex(int newCurrentIndex)
{
    if (m_currentIndex == newCurrentIndex)
        return;

    if (newCurrentIndex >= 0 && m_currentIndex <= m_mediaInfoArr.count() - 1) {
        m_currentIndex = newCurrentIndex;
        emit currentIndexChanged();
    }

    if (newCurrentIndex < 0)
        m_currentIndex = -1;
}

void FolderPathList::updateModel()
{
    int tmpCount = m_mediaInfoArr.count() - 1;
    for (int i = tmpCount; i >= 0 ; --i) {
        QString localPath = m_mediaInfoArr[i]->path();
        QDir dir(localPath);
        if (!dir.exists()) {
            beginRemoveRows(QModelIndex(), i, i);
            m_mediaInfoArr.removeAt(i);
            endRemoveRows();
        }
    }

    QDir dir(m_mediaPath);
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    QStringList folderList = dir.entryList();
    folderList.insert(0, "/");

    for (const QString &folder : folderList) {
        QString absolutePath = dir.absoluteFilePath(folder);
        bool isAreadyExists = false;
        for (const MediaInfo *info : m_mediaInfoArr) {
            if (info->path() == absolutePath) {
                isAreadyExists = true;
                break;
            }
        }
        if (isAreadyExists)
            continue;

        MediaInfo *info = new MediaInfo;
        if (folder.contains("sd")) {
            info->setMediaType(MediaType::USB);
        } else if (folder.contains("mmc")) {
            info->setMediaType(MediaType::MMC);
        } else if (folder == "/") {
            info->setMediaType(MediaType::MMC);
        } else {
            info->setMediaType(MediaType::Unknow);
        }

        info->setPath(absolutePath);
        beginInsertRows(QModelIndex(), m_mediaInfoArr.count(), m_mediaInfoArr.count());
        m_mediaInfoArr.append(info);
        endInsertRows();
    }
    setCurrentIndex(-1);
    emit currentIndexChanged();
}

QStringList FolderPathList::splitPath(const QString &path)
{
    QStringList components;
    QString currentPath = "";
    QStringList pathElements = path.split('/');

    for (const QString &element : pathElements) {
        if (!element.isEmpty()) {
            currentPath += "/" + element;
            components.append(currentPath);
        }
    }
    components.insert(0, "/");
    return components;
}

const QString &FolderPathList::mediaPath() const
{
    return m_mediaPath;
}

void FolderPathList::setMediaPath(const QString &newMediaPath)
{
    if (m_mediaPath == newMediaPath)
        return;
    m_mediaPath = newMediaPath;
    emit mediaPathChanged();
    m_filesystemwatcher->addPath(m_mediaPath);
    connect(m_filesystemwatcher, SIGNAL(directoryChanged(QString)), SLOT(updateModel()));
    updateModel();
}

int MediaInfo::mediaType() const
{
    return m_mediaType;
}

void MediaInfo::setMediaType(int newMediaType)
{
    if (m_mediaType == newMediaType)
        return;
    m_mediaType = newMediaType;
    emit mediaTypeChanged();
}

const QString &MediaInfo::path() const
{
    return m_path;
}

void MediaInfo::setPath(const QString &newPath)
{
    if (m_path == newPath)
        return;
    m_path = newPath;
    emit pathChanged();
}
