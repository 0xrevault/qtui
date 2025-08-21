/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         languagemanager.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-05-28
* @link          http://www.alientek.com
* @LICENSE       GPLV3
*******************************************************************/
#include "languagemanager.h"
#include  <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QIODevice>
#include <QFileInfo>

// example: /opt/Qt/5.15.2/gcc_64/bin/linguist $(programer_Name)_zh_CN.ts
LanguageManager::LanguageManager(QQmlEngine *engine, QString appName, QObject *parent)
    : QObject{parent}, m_engine(engine), m_appName(appName), m_language(-1)
{
    m_translator = new QTranslator(this);
    QCoreApplication::installTranslator(m_translator);
    m_languageSystemWatcher = new QFileSystemWatcher(this);
    QFile file;
    if (m_appName == "systemui")
        file.setFileName(QCoreApplication::applicationDirPath() + "/src/apps/resource/language.conf");
    else
        file.setFileName(QCoreApplication::applicationDirPath() + "/resource/language.conf");

    if (file.exists()) {
        m_languageSystemWatcher->addPath(file.fileName());
        connect(m_languageSystemWatcher, SIGNAL(fileChanged(QString)), this, SLOT(onlanguageConfChanged(QString)));
        onlanguageConfChanged(file.fileName());
    }
}

bool LanguageManager::changeLanguage(const QString &languageCode)
{
    if (languageCode != "zh_CN" && languageCode != "en_US") {
        qDebug() << "The available language codes are \"zh_CN\" (Simplified Chinese, China) and \"en_US\" (American English, United States).";
        return false;
    }
    if (m_translator->load(QString(":/i18n/" +m_appName + "_%1.qm").arg(languageCode))) {
        m_engine->retranslate();
        qDebug() << "Successfully loaded " + languageCode + "!";
        emit languageChanged();
        return true;
    }
    qWarning() << "Failed to load translation file for language:" << languageCode;
    return false;
}

int LanguageManager::language() const
{
    return m_language;
}

void LanguageManager::setLanguage(int newLanguage)
{
    if (newLanguage > en_US && newLanguage < zh_CN) {
        qWarning() << "The value " << newLanguage << " is within the Languages enum range.";
        return;
    }
    // if (newLanguage == 1)
    //     changeLanguage("zh_CN");
    // else
    //     changeLanguage("en_US");
    if (m_language == newLanguage)
        return;
    QFile file;
    if (m_appName == "systemui")
        file.setFileName(QCoreApplication::applicationDirPath() + "/src/apps/resource/language.conf");
    else
        file.setFileName(QCoreApplication::applicationDirPath() + "/resource/language.conf");
    if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        return;
    }
    if (newLanguage == 1) {
        file.write("zh_CN");
    } else
        file.write("en_US");
    file.close();
    m_language = newLanguage;
    emit languageChanged();
}

void LanguageManager::onlanguageConfChanged(QString fileName)
{

    QFileInfo fileInfo(fileName);
    QString baseName = fileInfo.fileName();
    if (baseName != "language.conf")
        return;
    QFile file(fileName);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString str = file.readLine().simplified();
        changeLanguage(str.simplified());

        if (str == "en_US" && m_language != 2) {
            m_language = 2;
            emit languageChanged();
        }
        if (str == "zh_CN" && m_language != 1) {
            m_language = 1;
            emit languageChanged();
        }

        // if (str == "en_US")
        //     setLanguage(2);
        // if (str == "zh_CN")
        //     setLanguage(1);
    }
}
