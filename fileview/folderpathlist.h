/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   fileview
* @brief         folderpathlist.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-11-27
*******************************************************************/
#ifndef FOLDERPATHLIST_H
#define FOLDERPATHLIST_H

#include <QAbstractListModel>
#include <QFileSystemWatcher>
#include <QObject>
class MediaInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(int mediaType READ mediaType WRITE setMediaType NOTIFY mediaTypeChanged)
public:
    QString m_path;
    int m_mediaType;

    const QString &path() const;
    void setPath(const QString &newPath);
    int mediaType() const;
    void setMediaType(int newMediaType);

signals:
    void pathChanged();
    void mediaTypeChanged();

private:
};
class FolderPathList : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString mediaPath READ mediaPath WRITE setMediaPath NOTIFY mediaPathChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QString currentMediaPath READ currentMediaPath WRITE setCurrentMediaPath NOTIFY currentMediaPathChanged)
    Q_ENUMS(MediaType)

public:
    explicit FolderPathList(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    enum ItemRoles {
        FolderPathRole = Qt::UserRole + 1
    };

    enum MediaType {
        Unknow = 0,
        MMC ,
        USB
    };

    const QString &mediaPath() const;
    void setMediaPath(const QString &newMediaPath);

    int currentIndex() const;
    void setCurrentIndex(int newCurrentIndex);

    const QString &currentMediaPath() const;
    void setCurrentMediaPath(const QString &newCurrentMediaPath);

private:
    QHash<int, QByteArray> roleNames() const;
    QVector<MediaInfo *> m_mediaInfoArr;
    QFileSystemWatcher *m_filesystemwatcher;
    QString m_mediaPath;
    int m_currentIndex;
    QString m_currentMediaPath;

public slots:
    void updateModel();
    QStringList splitPath(const QString &path);
signals:
    void mediaPathChanged();
    void currentIndexChanged();
    void currentMediaPathChanged();
};

#endif // FOLDERPATHLIST_H
