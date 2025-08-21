/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   weather
* @brief         weatherforecast.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-03-30
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "weatherforecast.h"

WeatherForecast::WeatherForecast(QObject *parent) : QObject(parent),
    m_currentTemperature("--"),
    m_currentWeatherType("--"),
    m_tempMin(-1000),
    m_tempMax(1000),
    m_interval(30)
{
    m_timer =  new QTimer(this);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(timerTimeOut()));
    m_networkConfigurationManager =  new QNetworkConfigurationManager(this);
    connect(m_networkConfigurationManager, SIGNAL(onlineStateChanged(bool)), this, SLOT(onlineStateChanged(bool)));
}

QString WeatherForecast::currentTemperature() const
{
    return m_currentTemperature;
}

QString WeatherForecast::currentWeatherType() const
{
    return m_currentWeatherType;
}

int WeatherForecast::tempMin() const
{
    return m_tempMin;
}

int WeatherForecast::tempMax() const
{
    return m_tempMax;
}

int WeatherForecast::interval() const
{
    return m_interval;
}

void WeatherForecast::setInterval(int minutes)
{
    m_interval = minutes;
    emit intervalChanged();
    m_timer->stop();
    m_timer->start(m_interval * 1000 * 60);
}

void WeatherForecast::getWeatherForecast()
{
    QNetworkRequest  ipQueryNRequest;
    QNetworkAccessManager *m_networkAccessManager = new  QNetworkAccessManager();
    connect(m_networkAccessManager, &QNetworkAccessManager::finished, m_networkAccessManager, &QNetworkAccessManager::deleteLater);
    QSslConfiguration config;
    config.setPeerVerifyMode(QSslSocket::VerifyNone);
    config.setProtocol(QSsl::TlsV1SslV3);
    ipQueryNRequest.setSslConfiguration(config);
    ipQueryNRequest.setUrl(QUrl("https://tianqi.2345.com/"));
    QNetworkReply *reply = m_networkAccessManager->get(ipQueryNRequest);
    connect(reply, SIGNAL(finished()), this, SLOT(response()));
}

QString WeatherForecast::weatherDate(const int &index)
{
    if (weatherVector.length() >= 8)
        return weatherVector[index].date();
    else
        return "--";
}

QString WeatherForecast::weatherType(const int &index)
{
    if (weatherVector.length() >= 8)
        return weatherVector[index].type();
    else
        return "--";
}

QString WeatherForecast::weatherlowTemp(const int &index)
{
    if (weatherVector.length() >= 8)
        return weatherVector[index].lowTemp();
    else
        return "--";
}

QString WeatherForecast::weatherhighTemp(const int &index)
{
    if (weatherVector.length() >= 8)
        return weatherVector[index].highTemp();
    else
        return "--";
}

void WeatherForecast::response()
{
    QNetworkReply *reply = (QNetworkReply*)sender();
    QByteArray ba = reply->readAll();
    reply->deleteLater();

    QTextCodec* textCode = QTextCodec::codecForName("UTF-8");
    assert(textCode != nullptr);
    QString str = textCode->toUnicode(ba);
    QStringList strList = str.split("\n");
    QRegularExpression reg;
    QRegularExpressionMatch match;

    QString date;
    QString type;
    QString lowTemp;
    QString highTemp;

    foreach (QString tmpStr, strList) {

        reg.setPattern("banner-whether-desc1\">(.*?)°</span>");
        match = reg.match(tmpStr, 0);
        if (match.hasMatch()) {
            m_currentTemperature = match.captured(1).simplified();
            emit currentTemperatureChanged();
        }

        reg.setPattern("div class=\"date\" data-txt=\"(.*?)\"");
        match = reg.match(tmpStr, 0);
        if (match.hasMatch()) {
            date = match.captured(1).simplified();
        }

        reg.setPattern("banner-right-con-list-status\">(.*?)</div>");
        match = reg.match(tmpStr, 0);
        if (match.hasMatch()) {
            type = match.captured(1).simplified();
        }

        reg.setPattern("banner-right-con-list-temp\">(.*?)~(.*?)°</div>");
        match = reg.match(tmpStr, 0);
        if (match.hasMatch()) {
            lowTemp = match.captured(1).simplified();
            highTemp = match.captured(2).simplified();
            if (m_tempMin == -1000)
                m_tempMin = lowTemp.toInt();
            if (m_tempMin > lowTemp.toInt())
                m_tempMin = lowTemp.toInt();

            if (m_tempMax == 1000)
                m_tempMax = highTemp.toInt();
            if (m_tempMax < highTemp.toInt())
                m_tempMax = highTemp.toInt();

            WeatherInfo info(date, type, lowTemp, highTemp);
            weatherVector.append(info);
            if (weatherVector.length() >= 8) {
                emit tempMinChanged();
                emit tempMaxChanged();
                emit weatherInfoChanged();
                m_currentWeatherType = weatherVector[1].m_type;
                emit currentWeatherTypeChanged();
            }
        }
    }
}

void WeatherForecast::timerTimeOut()
{
    getWeatherForecast();
}

void WeatherForecast::onlineStateChanged(bool oneline)
{
    if (oneline)
        getWeatherForecast();
}

WeatherInfo::WeatherInfo(QString d, QString t, QString l, QString h)
{
    m_date = d;
    m_type = t;
    m_lowTemp = l;
    m_highTemp = h;
}

QString WeatherInfo::date()
{
    return m_date;
}

QString WeatherInfo::type()
{
    return m_type;
}

QString WeatherInfo::lowTemp()
{
    return m_lowTemp;
}

QString WeatherInfo::highTemp()
{
    return m_highTemp;
}
