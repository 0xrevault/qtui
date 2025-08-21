/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         camera.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-08
* @link          http://www.alientek.com
*******************************************************************/
#include "camera.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include <sys/ioctl.h>
#include <sys/mman.h>
#include <linux/videodev2.h>
#include <linux/input.h>
#include <QDebug>

Camera::Camera(QObject *parent)
    : QThread{parent},
    m_deviceId("/dev/video-camera0"),
    m_resolution(640, 480),
    m_bufferCount(3),
    m_flag(true),
    m_state(State::StoppedState)
{
    QObject::connect(this, &Camera::stateChanged, [this]() {
        if (m_state == Camera::PlayingState) {
            ISPCtrolThread * m_iSPCtrolThread = new ISPCtrolThread(this);
            if (!m_iSPCtrolThread->isRunning())
                m_iSPCtrolThread->start();
            QObject::connect(m_iSPCtrolThread, SIGNAL(finished()), m_iSPCtrolThread, SLOT(deleteLater()));
        }
    });
}

void Camera::run()
{
    int fd = open(m_deviceId.toStdString().c_str(), O_RDWR);
    if (fd == -1) {
        qDebug("ERROR: failed to open video device");
        qDebug() << "can not open " << m_deviceId;
        return;
    }

    struct v4l2_format fmt = {0};
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    if (ioctl(fd, VIDIOC_G_FMT, &fmt) == -1) {
        qDebug("ERROR: failed to VIDIOC_G_FMT");
        close(fd);
        return;
    }

    fmt.fmt.pix_mp.width = m_resolution.width();
    fmt.fmt.pix_mp.height = m_resolution.height();
    fmt.fmt.pix_mp.pixelformat =  V4L2_PIX_FMT_RGB24;//V4L2_PIX_FMT_RGB565;
    fmt.fmt.pix_mp.field = V4L2_FIELD_NONE;


    if (ioctl(fd, VIDIOC_S_FMT, &fmt) == -1) {
        qDebug("ERROR: failed to VIDIOC_S_FMT");
        close(fd);
        return;
    }

    struct v4l2_requestbuffers req;
    req.count = m_bufferCount;
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    req.memory = V4L2_MEMORY_MMAP;

    if (ioctl(fd, VIDIOC_REQBUFS, &req) == -1) {
        qDebug("ERROR: failed to VIDIOC_REQBUFS");
        close(fd);
        return;
    }

    struct v4l2_buffer buf;
    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_MMAP;

    void *buffers[m_bufferCount];

    for (int i = 0; i < m_bufferCount; i ++) {
        buf.index = i;
        if (ioctl(fd, VIDIOC_QUERYBUF, &buf) == -1) {
            qDebug("ERROR: failed to VIDIOC_QUERYBUF");
            close(fd);
            return;
        }

        buffers[i] = mmap(NULL, buf.length, PROT_READ | PROT_WRITE, MAP_SHARED, fd,
                          buf.m.offset);
        if (buffers[i] == MAP_FAILED) {
            qDebug("ERROR: failed to mmap video buffer");
            close(fd);
            return;
        }
    }
    for (int i = 0; i < m_bufferCount; i ++) {
        buf.index = i;
        if (0 > ioctl(fd, VIDIOC_QBUF, &buf)) {
            return;
        }
    }

    if (ioctl(fd, VIDIOC_STREAMON, &buf.type) == -1) {
        qDebug() << "ERROR: ioctl error: VIDIOC_STREAMON";
        return;
    }

    while (m_flag) {
        setState(State::PlayingState);
        for (int i = 0; i < m_bufferCount; i++) {
            buf.index = i;
            if (ioctl(fd, VIDIOC_DQBUF, &buf) == -1) {
                break;
            }

            QImage qImage((unsigned char*)buffers[i], fmt.fmt.pix.width, fmt.fmt.pix.height, QImage::Format_RGB888);
            if (!qImage.isNull())
                setImage(qImage.copy());

            if (ioctl(fd, VIDIOC_QBUF, &buf) == -1) {
                break;
            }
        }
    }

    for (int i = 0; i < m_bufferCount; i++) {
        munmap(buffers[i], buf.length);
    }
    close(fd);
    setState(State::StoppedState);
}

QString Camera::generateFileName(const QString &requestedName, MediaType type, const QString &prefix, const QString &extension)
{
    if (requestedName.isEmpty())
        return generateFileName(prefix, defaultLocation(type), extension);

    QString path = requestedName;

    if (QFileInfo(path).isRelative())
        path = defaultLocation(type).absoluteFilePath(path);

    if (QFileInfo(path).isDir())
        return generateFileName(prefix, QDir(path), extension);

    if (!path.endsWith(extension))
        path.append(QString(QLatin1String(".%1")).arg(extension));

    return path;

}

