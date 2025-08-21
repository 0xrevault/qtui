/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         instructionsfileread.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-18
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef INSTRUCTIONSFILEREAD_H
#define INSTRUCTIONSFILEREAD_H

#include <QObject>
#include <QFile>

class InstructionsFileRead : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString instructionsContent READ instructionsContent WRITE setInstructionsContent NOTIFY instructionsContentChanged)
public:
    explicit InstructionsFileRead(QObject *parent = nullptr);
    Q_INVOKABLE void readInstructions();
    QString instructionsContent() const;
    void setInstructionsContent(const QString &newInstructionsContent);

signals:
    void instructionsContentChanged();

private:
    QString m_instructionsContent;
};

#endif // INSTRUCTIONSFILEREAD_H
