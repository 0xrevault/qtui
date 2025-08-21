/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         fixvideothread.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-09
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef FIXVIDEOTHREAD_H
#define FIXVIDEOTHREAD_H

#include <QObject>
#include <QThread>

class FixVideoThread : public QThread
{
    Q_OBJECT
    Q_PROPERTY(QString videoFile READ videoFile WRITE setVideoFile NOTIFY videoFileChanged FINAL)
    Q_PROPERTY(QString backupFile READ backupFile WRITE setBackupFile NOTIFY backupFileChanged FINAL)
public:
    explicit FixVideoThread(QObject *parent = nullptr);

    QString videoFile() const;
    void setVideoFile(const QString &newVideoFile);

    QString backupFile() const;
    void setBackupFile(const QString &newBackupFile);

signals:
    void videoFileChanged();
    void backupFileChanged();

private:
    QString m_videoFile;
    QString m_backupFile;

    void run() override;
};

#endif // FIXVIDEOTHREAD_H
