/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         generatecoverplan.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2025-03-12
* @link          http://www.alientek.com
*******************************************************************/
#ifndef GENERATECOVERPLAN_H
#define GENERATECOVERPLAN_H

#include <QObject>
#include <QThread>
#include <QProcess>

class GenerateCoverplan : public QThread
{
    Q_OBJECT
    Q_PROPERTY(QString cmd READ cmd WRITE setCmd NOTIFY cmdChanged)
public:
    explicit GenerateCoverplan(QObject *parent = nullptr);
    QString cmd() const;
    void setCmd(const QString &newCmd);

signals:
    void cmdChanged();

private:
    QString m_cmd;
    void run() override;
};

#endif // GENERATECOVERPLAN_H
