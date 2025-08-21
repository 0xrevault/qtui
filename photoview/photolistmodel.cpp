/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 1990-2030. All rights reserved.
* @projectName   photoview
* @brief         photoListModel.cpp
* @author        Deng Zhimao
* @email         1252699831@qq.com
* @date          2020-07-18
*******************************************************************/
#include "photolistmodel.h"
#include <QDir>
#include <QDebug>
#include <QDirIterator>
photo::photo(QUrl path, QString title) {
    m_path = path;
    m_title = title;
}

QUrl photo::getpath() const {
    return m_path;
}

QString photo::gettitle() const {
    return m_title;
}

void photo::settitle(QString title) {
    m_title = title;
}

PhotoListModel::PhotoListModel(QObject *parent) : QAbstractListModel(parent) {
    m_currentIndex = -1;
    phtoListData.clear();
    fileSystemWatcher = new QFileSystemWatcher(this);
    QObject::connect(fileSystemWatcher, &QFileSystemWatcher::directoryChanged, [this](){
        this->add(m_albumPath);
    });
}

PhotoListModel::~PhotoListModel()
{
}

int PhotoListModel::currentIndex() const {
    return m_currentIndex;
}

int PhotoListModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return phtoListData.count();
}

QVariant PhotoListModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= phtoListData.count())
        return QVariant();
    const photo &s = phtoListData.at(index.row());
    switch (role) {
    case pathRole:
        return s.getpath();
    case titleRole:
        return s.gettitle();
    default:
        return QVariant();
    }
}

int PhotoListModel::randomIndex() {
    int tmp;
    srand(time(NULL));
    do {
        tmp = qrand() % phtoListData.count();
    } while (tmp == m_currentIndex);
    setCurrentIndex(tmp);
    return tmp;
}

QString PhotoListModel::getcurrentTitle() const {
    return phtoListData.at(m_currentIndex).gettitle();
}

QUrl PhotoListModel::getcurrentPath() const {
    return phtoListData.at(m_currentIndex).getpath();
}

void PhotoListModel::add( QString paths) {
    if (phtoListData.count() > 0)
        this->remove(0, phtoListData.count() - 1);
    revert();
    int count, index;
    QString  title;
    QDir dir(paths);
    if(!dir.exists()){
        qDebug()<<"src/images or src/photos Dir not exist"<<endl;
        return ;
    }
    QStringList filter;
    filter<<"*.jpg"<<"*.png"<<"*jpeg";
    QDirIterator it(paths, filter, QDir::Files | QDir::NoSymLinks);
    QList<QUrl> pathList;
    while (it.hasNext()){
        it.next();
        QFileInfo fileif = it.fileInfo();
        QString photosPath = QString::fromUtf8((QString("file:///" + fileif.filePath()).toUtf8().data()));

        //qDebug()<<photosPath<<endl;
        pathList.append(photosPath);
    }
    count = pathList.count();
    for (index = 0; index < count; index ++) {
        title = pathList.at(index).fileName(QUrl::FullyDecoded).remove(-4, 4);
        addPhoto(pathList.at(index), title);
    }

    /*if (m_currentIndex < 0 && phtoListData.count()) {
        setCurrentIndex(phtoListData.count() - 1);
    }*/
    emit listModelInit();
    revert();
}

void PhotoListModel::move(int from, int to) {
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);
    phtoListData.move(from, to);
    endMoveRows();
}

void PhotoListModel::remove(int first, int last) {
    revert();
    if ((first < 0) && (first >= phtoListData.count()))
        return;
    if ((last < 0) && (last >= phtoListData.count()))
        return;
    if (first > last) {
        first ^= last;
        last ^= first;
        first ^= last;
    }
    beginRemoveRows(QModelIndex(), first, last);
    while (first <= last) {
        phtoListData.removeAt(first);
        last --;
    }
    endRemoveRows();
    revert();
    if (m_currentIndex >= phtoListData.count()) {
        setCurrentIndex(phtoListData.count() - 1);
    }
}

void PhotoListModel::removeOne(int index) {
    if (phtoListData.count() != 0) {
        revert();
        QFile file(phtoListData.at(index).getpath().toString().mid(8));
        beginRemoveRows(QModelIndex(), index, index);
        phtoListData.removeAt(index);
        if (file.remove())
            qDebug() << "delete ok" <<endl;
        endRemoveRows();
        /*if (m_currentIndex >= phtoListData.count()) {
            setCurrentIndex(phtoListData.count() - 1);
        }*/
        revert();
    } else {
    }
}

void PhotoListModel::setCurrentTitle(QString title) {
    photo s = phtoListData.at(m_currentIndex);
    s.settitle(title);
    phtoListData.replace(m_currentIndex, s);
}

void PhotoListModel::setCurrentIndex(const int & i) {
    if (i >= phtoListData.count() && m_currentIndex != 0) {
        m_currentIndex = 0;
        emit currentIndexChanged();
    } else if ((i >= 0) && (i < phtoListData.count()) && (m_currentIndex != i)) {
        m_currentIndex = i;
        emit currentIndexChanged();
    } else if(i < 0) {
        m_currentIndex = -1;
        emit currentIndexChanged();
    }
}

QHash<int, QByteArray> PhotoListModel::roleNames() const {
    QHash<int, QByteArray> role;
    role[pathRole] = "path";
    role[titleRole] = "title";
    return role;
}

QString PhotoListModel::albumPath() const
{
    return m_albumPath;
}

void PhotoListModel::setAlbumPath(const QString &newAlbumPath)
{
    if (m_albumPath == newAlbumPath)
        return;
    if (m_albumPath != "")
        fileSystemWatcher->removePath(m_albumPath);
    m_albumPath = newAlbumPath;

    // upate album
    add(m_albumPath);

    fileSystemWatcher->addPath(newAlbumPath);

    emit albumPathChanged();
}

void PhotoListModel::addPhoto(QString fileName) {
    revert();
    QUrl path;
    QString title;
    QFile file(fileName);
    if (file.exists()) {
        QString str = "file:///" + fileName;
        path = QString::fromUtf8((str.toUtf8()).data());
        title = file.fileName();
    } else {
        qDebug() << "Resource error! No such file or dir!" << endl;
        return;
    }
    beginInsertRows(QModelIndex(), phtoListData.count(), phtoListData.count());
    phtoListData.append(photo(path, title));
    endInsertRows();
    //setCurrentIndex(phtoListData.count() - 1);
    revert();
}

void PhotoListModel::addPhoto(QUrl path, QString title) {
    revert();
    beginInsertRows(QModelIndex(), phtoListData.count(), phtoListData.count());
    phtoListData.append(photo(path, title));
    endInsertRows();
    //setCurrentIndex(phtoListData.count() - 1);
    revert();
}

int PhotoListModel::count()
{
    return phtoListData.count();
}
