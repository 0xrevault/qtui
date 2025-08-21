/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         chatmodel.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-11
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef CHATMODEL_H
#define CHATMODEL_H

#include "chatmessage.h"
#include <QAbstractListModel>
#include <QSerialPort>
#include <QVector>
#include <QHash>
#include <QByteArray>

class ChatModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(User)
    Q_ENUMS(State)
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QString lastMessage READ lastMessage WRITE setLastMessage NOTIFY lastMessageChanged)
public:
    enum User {
        OtherDevice = 1,
        ARM64
    };

    enum State {
        OffLine = 1,
        Online
    };
    explicit ChatModel(QObject *parent = nullptr);
    ~ChatModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    enum ItemRoles {
        MessageRole = Qt::UserRole + 1
    };

    QString portName() const;
    void setPortName(const QString &newPortName);

    int count() const;
    Q_INVOKABLE void clear();

    int state() const;
    void setState(int newState);
    QString lastMessage() const;
    void setLastMessage(const QString &newLastMessage);

signals:
    void portNameChanged();
    void countChanged();
    void stateChanged();
    void lastMessageChanged();

private:
    QHash<int, QByteArray> roleNames() const;
    QVector<ChatMessage *> m_chatMessages;
    QSerialPort *m_serialPort;
    QString m_portName;
    int m_state;
    QString m_lastMessage;

private slots:
    void serialPortReadyRead();
public slots:
    void sendMessage(const QString &msg);

};
#endif // CHATMODEL_H
