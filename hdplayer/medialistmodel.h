/******************************************************************
Copyright 2022 Guangzhou ALIENTEK Electronincs Co.,Ltd. All rights reserved
Copyright © Deng Zhimao Co., Ltd. 1990-2030. All rights reserved.
* @projectName   videoplayer
* @brief         medialistmodel.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2022-11-22
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef MEDIALISTMODEL_H
#define MEDIALISTMODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>
#include "generatecoverplan.h"

class Media {
public:
    explicit Media(QUrl path, QString title, QString content, QString lastModified);
    QString getcontent() const;
    QString getlastModified() const;
    QString gettitle() const;
    QUrl getpath() const;
    void settitle(QString title);

private:
    QString  m_title;
    QUrl m_path;
    QString m_content;
    QString m_lastModified;
};

class MediaListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit MediaListModel(QObject *parent = nullptr);
    ~MediaListModel();
    int currentIndex() const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE int randomIndex();
    Q_INVOKABLE QString getcurrentTitle() const;
    Q_INVOKABLE void add(QString paths);
    Q_INVOKABLE void move(int from, int to);
    Q_INVOKABLE void remove(int first, int last);
    Q_INVOKABLE void removeOne(int index);
    Q_INVOKABLE void setCurrentTitle(QString title);
    Q_INVOKABLE QString getStorepath();
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QUrl currentMedia READ currentMedia  NOTIFY currentMediaChanged)
    void setCurrentIndex(const int & i);

    enum MediaRole {
        pathRole = Qt::UserRole + 1,
        titleRole,
        contentRole,
        lastModifiedRole,
    };

    QUrl currentMedia() const;
    void setCurrentMedia(const QUrl &newCurrentMedia);

signals:
    void currentIndexChanged();
    void currentMediaChanged();
    void updateCoverplan();

public slots:

private:
    QHash<int, QByteArray> roleNames() const;
    void addMedia(QUrl path, QString title, QString content, QString lastModified);

    int m_currentIndex;
    QUrl m_currentMedia;
    QList<Media> mediaData;
};

#endif // MEDIALISTMODEL_H
