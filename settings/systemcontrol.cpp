/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         systemcontrol.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-26
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "systemcontrol.h"
#include <QFile>
#include <QDebug>
#include <QCoreApplication>
#include <QProcess>
SystemControl::SystemControl(QObject *parent)
    : QObject{parent}
{
    m_systemuiConfSystemWatcher = new QFileSystemWatcher(this);
    QFile file(QCoreApplication::applicationDirPath() + "/resource/systemui.conf");
    if (file.exists()) {
        m_systemuiConfSystemWatcher->addPath(file.fileName());
        connect(m_systemuiConfSystemWatcher, SIGNAL(fileChanged(QString)), this, SLOT(onSystemuiconfChanged()));
        //onSystemuiconfChanged();
    }
}

bool SystemControl::applicationAnimation() const
{
    return m_applicationAnimation;
}

void SystemControl::setApplicationAnimation(bool newApplicationAnimation)
{
    if (m_applicationAnimation == newApplicationAnimation)
        return;
    m_applicationAnimation = newApplicationAnimation;

    QFile file(m_systemuiConfSystemWatcher->files()[0]);
    if (file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        QString str = file.readAll();
        QString writeContent;
        foreach (QString tmpStr, str.split("\n")) {
            if (tmpStr.contains("application-animation=false") && m_applicationAnimation) {
                writeContent += "application-animation=true\n";
            } else if (tmpStr.contains("application-animation=true") && !m_applicationAnimation) {
                writeContent += "application-animation=false\n";
            } else {
                if (tmpStr.simplified() != "" )
                    writeContent += tmpStr + "\n";
            }
            file.resize(0);
            file.write(writeContent.toUtf8());
        }
        file.close();
    }
    emit applicationAnimationChanged();
}

QString SystemControl::memoryInfoMation() const
{
    return m_memoryInfoMation;
}

void SystemControl::setMemoryInfoMation(const QString &newMemoryInfoMation)
{
    if (m_memoryInfoMation == newMemoryInfoMation)
        return;
    m_memoryInfoMation = newMemoryInfoMation;
    emit memoryInfoMationChanged();
}

void SystemControl::systemReboot()
{
    system("reboot");
}

void SystemControl::uiKillall()
{
    system("killall systemui; killall /opt/ui/src/apps/*");
}

void SystemControl::systemPoweroff()
{
   system("poweroff");
}

void SystemControl::onSystemuiconfChanged() {
    QFile file(m_systemuiConfSystemWatcher->files()[0]);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString str = file.readAll();
        if (str.contains("application-animation=false"))
            setApplicationAnimation(false);
        else
            setApplicationAnimation(true);
        file.close();
    }
}

void SystemControl::checkMemoryInfo()
{
    QProcess pro;
    pro.start(QCoreApplication::applicationDirPath() + "/resource/shell/mmc1_total.sh");
    pro.waitForFinished();

    QString info;
    info = "eMMC:" + pro.readAll().simplified();
    pro.start(QCoreApplication::applicationDirPath() + "/resource/shell/memory_total.sh");
    pro.waitForFinished();
    info += " DDR:" + pro.readAll().simplified() + "B";
    setMemoryInfoMation(info);
}
