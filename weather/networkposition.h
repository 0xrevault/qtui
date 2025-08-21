/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   location
* @brief         networkposition.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2025-01-16
*******************************************************************/
#ifndef NETWORKPOSITION_H
#define NETWORKPOSITION_H

#include <QObject>
#include <QDebug>
#include <QTextCodec>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QNetworkConfigurationManager>
#include <QTimer>
#include <QThread>
#include <QProcess>

class NetworkPosition : public QThread
{
    Q_OBJECT
public:
    explicit NetworkPosition(QObject *parent = nullptr);
    Q_INVOKABLE void refreshPosition();

    QString cityName() const;
    QString position() const;
    QString netWorkType() const;
    int interval() const;

    void setInterval(int minutes);

    Q_PROPERTY(QString cityName READ cityName NOTIFY cityNameChanged)
    Q_PROPERTY(QString position READ position NOTIFY positionChanged)
    Q_PROPERTY(QString netWorkType READ netWorkType NOTIFY netWorkTypeChanged)
    Q_PROPERTY(QString area READ area WRITE setArea NOTIFY areaChanged)
    Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY intervalChanged)

    const QString &area() const;
    void setArea(const QString &newArea);

signals:
    void cityNameChanged();
    void positionChanged();
    void netWorkTypeChanged();
    void intervalChanged();

    void areaChanged();

private slots:
    void getReply(const QString str);
    void onlineStateChanged(bool);
    void timerTimeOut();
private:
    QString m_cityName;
    QString m_position;
    QString m_netWorkType;
    QString m_area;
    QNetworkConfigurationManager *m_networkConfigurationManager;
    QTimer *m_timer;
    int m_interval;

    void run() override;
};

#endif // NETWORKPOSITION_H
