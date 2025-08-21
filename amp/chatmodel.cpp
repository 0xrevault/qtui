/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         chatmodel.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-11
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "chatmodel.h"
#include <QDebug>
#include <QIODevice>
#include <QFile>
#include <QProcess>
#include <QCoreApplication>

ChatModel::ChatModel(QObject *parent)
    : QAbstractListModel(parent), m_state(State::OffLine), m_lastMessage("最近无聊天内容")
{
    // m33 init
    QFile file("/dev/ttyRPMSG0");
    if (!file.exists()) {
        QString cmd = QCoreApplication::applicationDirPath() + "/resource/OpenAMP_TTY_echo/fw_cortex_m33.sh";
        QProcess pro;
        pro.start(cmd);
        pro.waitForFinished(3000);
    }
    m_serialPort = new QSerialPort(this);
    connect(m_serialPort, SIGNAL(readyRead()),
            this, SLOT(serialPortReadyRead()));
}

ChatModel::~ChatModel()
{
    m_chatMessages.clear();
    Q_EMIT countChanged();
}

int ChatModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    Q_UNUSED(parent);
    return m_chatMessages.count();
}

QVariant ChatModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    switch (role) {
    case MessageRole:
        return QVariant::fromValue(static_cast<QObject *>(m_chatMessages.value(index.row())));
    }

    return QVariant();
}

QHash<int, QByteArray> ChatModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[MessageRole] = "chatMessage";
    return roles;
}

QString ChatModel::lastMessage() const
{
    return m_lastMessage;
}

void ChatModel::setLastMessage(const QString &newLastMessage)
{
    if (m_lastMessage == newLastMessage)
        return;
    m_lastMessage = newLastMessage;
    emit lastMessageChanged();
}

int ChatModel::state() const
{
    return m_state;
}

void ChatModel::setState(int newState)
{
    if (m_state == newState)
        return;
    m_state = newState;
    emit stateChanged();
}

int ChatModel::count() const
{
    return rowCount();
}

void ChatModel::clear()
{
    beginRemoveRows(QModelIndex(), 0, m_chatMessages.count() - 1);
    endRemoveRows();
    m_chatMessages.clear();
    Q_EMIT countChanged();
    setLastMessage("最近无聊天内容");
}

void ChatModel::serialPortReadyRead()
{
    qDebug() << "receive data!";
    QByteArray buf = m_serialPort->readAll();
    ChatMessage *message = new ChatMessage;
    message->setUser(User::OtherDevice);
    message->setMessage(buf);
    beginInsertRows(QModelIndex(), m_chatMessages.count(), m_chatMessages.count());
    m_chatMessages.append(message);
    endInsertRows();
    Q_EMIT countChanged();
    setLastMessage(buf);
}

void ChatModel::sendMessage(const QString &msg)
{
    if (m_serialPort->portName().isNull()) {
        qDebug() << "Which serial port to open is not set!";
    }
    if (m_serialPort->isOpen()) {
        QByteArray data = msg.toUtf8();
        m_serialPort->write(data);
        qDebug() << "successfully send!";
        ChatMessage *message = new ChatMessage;
        message->setUser(User::ARM64);
        message->setMessage(msg);
        beginInsertRows(QModelIndex(), m_chatMessages.count(), m_chatMessages.count());
        m_chatMessages.append(message);
        endInsertRows();
        Q_EMIT countChanged();
        setLastMessage(msg);
    } else {
        qDebug() << "Serial port is not open!";
    }
}

QString ChatModel::portName() const
{
    return m_portName;
}

void ChatModel::setPortName(const QString &newPortName)
{
    if (m_portName == newPortName)
        return;
    m_portName = newPortName;
    emit portNameChanged();
    if (m_serialPort->isOpen()) {
        m_serialPort->close();
    }
    m_serialPort->setPortName(m_portName);
    if (!m_serialPort->open(QIODevice::ReadWrite)) {
        qDebug() << "Failed to open" << m_portName;
        setState(State::OffLine);
    } else {
        setState(State::Online);
        qDebug() << "Succeeded to open" << m_portName;
    }
}
