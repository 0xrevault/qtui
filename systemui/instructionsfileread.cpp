/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         instructionsfileread.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-18
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "instructionsfileread.h"
#include <QCoreApplication>
#include <QIODevice>
#include <QDebug>

void InstructionsFileRead::readInstructions()
{
    QFile file(QCoreApplication::applicationDirPath() + "/src/apps/resource/instructions/instructions.txt");
    if (file.exists()) {
        if (file.open(QIODevice::ReadOnly)) {
            QString str = file.readAll();
            setInstructionsContent(str.toUtf8());
            file.close();
        } else {
            qDebug() << "/src/apps/resource/instructions/instructions.txt does not exists!";
        }
    }
}

InstructionsFileRead::InstructionsFileRead(QObject *parent)
    : QObject{parent}
{
}

QString InstructionsFileRead::instructionsContent() const
{
    return m_instructionsContent;
}

void InstructionsFileRead::setInstructionsContent(const QString &newInstructionsContent)
{
    if (m_instructionsContent == newInstructionsContent)
        return;
    m_instructionsContent = newInstructionsContent;
    emit instructionsContentChanged();
}
