/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mediaplayer.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-11
* @link          http://www.alientek.com
*******************************************************************/
#ifndef MEDIAPLAYER_H
#define MEDIAPLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include <QStandardPaths>
#include <QDir>
#include <QUrl>
#include <QMap>
#include <QHash>
#include <QString>
#include <QFile>
#include <QMutexLocker>

#include "ispctrolthread.h"
#include "fixvideothread.h"

class MediaPlayer : public QMediaPlayer {
    Q_OBJECT
    Q_PROPERTY(QString  source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(int mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_ENUMS(MediaType)
    Q_ENUMS(Mode)
public:
    explicit MediaPlayer(QObject *parent = nullptr);
    enum MediaType{ Movies, Music, Pictures};
    enum Mode
    {
        PlayCameraMode,
        RecordMode,
        PlayVideoMode
    };


    QString  source() const;
    void setSource(const QString  &newSource);

    QString path() const;
    void setPath(const QString &newPath);

    int mode() const;
    void setMode(int newMode);

signals:
    void sourceChanged();
    void pathChanged();
    void modeChanged();
    void videoFileChanged();

private:
    QString  m_source;

    mutable QMutex m_mutex;
    QString m_backupFileName;
    QString m_vidoeFileName;

    mutable QHash<QString, qint64> m_lastUsedIndex;
    QString m_path;
    int m_mode;
    QMap<MediaType, QStringList> m_customLocations;
    QString generateFileName(const QString &requestedName,
                             MediaType type,
                             const QString &prefix,
                             const QString &extension);
    QString generateFileName(const QString &prefix,
                             const QDir &dir,
                             const QString &extension);
    QDir defaultLocation(MediaType type);
private slots:
    void updateMediaSource();
};

#endif // MEDIAPLAYER_H
