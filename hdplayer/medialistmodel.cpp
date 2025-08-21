/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 1990-2030. All rights reserved.
* @projectName   mediaer
* @brief         mediaListModel.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2022-10-19
* @link          www.opendev.com/www.alientek.com
*******************************************************************/
#include "medialistmodel.h"
#include <QDir>
#include <QDebug>
#include <QDirIterator>
#include <QDateTime>
#include <QImage>
#include <QProcess>
#include <QUrl>
#include <QCoreApplication>

Media::Media(QUrl path, QString title, QString content, QString lastModified) {
    m_path = path;
    m_title = title;
    m_content = content;
    m_lastModified = lastModified;
}

QUrl Media::getpath() const {
    return m_path;
}

QString Media::gettitle() const {
    return m_title;
}

QString Media::getcontent() const {
    return m_content;
}

QString Media::getlastModified() const {
    return m_lastModified;
}

void Media::settitle(QString title) {
    m_title = title;
}

MediaListModel::MediaListModel(QObject *parent) : QAbstractListModel(parent) {
    m_currentIndex = -1;
}

MediaListModel::~MediaListModel()
{

}

int MediaListModel::currentIndex() const {
    return m_currentIndex;
}

int MediaListModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return mediaData.count();
}

QVariant MediaListModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= mediaData.count())
        return QVariant();
    const Media &s = mediaData.at(index.row());
    switch (role) {
    case pathRole:
        return s.getpath();
    case titleRole:
        return s.gettitle();
    case contentRole:
        return s.getcontent();
    case lastModifiedRole:
        return s.getlastModified();
    default:
        return QVariant();
    }
}

int MediaListModel::randomIndex() {
    int tmp;
    srand(time(NULL));
    do {
        tmp = qrand() % mediaData.count();
    } while (tmp == m_currentIndex);
    setCurrentIndex(tmp);
    return tmp;
}

QString MediaListModel::getcurrentTitle() const {
    return mediaData.at(m_currentIndex).gettitle();
}

void MediaListModel::add(QString paths) {

    if (mediaData.count() > 0)
        this->remove(0, mediaData.count() - 1);

    int count, index;
    QString  title;
    QString content;
    QString lastModified;
    QDir dir(paths);

    if(!dir.exists()) {
        qDebug()<<"resource/media does not exist";
        return ;
    }

    QStringList filter;
    filter <<"*.mkv" << "*.mp4" << "*.wmv" << "*.avi" << "*.ogg" << "*.mov" << "*.3gp" << "*.webm";
    QList<QUrl> pathList;
#if 0
    QDirIterator it(paths, filter, QDir::Files | QDir::NoSymLinks);

    while (it.hasNext()){
        it.next();

        QFileInfo fileif = it.fileInfo();
        lastModified = fileif.lastModified().toString("MM-dd hh:mm");
#ifdef WIN32
        QUrl mediaPath = QString::fromUtf8((fileif.filePath().toUtf8().data()));
#else
        QUrl mediaPath = QString::fromUtf8((QString("file:///" + fileif.filePath()).toUtf8().data()));
#endif
        pathList.append(mediaPath);
    }
#endif

#if 1
    QDir dir1(paths);
    QDir dir2(dir1.absolutePath());
    QFileInfoList files = dir2.entryInfoList(filter, QDir::Files);
    for (int i = 0; i < files.count(); i++) {
        QFileInfo fileif(files.at(i).filePath());
        lastModified = fileif.lastModified().toString("MM-dd hh:mm");

#ifdef WIN32
        QUrl mediaPath = QString::fromUtf8((fileif.filePath().toUtf8().data()));
#else
        QUrl mediaPath = QString::fromUtf8((QString("file://" + fileif.filePath()).toUtf8().data()));
#endif
        pathList.append(mediaPath);
    }
#endif
    count = pathList.count();
    for (index = 0; index < count; index ++) {

        title = pathList.at(index).fileName(QUrl::FullyDecoded);
#ifdef WIN32
        QFile file(pathList.at(index).toString());
#else
        QFile file(pathList.at(index).toString().mid(7));
#endif
        if (!file.exists())
            qDebug() << title << "does not exists";

        QFileInfo fileif(files.at(index).filePath());

        content = pathList.at(index).toString().replace(fileif.suffix(), "jpg").replace("movies", "coverplan");

        QUrl tmpUrl = content;
        QImage image(tmpUrl.toLocalFile());
        QFileInfo fileInfoCoverplan(tmpUrl.toLocalFile());
        if (image.isNull()) {
            //QProcess pro;
            GenerateCoverplan * m_enerateCoverplan = new GenerateCoverplan(this);
            QString cmd1 = fileInfoCoverplan.path() + "/generate_coverplan.sh ";
            QString cmd2 = "\"" + fileif.filePath() + "\"" + " ";
            QString cmd3 =  "\"" + fileInfoCoverplan.path() + "/" + files.at(index).baseName() + "\"" ;
            m_enerateCoverplan->setCmd(cmd1 + cmd2 + cmd3);
            connect(m_enerateCoverplan, SIGNAL(finished()), this, SIGNAL(updateCoverplan()));
            //pro.start(cmd1 + cmd2 + cmd3);
            //pro.waitForFinished(10000);
        }
        addMedia(pathList.at(index), title, content, lastModified);
    }

    if (m_currentIndex < 0 && mediaData.count()) {
        setCurrentIndex(0);
    }
}

