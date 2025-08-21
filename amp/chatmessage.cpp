/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         chatmessage.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "chatmessage.h"

ChatMessage::ChatMessage(QObject *parent)
    : QObject{parent}, m_user(0), m_message("")
{}

int ChatMessage::user() const
{
    return m_user;
}

void ChatMessage::setUser(int newUser)
{
    if (m_user == newUser)
        return;
    m_user = newUser;
    emit userChanged();
}

QString ChatMessage::message() const
{
    return m_message;
}

void ChatMessage::setMessage(const QString &newMessage)
{
    if (m_message == newMessage)
        return;
    m_message = newMessage;
    emit messageChanged();
}
