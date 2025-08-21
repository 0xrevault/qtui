/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mediaplaylist.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-09
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef MEDIAPLAYLIST_H
#define MEDIAPLAYLIST_H

#include <QAbstractListModel>
#include <QDir>
#include <QVector>
#include <QDebug>
#include "videodata.h"

class MediaPlayerList : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QString sourcePath READ sourcePath WRITE setSourcePath NOTIFY sourcePathChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)
public:
    explicit MediaPlayerList(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index,
                  int role = Qt::DisplayRole) const override;
    enum ItemRoles {
        VideoDataRole = Qt::UserRole + 1
    };

    QString sourcePath() const;
    void setSourcePath(const QString &newSourcePath);

    int count() const;

signals:
    void sourcePathChanged();

    void countChanged();

private:
    QHash<int, QByteArray> roleNames() const;
    QVector<VideoData *> m_videoDataArr;
    QString m_sourcePath;
    int m_count;

public slots:
    void updateModel();
    void deleteSelectVideoFiles();
};

#endif // MEDIAPLAYLIST_H
