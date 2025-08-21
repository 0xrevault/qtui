#include "generatecoverplan.h"

GenerateCoverplan::GenerateCoverplan(QObject *parent)
    : QThread{parent}
{}

QString GenerateCoverplan::cmd() const
{
    return m_cmd;
}

void GenerateCoverplan::setCmd(const QString &newCmd)
{
    if (m_cmd == newCmd)
        return;
    m_cmd = newCmd;
    this->start();
    emit cmdChanged();
}

void GenerateCoverplan::run()
{
    QProcess pro;
    pro.start(m_cmd);
    pro.waitForFinished(10000);
    this->deleteLater();
}
