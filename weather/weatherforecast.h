/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   weather
* @brief         weatherforecast.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-03-30
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef WEATHERFORECAST_H
#define WEATHERFORECAST_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QTextCodec>
#include <QTimer>
#include <QNetworkConfigurationManager>

class WeatherInfo
{
public:
    explicit WeatherInfo(QString d, QString t, QString l, QString h);
    QString date();
    QString type();
    QString lowTemp();
    QString highTemp();

public:
    QString m_date;
    QString m_type;
    QString m_lowTemp;
    QString m_highTemp;
};

class WeatherForecast : public QObject
{
    Q_OBJECT
public:
    explicit WeatherForecast(QObject *parent = nullptr);

    QString currentTemperature() const;
    QString currentWeatherType() const;
    int tempMin() const;
    int tempMax() const;
    int interval() const;

    void setInterval(int minutes);
    Q_INVOKABLE void getWeatherForecast();
    Q_INVOKABLE QString weatherDate(const int &index);
    Q_INVOKABLE QString weatherType(const int &index);
    Q_INVOKABLE QString weatherlowTemp(const int &index);
    Q_INVOKABLE QString weatherhighTemp(const int &index);

    Q_PROPERTY(int tempMin READ tempMin NOTIFY tempMinChanged)
    Q_PROPERTY(int tempMax READ tempMax NOTIFY tempMaxChanged)
    Q_PROPERTY(QString currentTemperature READ currentTemperature NOTIFY currentTemperatureChanged)
    Q_PROPERTY(QString currentWeatherType READ currentWeatherType NOTIFY currentWeatherTypeChanged)
    Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY intervalChanged)

signals:
    void weatherInfoChanged();
    void currentTemperatureChanged();
    void currentWeatherTypeChanged();
    void tempMinChanged();
    void tempMaxChanged();
    void intervalChanged();

private:
    QVector<WeatherInfo> weatherVector;
    QString m_currentTemperature;
    QString m_currentWeatherType;
    int m_tempMin;
    int m_tempMax;
    QTimer *m_timer;
    int m_interval;
    QNetworkConfigurationManager *m_networkConfigurationManager;

private slots:
    void response();
    void timerTimeOut();
    void onlineStateChanged(bool);

};

#endif // WEATHERFORECAST_H
