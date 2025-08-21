/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         chatmessage.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-12
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef CHATMESSAGE_H
#define CHATMESSAGE_H

#include <QObject>

class ChatMessage : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int user READ user WRITE setUser NOTIFY userChanged)
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
public:
    explicit ChatMessage(QObject *parent = nullptr);

    int user() const;
    void setUser(int newUser);

    QString message() const;
    void setMessage(const QString &newMessage);

private:
    int m_user;
    QString m_message;

signals:
    void userChanged();
    void messageChanged();
};

#endif // CHATMESSAGE_H
