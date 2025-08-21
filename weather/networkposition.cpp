/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   location
* @brief         networkposition.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2025-01-16
*******************************************************************/
#include "networkposition.h"

NetworkPosition::NetworkPosition(QObject *parent) : QThread(parent),
    m_cityName("--"),
    m_position("--"),
    m_netWorkType("--"),
    m_area("--"),
    m_interval(30)
{
    m_timer = new QTimer(this);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(timerTimeOut()));
    m_networkConfigurationManager =  new QNetworkConfigurationManager(this);
    connect(m_networkConfigurationManager, SIGNAL(onlineStateChanged(bool)), this, SLOT(onlineStateChanged(bool)));
}

void NetworkPosition::refreshPosition()
{
    if (!this->isRunning())
        this->start();
}

QString NetworkPosition::cityName() const
{
    return m_cityName;
}

QString NetworkPosition::position() const
{
    return m_position;
}

QString NetworkPosition::netWorkType() const
{
    return m_netWorkType;
}

int NetworkPosition::interval() const
{
    return m_interval;
}

void NetworkPosition::setInterval(int minutes)
{
    m_interval = minutes;
    emit intervalChanged();
    m_timer->stop();
    m_timer->start(m_interval * 1000 * 60);
}

void NetworkPosition::getReply(const QString str)
{
    QRegularExpression reg;
    QRegularExpressionMatch match;

    reg.setPattern("prov\":\"(.*?)\",");
    match = reg.match(str, 0);
    if (match.hasMatch()) {
        m_cityName = match.captured(1).simplified();
        emit cityNameChanged();
    }
    reg.setPattern("city\":\"(.*?)\",");
    match = reg.match(str, 0);
    if (match.hasMatch()) {
        m_position = match.captured(1).simplified();
        emit positionChanged();
    }
    reg.setPattern("area\":\"(.*?)\",");
    match = reg.match(str, 0);
    if (match.hasMatch()) {
        m_area = match.captured(1).simplified();
        emit areaChanged();
    }
}

void NetworkPosition::onlineStateChanged(bool online)
{
    if (online)
        refreshPosition();
}

void NetworkPosition::timerTimeOut()
{
    refreshPosition();
}

void NetworkPosition::run()
{
    QProcess pro;
    pro.start("curl ifconfig.me");
    pro.waitForFinished(8000);
    QString str = pro.readAllStandardOutput();
    pro.start("curl http://ip9.com.cn/get?ip=" + str);
    pro.waitForFinished(5000);
    str = pro.readAllStandardOutput();
    getReply(str);
}

const QString &NetworkPosition::area() const
{
    return m_area;
}

void NetworkPosition::setArea(const QString &newArea)
{
    if (m_area == newArea)
        return;
    m_area = newArea;
    emit areaChanged();
}
