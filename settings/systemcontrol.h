/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         systemcontrol.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-26
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef SYSTEMCONTROL_H
#define SYSTEMCONTROL_H

#include <QObject>
#include <QString>
#include <QFileSystemWatcher>
class SystemControl : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool applicationAnimation READ applicationAnimation WRITE setApplicationAnimation NOTIFY applicationAnimationChanged FINAL)
    Q_PROPERTY(QString memoryInfoMation READ memoryInfoMation WRITE setMemoryInfoMation  NOTIFY memoryInfoMationChanged FINAL)
public:
    explicit SystemControl(QObject *parent = nullptr);

    bool applicationAnimation() const;
    void setApplicationAnimation(bool newApplicationAnimation);

    QString memoryInfoMation() const;
    void setMemoryInfoMation(const QString &newMemoryInfoMation);
    Q_INVOKABLE void systemReboot();
    Q_INVOKABLE void uiKillall();
    Q_INVOKABLE void systemPoweroff();

signals:
    void applicationAnimationChanged();
    void memoryInfoChanged();

    void memoryInfoMationChanged();

private:
    bool m_applicationAnimation;
    QFileSystemWatcher * m_systemuiConfSystemWatcher;
    QString m_memoryInfoMation;

public slots:
    void onSystemuiconfChanged();
    void checkMemoryInfo();
};

#endif // SYSTEMCONTROL_H