QString Camera::generateFileName(const QString &prefix, const QDir &dir, const QString &extension)
{
    QMutexLocker lock(&m_mutex);

    const QString lastMediaKey = dir.absolutePath() + QLatin1Char(' ') + prefix + QLatin1Char(' ') + extension;
    qint64 lastMediaIndex = m_lastUsedIndex.value(lastMediaKey, 0);

    if (lastMediaIndex == 0) {
        // first run, find the maximum media number during the fist capture
        const auto list = dir.entryList(QStringList() << QString(QLatin1String("%1*.%2")).arg(prefix).arg(extension));
        for (const QString &fileName : list) {
            const qint64 mediaIndex = fileName.midRef(prefix.length(), fileName.size() - prefix.length() - extension.length() - 1).toInt();
            lastMediaIndex = qMax(lastMediaIndex, mediaIndex);
        }
    }

    // don't just rely on cached lastMediaIndex value,
    // someone else may create a file after camera started
    while (true) {
        const QString name = QString(QLatin1String("%1%2.%3")).arg(prefix)
                                 .arg(lastMediaIndex + 1, 8, 10, QLatin1Char('0'))
                                 .arg(extension);

        const QString path = dir.absoluteFilePath(name);
        if (!QFileInfo::exists(path)) {
            m_lastUsedIndex[lastMediaKey] = lastMediaIndex + 1;
            return path;
        }

        lastMediaIndex++;
    }

    return QString();

}

QDir Camera::defaultLocation(MediaType type)
{
    QStringList dirCandidates;

    dirCandidates << m_customLocations.value(type);

    switch (type) {
    case Movies:
        dirCandidates << QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
        break;
    case Music:
        dirCandidates << QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
        break;
    case Pictures:
        dirCandidates << QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    default:
        break;
    }

    dirCandidates << QDir::homePath();
    dirCandidates << QDir::currentPath();
    dirCandidates << QDir::tempPath();

    for (const QString &path : qAsConst(dirCandidates)) {
        if (QFileInfo(path).isWritable())
            return QDir(path);
    }

    return QDir();

}

QString Camera::path() const
{
    return m_path;
}

void Camera::setPath(const QString &newPath)
{
    if (m_path == newPath)
        return;
    m_path = newPath;
    emit pathChanged();
}

int Camera::state() const
{
    return m_state;
}

void Camera::setState(int newState)
{
    if (m_state == newState)
        return;
    m_state = newState;
    emit stateChanged();
}

QImage Camera::image() const
{
    return m_image;
}

void Camera::setImage(const QImage &newImage)
{
    if (m_image == newImage)
        return;
    m_image = newImage;
    emit imageChanged();
}

void Camera::play()
{
    if (!this->isRunning()) {
        m_flag = true;
        this->start();
    }
}

void Camera::stop()
{
    m_flag = false;
    this->wait(500);
    this->quit();
}

void Camera::takeImage()
{
    QFile tmpFile(m_path);
    if (!tmpFile.exists()) {
        qDebug() << "You should specify where to save the photo";
        return;
    }
    QString fileName = generateFileName(m_path,
                                        MediaType::Pictures,
                                        QLatin1String("IMG_"),
                                        QLatin1String("JPG"));
    QTransform transform;
    //transform.rotate(270);

    QByteArray ba;
    QBuffer buffer(&ba);
    buffer.open(QIODevice::WriteOnly);
    m_image.transformed(transform, Qt::SmoothTransformation).save(&buffer, "JPG", 100);

    QFile file(fileName);
    if (file.open(QFile::WriteOnly)) {
        if (file.write(ba) == ba.size()) {
            emit imageCapture(fileName);
        } else {
            qDebug() << "imageCaptureError";
        }
    } else {
        qDebug() << "imageCaptureError";
    }

}

int Camera::bufferCount() const
{
    return m_bufferCount;
}

void Camera::setBufferCount(int newBufferCount)
{
    if (m_bufferCount == newBufferCount)
        return;
    m_bufferCount = newBufferCount;
    emit bufferCountChanged();
}

QSize Camera::resolution() const
{
    return m_resolution;
}

void Camera::setResolution(const QSize &newResolution)
{
    if (m_resolution == newResolution)
        return;
    m_resolution = newResolution;
    emit resolutionChanged();
}

QString Camera::deviceId() const
{
    return m_deviceId;
}

void Camera::setDeviceId(const QString &newDeviceId)
{
    if (m_deviceId == newDeviceId)
        return;
    m_deviceId = newDeviceId;
    emit deviceIdChanged();
}

