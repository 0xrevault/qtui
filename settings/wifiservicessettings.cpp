/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         wifiservicessettings.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-08-30
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "wifiservicessettings.h"
#include <QDebug>
#include <QIODevice>

WifiServicesSettings::WifiServicesSettings(QObject *parent)
    : QObject{parent}
{}

QString WifiServicesSettings::path() const
{
    return m_path;
}

void WifiServicesSettings::setPath(const QString &newPath)
{
    if (m_path == newPath)
        return;
    QStringList stringList = newPath.split("/net/connman/service/");
    if (stringList.count() == 2) {
        m_file1.setFileName("/var/lib/connman/" + stringList[1]);
        setIdenty(stringList[1]);
    } else {
        qDebug() << "Can not set path";
        return;
    }
    m_path = newPath;
    emit pathChanged();
}

QString WifiServicesSettings::name() const
{
    return m_name;
}

void WifiServicesSettings::setName(const QString &newName)
{
    if (m_name == newName)
        return;

    //m_file2.setFileName("/var/lib/connman/" + newName + ".config");
    m_name = newName;
    emit nameChanged();
}

QString WifiServicesSettings::passphrase() const
{
    return m_passphrase;
}

void WifiServicesSettings::setPassphrase(const QString &newPassphrase)
{
    if (m_passphrase == newPassphrase)
        return;
    m_passphrase = newPassphrase;
    emit passphraseChanged();
}

QString WifiServicesSettings::identy() const
{
    return m_identy;
}

void WifiServicesSettings::setIdenty(const QString &newIdenty)
{
    if (m_identy == newIdenty)
        return;
    m_identy = newIdenty;
    m_file2.setFileName("/var/lib/connman/" + m_identy + ".config");
    emit identyChanged();
}

bool WifiServicesSettings::deleteDirectory(const QString &path)
{
    if (path.isEmpty()) {
        return false;
    }

    QDir dir(path);
    if(!dir.exists()) {
        return true;
    }

    dir.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot);
    QFileInfoList fileList = dir.entryInfoList();
    foreach (QFileInfo fi, fileList) {
        if (fi.isFile()) {
            fi.dir().remove(fi.fileName());
        }
        else {
            deleteDirectory(fi.absoluteFilePath());
        }
    }
    return dir.rmpath(dir.absolutePath());
}

void WifiServicesSettings::remove()
{
    deleteDirectory(m_file1.fileName());
    m_file2.remove();
}

void WifiServicesSettings::writeServicesConfig()
{
    if (m_name == "")
        return;
    if (m_identy == "")
        return;
    if (m_passphrase == "")
        return;
    if (m_file2.open(QIODevice::ReadWrite | QIODevice::Text)) {
        QString configContent = tr("[service_%1]\nType=wifi\n"
                                   "Name=%2\nPassphrase=%3").arg(m_identy)
                                    .arg(m_name).arg(m_passphrase) ;
        m_file2.write(configContent.toUtf8());
        m_file2.close();
    }
    system("sync");
}