void MediaListModel::move(int from, int to) {
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);
    mediaData.move(from, to);
    endMoveRows();
}

void MediaListModel::remove(int first, int last) {
    if ((first < 0) && (first >= mediaData.count()))
        return;
    if ((last < 0) && (last >= mediaData.count()))
        return;
    if (first > last) {
        first ^= last;
        last ^= first;
        first ^= last;
    }
    beginRemoveRows(QModelIndex(), first, last);
    while (first <= last) {
        mediaData.removeAt(first);
        last --;
    }
    endRemoveRows();
    if (m_currentIndex >= mediaData.count()) {
        setCurrentIndex(mediaData.count() - 1);
    }
}

void MediaListModel::removeOne(int index) {
#ifdef WIN32
    QFile file(mediaData.at(index).getpath().toString());
#else
    QFile file(mediaData.at(index).getpath().toString().mid(8));
#endif
    beginRemoveRows(QModelIndex(), index, index);
    mediaData.removeAt(index);
    if (file.remove())
        qDebug() << "delete ok" <<endl;
    endRemoveRows();
    if (m_currentIndex >= mediaData.count()) {
        setCurrentIndex(mediaData.count() - 1);
    }
}

void MediaListModel::setCurrentTitle(QString title) {
    Media s = mediaData.at(m_currentIndex);
    s.settitle(title);
    mediaData.replace(m_currentIndex, s);
}

QString MediaListModel::getStorepath()
{
    return QCoreApplication::applicationDirPath();
}

void MediaListModel::setCurrentIndex(const int & i) {
    if (i >= mediaData.count() && m_currentIndex != 0) {
        m_currentIndex = 0;
        emit currentIndexChanged();
    } else if ((i >= 0) && (i < mediaData.count()) && (m_currentIndex != i)) {
        m_currentIndex = i;
        emit currentIndexChanged();
    }
    if (m_currentIndex >= 0 && m_currentIndex <= mediaData.count() - 1)
        setCurrentMedia(mediaData.at(m_currentIndex).getpath());
}

QHash<int, QByteArray> MediaListModel::roleNames() const {
    QHash<int, QByteArray> role;
    role[pathRole] = "path";
    role[titleRole] = "title";
    role[contentRole] = "content";
    role[lastModifiedRole] = "lastModified";
    return role;
}

void MediaListModel::addMedia(QUrl path, QString title, QString content, QString lastModified) {
    beginInsertRows(QModelIndex(), mediaData.count(), mediaData.count());
    mediaData.append(Media(path, title, content, lastModified));
    endInsertRows();
}

QUrl MediaListModel::currentMedia() const
{    if (m_currentIndex >= 0 && m_currentIndex <= mediaData.count() - 1)
        return mediaData.at(m_currentIndex).getpath();
    else
        return QUrl();
}

void MediaListModel::setCurrentMedia(const QUrl &newCurrentMedia)
{
    if (m_currentMedia == newCurrentMedia)
        return;
    m_currentMedia = newCurrentMedia;
    emit currentMediaChanged();
}

