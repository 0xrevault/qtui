/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         wifiservicessettings.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-08-30
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef WIFISERVICESSETTINGS_H
#define WIFISERVICESSETTINGS_H

#include <QObject>
#include <QFile>
#include <QDir>
class WifiServicesSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath  NOTIFY pathChanged FINAL)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
    Q_PROPERTY(QString passphrase READ passphrase WRITE setPassphrase NOTIFY passphraseChanged FINAL)
    Q_PROPERTY(QString identy READ identy WRITE setIdenty NOTIFY identyChanged FINAL)
public:
    explicit WifiServicesSettings(QObject *parent = nullptr);


    QString path() const;
    void setPath(const QString &newPath);

    QString name() const;
    void setName(const QString &newName);

    QString passphrase() const;
    void setPassphrase(const QString &newPassphrase);

    QString identy() const;
    void setIdenty(const QString &newIdenty);

signals:
    void pathChanged();
    void nameChanged();
    void passphraseChanged();
    void identyChanged();

private:
    QString m_path;
    QString m_name;
    QString m_identy;
    QString m_passphrase;
    QFile m_file1;
    QFile m_file2;

    bool deleteDirectory(const QString &path);

public slots:
    void remove();
    void writeServicesConfig();
};


#endif // WIFISERVICESSETTINGS_H
