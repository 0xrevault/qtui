/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         camera.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-08
* @link          http://www.alientek.com
*******************************************************************/
#ifndef CAMERA_H
#define CAMERA_H

#include <QObject>
#include <QThread>
#include <QImage>
#include <QString>
#include <QSize>
#include <QStandardPaths>
#include <QDir>
#include <QMutexLocker>
#include <QMap>
#include <QByteArray>
#include <QFile>
#include <QBuffer>
#include "ispctrolthread.h"

class Camera : public QThread
{
    Q_OBJECT
    Q_PROPERTY(QString deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QSize resolution READ resolution WRITE setResolution NOTIFY resolutionChanged)
    Q_PROPERTY(int bufferCount READ bufferCount WRITE setBufferCount NOTIFY bufferCountChanged)
    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(int state READ state WRITE setState  NOTIFY stateChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_ENUMS(State)
public:
    explicit Camera(QObject *parent = nullptr);
    enum MediaType{ Movies, Music, Pictures};
    enum State
    {
        StoppedState,
        PlayingState
    };

    QString deviceId() const;
    void setDeviceId(const QString &newDeviceId);

    QSize resolution() const;
    void setResolution(const QSize &newResolution);

    int bufferCount() const;
    void setBufferCount(int newBufferCount);

    QImage image() const;
    void setImage(const QImage &newImage);

    int state() const;
    void setState(int newState);

    QString path() const;
    void setPath(const QString &newPath);
protected:
    void run() override;

signals:
    void deviceIdChanged();
    void resolutionChanged();
    void bufferCountChanged();
    void imageChanged();
    void stateChanged();
    void pathChanged();
    void imageCapture(QString fileName);

private:
    QString m_deviceId;
    QSize m_resolution;
    int m_bufferCount;
    bool m_flag;
    QImage m_image;
    int m_state;
    QString m_path;

    mutable QMutex m_mutex;
    mutable QHash<QString, qint64> m_lastUsedIndex;

    QMap<MediaType, QStringList> m_customLocations;
    QString generateFileName(const QString &requestedName,
                             MediaType type,
                             const QString &prefix,
                             const QString &extension);
    QString generateFileName(const QString &prefix,
                             const QDir &dir,
                             const QString &extension);
    QDir defaultLocation(MediaType type);

public slots:
    void play();
    void stop();
    void takeImage();
};

#endif // CAMERA_H
