/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mediaplayer.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-11
* @link          http://www.alientek.com
*******************************************************************/
#include "mediaplayer.h"

MediaPlayer::MediaPlayer(QObject *parent) : QMediaPlayer{ parent }, m_mode(-1)
{
    QObject::connect(this, &MediaPlayer::stateChanged, [this](MediaPlayer::State m_state) {
        if (m_state == MediaPlayer::PlayingState && m_mode == Mode::PlayCameraMode) {
            ISPCtrolThread * m_iSPCtrolThread = new ISPCtrolThread(this);
            if (!m_iSPCtrolThread->isRunning())
                m_iSPCtrolThread->start();
            QObject::connect(m_iSPCtrolThread, SIGNAL(finished()), m_iSPCtrolThread, SLOT(deleteLater()));
        }

        if (m_state == MediaPlayer::StoppedState && m_mode == Mode::RecordMode) {
            QFile file(m_backupFileName);
            if (file.exists()) {
                FixVideoThread *m_fixVideoThread = new FixVideoThread(this);
                m_fixVideoThread->setVideoFile(m_vidoeFileName);
                m_fixVideoThread->setBackupFile(m_backupFileName);
                connect(m_fixVideoThread, SIGNAL(finished()), m_fixVideoThread, SLOT(deleteLater()));
                connect(m_fixVideoThread, SIGNAL(finished()), this, SIGNAL(videoFileChanged()));
            }
            setSource("");
            this->setMedia(QUrl());
        }

        if (m_state == MediaPlayer::StoppedState && m_mode == Mode::PlayVideoMode) {
            setSource("");
            this->setMedia(QUrl());
        }
    });
}

QString  MediaPlayer::source() const
{
    return m_source;
}

void MediaPlayer::setSource(const QString  &newSource)
{
    if (m_source == newSource)
        return;
    this->stop();
    m_source = newSource;
    updateMediaSource();
    emit sourceChanged();
}

QString MediaPlayer::path() const
{
    return m_path;
}

void MediaPlayer::setPath(const QString &newPath)
{
    if (m_path == newPath)
        return;
    m_path = newPath;
    updateMediaSource();
    emit pathChanged();
}

int MediaPlayer::mode() const
{
    return m_mode;
}

void MediaPlayer::setMode(int newMode)
{
    if (m_mode == newMode)
        return;
    m_mode = newMode;
    updateMediaSource();
    emit modeChanged();
}

QString MediaPlayer::generateFileName(const QString &requestedName, MediaType type, const QString &prefix, const QString &extension)
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

QString MediaPlayer::generateFileName(const QString &prefix, const QDir &dir, const QString &extension)
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

QDir MediaPlayer::defaultLocation(MediaType type)
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

void MediaPlayer::updateMediaSource()
{

    if (m_mode == Mode::RecordMode && m_source != "" &&  m_path != "") {
        m_vidoeFileName = generateFileName(m_path,
                                           MediaType::Movies,
                                           QLatin1String("video_"),
                                           QLatin1String("mp4"));
        m_source = tr(m_source.toStdString().c_str()).arg(m_vidoeFileName.toStdString().c_str());
        m_source = m_source.replace("cameravideos", "backupvideos");
        QString tmpString = m_vidoeFileName;
        m_backupFileName = tmpString.replace("cameravideos", "backupvideos");
        this->setMedia(QUrl(m_source));
    }

    if (m_mode == Mode::PlayCameraMode && m_source != "") {
        this->setMedia(QUrl(m_source));
    }

    if (m_mode == Mode::PlayVideoMode && m_source != "") {

        // has audio
        // QString playCmd = tr("gst-pipeline: uridecodebin uri=%1  name=decoder decoder. ! queue !"
        //               " waylandsink fullscreen=true decoder. ! queue ! audioconvert"
        //               " ! volume name=audiovolume ! autoaudiosink").arg(m_source);

        // no audio
        QString playCmd = tr("gst-pipeline: uridecodebin uri=%1 ! waylandsink fullscreen=true").arg(m_source);
        this->setMedia(QUrl(playCmd));
    }
}

