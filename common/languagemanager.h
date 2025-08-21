/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         languagemanager.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-05-28
* @link          http://www.alientek.com
* @LICENSE       GPLV3
*******************************************************************/
#ifndef LANGUAGEMANAGER_H
#define LANGUAGEMANAGER_H
#include <QObject>
#include <QTranslator>
#include <QQmlEngine>
#include <QString>
#include <QFileSystemWatcher>

class LanguageManager : public QObject
{
    Q_OBJECT
    Q_ENUMS(Languages)
    Q_PROPERTY(int language READ language WRITE setLanguage NOTIFY languageChanged)
public:
    explicit LanguageManager(QQmlEngine *engine,  QString appName, QObject *parent = nullptr);
    Q_INVOKABLE bool changeLanguage(const QString &languageCode);

    enum Languages {
        zh_CN = 1,
        en_US
    };
    int language() const;
    void setLanguage(int newLanguage);

signals:
    void languageChanged();

private:
    QTranslator *m_translator;
    QQmlEngine *m_engine = nullptr;
    QString m_appName;
    QFileSystemWatcher *m_languageSystemWatcher;
    int m_language;

private slots:
    void onlanguageConfChanged(QString fileName);
};

#endif // LANGUAGEMANAGER_H
