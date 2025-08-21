/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   server
* @brief         systemuicommonapi.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2023-10-31
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef SYSTEMUICOMMONAPISERVER_H
#define SYSTEMUICOMMONAPISERVER_H

#include <QRemoteObjectHost>
#include <QTimer>
#include <QImage>
#include "rep_systemuicommonapi_source.h"
#include "launchintent.h"
#include <QByteArray>
#include <QMap>
#include <QVariant>


typedef QMap<QString, QVariant> SystemUIMessages;

class Properties {
public:
    static const QString appName;
    static const QString appState;
    static const QString appStateImage;

    static const QString appX;
    static const QString appY;
    static const QString appIconWidth;
    static const QString appIconHeight;
    static const QString appIconPath;
    static const QString pageIndex;
    static const QString command;
    static const QString launchMode;
};

class SystemUICommonApiServer : public SystemUICommonApiSource
{
    Q_OBJECT
    Q_ENUMS(Command)
    Q_ENUMS(AppState)
    Q_ENUMS(LaunchMode)
public:
    explicit SystemUICommonApiServer(QObject * parent = nullptr);
    Q_INVOKABLE void launchProperties(qreal x, qreal y, qreal iconWidth, qreal iconHeight, QString iconPath, int currtentPage, int launchMode);
    Q_PROPERTY(QString currtentLauchAppName READ currtentLauchAppName WRITE setCurrtentLauchAppName NOTIFY currtentLauchAppNameChanged)
    Q_PROPERTY(bool appIsRunning READ appIsRunning WRITE setAppIsRunning NOTIFY appIsRunningChanged)
    Q_PROPERTY(bool coldLaunch READ coldLaunch WRITE setColdLaunch NOTIFY coldLaunchChanged)
    Q_PROPERTY(bool currtentAppIsActive READ currtentAppIsActive WRITE setCurrtentAppIsActive NOTIFY currtentAppIsActiveChanged)

    QString currtentLauchAppName();
    void setCurrtentLauchAppName(const QString &appName);

    bool appIsRunning() const;
    void setAppIsRunning(bool newAppIsRunning);

    bool currtentAppIsActive() const;
    void setCurrtentAppIsActive(bool newCurrtentAppIsActive);

    bool coldLaunch() const;
    void setColdLaunch(bool newColdLaunch);

    enum Command {
        UnknowCommand,
        Show,
        Quit,
        Hide
    };

    enum AppState {
        UnknowState = 0,
        Background,
        Active,
        WhichState
    };

    enum LaunchMode {
        UnknowMode = 0,
        ClickIcon,
        AppSwitcher
    };

    Properties pros;
    // Received messages from the APP
    SystemUIMessages m_receiveAppMessagesCache;

    // The properties of the app when it is clicked
    SystemUIMessages m_propertiesCache;

    void updateReceiveAppMessages(SystemUIMessages messages);

public slots:
    virtual void onServerVariant(const QByteArray &data) override;
    void quitNotification(QString appName);
    void launchApp(const QString &appName);
private slots:
    void timeOutDetectIsAlreadyRunning();
    void noAppFile();
    void onAppExitHandler(QProcess *process, int exitValue);
private:
    QRemoteObjectHost * m_remoteObjectHost = nullptr;
    bool m_appIsRunning;
    QString m_currtentLauchAppName;
    QTimer *detectAppIsAlreadyRunningTimer;
    bool m_currtentAppIsActive;
    LaunchIntent *launchIntent;
    bool m_coldLaunch = true;

    void updateReceiveAppMessages(const QString &name, const QVariant& value);

signals:
    void appAsktoHideOrShow(int action);
    void currtentLauchAppNameChanged();
    void appIsRunningChanged();
    void currtentAppIsActiveChanged();
    void coldLaunchChanged();
    void appIsUnistalled();
    void appStateImageChanged(QString appName, QVariant image);
    void appCrashHandler(QString appName);
private:
    QByteArray serializeSystemUIMessages(const SystemUIMessages &messages);
    SystemUIMessages deserializeSystemUIMessages(const QByteArray& data);
};

#endif // SYSTEMUICOMMONAPISERVER_H
