/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   pcba
* @brief         pcbaListModel.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-04-10
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "pcbalistmodel.h"
#include <QDir>
#include <QDebug>
#include <QDirIterator>
#include <QDateTime>
#include <QTextCodec>
#include <QCoreApplication>

Pcba::Pcba(QString shell, QString title, QString processState, QString result, bool activate, bool manual) {
    m_shell = shell;
    m_title = title;
    m_processState = processState;
    m_result = result;
    m_activate = activate;
    m_manual = manual;
}

QString Pcba::getshell() const {
    return m_shell;
}

QString Pcba::gettitle() const {
    return m_title;
}

bool Pcba::getactivate() const
{
    return m_activate;
}

bool Pcba::getmanual() const
{
    return m_manual;
}

QString Pcba::getprocessState() const {
    return m_processState;
}

QString Pcba::getresult() const {
    return m_result;
}

void Pcba::settitle(QString title) {
    m_title = title;
}

void Pcba::setprocessState(QString processState)
{
    m_processState = processState;
}

void Pcba::setresult(QString result)
{
    m_result = result;
}

PcbaListModel::PcbaListModel(QObject *parent) : QAbstractListModel(parent) {
    m_currentIndex = -1;
    m_logfileIsReady = false;
    manualPro = new QProcess(this);
    QDir dir(QCoreApplication::applicationDirPath() + "/resource/pcba/.log");
    if (!dir.exists()) {
        dir.mkdir(dir.path());
    }
    QFile file("/etc/hostname");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString str =  file.readLine().simplified();
        add(QCoreApplication::applicationDirPath() + "/resource/pcba/" + str + ".cfg");
        file.close();
    }
}

int PcbaListModel::currentIndex() const {
    return m_currentIndex;
}

QString PcbaListModel::manualLog() const
{
    return m_manualLog;
}

int PcbaListModel::rowCount(const QModelIndex & parent) const {
    Q_UNUSED(parent);
    return pcbaData.count();
}

QVariant PcbaListModel::data(const QModelIndex & index, int role) const {
    if (index.row() < 0 || index.row() >= pcbaData.count())
        return QVariant();
    const Pcba &s = pcbaData.at(index.row());
    switch (role) {
    case shellRole:
        return s.getshell();
    case titleRole:
        return s.gettitle();
    case processStateRole:
        return s.getprocessState();
    case resultRole:
        return s.getresult();
    case manualRole:
        return s.getmanual();
    default:
        return QVariant();
    }
}

int PcbaListModel::randomIndex()
{
    int tmp;
    srand(time(NULL));
    do {
        tmp = qrand() % pcbaData.count();
    } while (tmp == m_currentIndex);
    setCurrentIndex(tmp);
    return tmp;
}

QString PcbaListModel::getcurrentTitle() const
{
    return pcbaData.at(m_currentIndex).gettitle();
}

QString PcbaListModel::getcurrentShell() const {
    return pcbaData.at(m_currentIndex).getshell();
}

void PcbaListModel::add(QString fileName)
{
    if (pcbaData.count() > 0)
        this->remove(0, pcbaData.count() - 1);
    revert();

    QString title;
    QString processState = "未测试";
    bool activate;
    QString result = "";
    bool manual;
    QString shell;

    QList<Pcba> tmpPcbaData;
    tmpPcbaData.clear();

    QFile file(fileName);

    if(!file.exists()) {
        qDebug()<< "read pcba.cfg failed" << Qt::endl;
        return ;
    }
    QString str;
    if (file.open(QIODevice::ReadOnly)) {
        QTextCodec* textCode = QTextCodec::codecForName("UTF-8");
        assert(textCode != nullptr);
        str = textCode->toUnicode(file.readAll());
    } else {
        qDebug()<< "open pcba.cfg failed" << Qt::endl;
        return;
    }

    QStringList strList = str.split("\n");

    foreach (QString tmpStr, strList) {

        if (tmpStr.contains("display_name")) {
            QStringList list = tmpStr.split(" ");
            if (list.length() == 2 )
                title = list[1].simplified();
        }

        if (tmpStr.contains("activate")) {
            QStringList list = tmpStr.split(" ");
            if (list.length() == 2 ) {
                if (list[1].simplified() == "true")
                    activate = true;
                else
                    activate = false;
            }
        }

        if (tmpStr.contains("shell")) {
            QStringList list = tmpStr.split(" ");
            if (list.length() == 2) {
                shell = list[1].simplified();
            }
        }

        if (tmpStr.contains("manual")) {
            QStringList list = tmpStr.split(" ");
            if (list.length() == 2) {
                QFile file(QCoreApplication::applicationDirPath() + "/resource/pcba/" + shell);
                if (!file.exists())
                    return;
                if (list[1].simplified() == "true") {
                    manual = true;
                    tmpPcbaData.append(Pcba(shell, title, processState, result, activate, manual));
                } else {
                    manual = false;
                    addPcba(shell, title, processState, result, activate, manual);
                }
            }
        }

    }

    foreach (Pcba pcba, tmpPcbaData) {
        addPcba(pcba.getshell(), pcba.gettitle(), pcba.getprocessState(), pcba.getresult(), pcba.getactivate(), pcba.getmanual());
    }

    if (m_currentIndex < 0 && pcbaData.count()) {
        setCurrentIndex(0);
    }
    revert();
    emit countChanged();

    checkLog();
}

void PcbaListModel::move(int from, int to) {
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);
    pcbaData.move(from, to);
    endMoveRows();
}

void PcbaListModel::remove(int first, int last)
{
    if ((first < 0) && (first >= pcbaData.count()))
        return;
    if ((last < 0) && (last >= pcbaData.count()))
        return;
    if (first > last) {
        first ^= last;
        last ^= first;
        first ^= last;
    }
    beginRemoveRows(QModelIndex(), first, last);
    while (first <= last) {
        pcbaData.removeAt(first);
        last --;
    }
    endRemoveRows();
    if (m_currentIndex >= pcbaData.count()) {
        setCurrentIndex(pcbaData.count() - 1);
    }
    emit countChanged();
}

void PcbaListModel::removeOne(int index)
{
#ifdef WIN32
    QFile file(pcbaData.at(index).getshell().toString());
#else
    QFile file(pcbaData.at(index).getshell().mid(8));
#endif
    beginRemoveRows(QModelIndex(), index, index);
    pcbaData.removeAt(index);
    if (file.remove())
        qDebug() << "delete ok" <<endl;
    endRemoveRows();
    if (m_currentIndex >= pcbaData.count()) {
        setCurrentIndex(pcbaData.count() - 1);
    }
}

void PcbaListModel::setCurrentTitle(QString title)
{
    Pcba s = pcbaData.at(m_currentIndex);
    s.settitle(title);
    pcbaData.replace(m_currentIndex, s);
    emit currentTitleChanged();
}

int PcbaListModel::count() const
{
    return pcbaData.count();
}

bool PcbaListModel::logfileIsReady() const
{
    return m_logfileIsReady;
}

void PcbaListModel::autoTest()
{
    QString path = QCoreApplication::applicationDirPath() + "/resource/pcba/";
    for (int i = 0; i < pcbaData.count();  i++) {
        if (pcbaData[i].getmanual())
            return;
        QProcess *pro = new QProcess();
        pro->start(path + pcbaData[i].getshell());
        beginResetModel();
        pcbaData[i].setprocessState("测试中");
        pcbaData[i].setresult(" ");
        endResetModel();
        connect(pro, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(procssHandle(int, QProcess::ExitStatus)));
        connect(pro, SIGNAL(finished(int, QProcess::ExitStatus)), pro, SLOT(deleteLater()));
    }
}

void PcbaListModel::singleTest()
{
    QString path = QCoreApplication::applicationDirPath() + "/resource/pcba/";
    QProcess *pro = new QProcess();
    pro->start(path + pcbaData.at(m_currentIndex).getshell());
    beginResetModel();
    pcbaData[m_currentIndex].setprocessState("测试中");
    pcbaData[m_currentIndex].setresult(" ");
    endResetModel();
    connect(pro, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(procssHandle(int, QProcess::ExitStatus)));
    connect(pro, SIGNAL(finished(int, QProcess::ExitStatus)), pro, SLOT(deleteLater()));
}

void PcbaListModel::manualTest()
{
    QString path = QCoreApplication::applicationDirPath() + "/resource/pcba/";
    manualPro->start(path + pcbaData.at(m_currentIndex).getshell());
    //qDebug() <<path + pcbaData.at(m_currentIndex).getshell() << endl;
    beginResetModel();
    pcbaData[m_currentIndex].setprocessState("测试中");
    pcbaData[m_currentIndex].setresult(" ");
    endResetModel();
    connect(manualPro, SIGNAL(readyReadStandardOutput()), this, SLOT(manualReadyReadStandardOutput()));
}

void PcbaListModel::exitTest()
{
    manualPro->kill();
    manualPro->waitForFinished(1000);
    m_manualLog.clear();

}

void PcbaListModel::setItemSuccess(QString sucess)
{
    beginResetModel();
    pcbaData[m_currentIndex].setprocessState("已完成");
    pcbaData[m_currentIndex].setresult(sucess);
    QFile file(QCoreApplication::applicationDirPath() + "/resource/pcba/.log/" + pcbaData[m_currentIndex].gettitle());
    if (file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        QString str = pcbaData[m_currentIndex].gettitle() + " " + pcbaData[m_currentIndex].getresult() + " " +  QDateTime::currentDateTime().toString("yyyy.MM.dd-hh:mm:ss");
        file.write(str.toUtf8());
    }
    file.close();
    m_logfileIsReady = true;
    emit logfileIsReadyChanged();
    endResetModel();
}

bool PcbaListModel::checkUnfinishedJob()
{
    bool ok = false;
    foreach (Pcba pcba, pcbaData) {
        if (pcba.getprocessState() == "测试中" || pcba.getprocessState() == "未测试")
            ok = true;
    }
    return ok;
}

void PcbaListModel::checkLog()
{
#if 1
    foreach (Pcba pcba, pcbaData) {
        /*QFile file(QCoreApplication::applicationDirPath() + "/resource/pcba/.log/" + pcba.gettitle());
        if (!file.exists())
            return;*/
        QProcess *pro = new QProcess();
        QString cmd = "cat " + QCoreApplication::applicationDirPath() + "/resource/pcba/.log/" + pcba.gettitle();
        pro->start(cmd);
        connect(pro, SIGNAL(readyReadStandardOutput()), this, SLOT(resultReadStandardOutput()));
        connect(pro, SIGNAL(finished(int, QProcess::ExitStatus)), pro, SLOT(deleteLater()));
    }
#endif
#if 0
    QFile file(QCoreApplication::applicationDirPath() + "/log.txt");
    if (!file.exists())
        return;
    if (file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        QString str = QString::fromUtf8(file.readAll());
        QStringList strList = str.split("\n");
        foreach (QString str, strList) {
            QStringList tmpStrList =  str.split(" ");
            if (tmpStrList.length() >= 2 ) {
                emit logTxtContentChanged(tmpStrList[0],  tmpStrList[1]);
            }
        }
        file.close();
    }
#endif
}

void PcbaListModel::setCurrentIndex(const int & i)
{
    if (i >= pcbaData.count() && m_currentIndex != 0) {
        m_currentIndex = 0;
        emit currentIndexChanged();
    } else if ((i >= 0) && (i < pcbaData.count()) && (m_currentIndex != i)) {
        m_currentIndex = i;
        emit currentIndexChanged();
        emit currentTitleChanged();
    }
}

void PcbaListModel::procssHandle(int exitCode, QProcess::ExitStatus exitStatus)
{
    QProcess *pro = (QProcess *)sender();

    for (int i = 0; i < pcbaData.count();  i++) {
        if (pro->program() == QCoreApplication::applicationDirPath() + "/resource/pcba/" + pcbaData[i].getshell()) {
            beginResetModel();
            pcbaData[i].setprocessState("已完成");
            if (exitCode)
                pcbaData[i].setresult("失败");
            else
                pcbaData[i].setresult("成功");
            QFile file(QCoreApplication::applicationDirPath() + "/resource/pcba/.log/" + pcbaData[i].gettitle());
            if (file.open(QIODevice::ReadWrite | QIODevice::Text)) {
                QString str = pcbaData[i].gettitle() + " " + pcbaData[i].getresult() + " " +  QDateTime::currentDateTime().toString("yyyy.MM.dd-hh:mm:ss");
                file.write(str.toUtf8());
            }
            file.close();
            m_logfileIsReady = true;
            emit logfileIsReadyChanged();
            endResetModel();
        }
    }
}

void PcbaListModel::manualReadyReadStandardOutput()
{
    //QString str = QString::fromUtf8(manualPro->readAll().simplified());
    QString str = QString::fromUtf8(manualPro->readLine().simplified());
    if (!str.isEmpty()) {
        m_manualLog = str + "\n";
        emit manualLogChanged();
    }
}

void PcbaListModel::resultReadStandardOutput()
{
    QProcess *pro = (QProcess *)sender();
    //QStringList strList = QString::fromUtf8(pro->readAll()).split(" ");
    QStringList strList = QString::fromUtf8(pro->readLine()).split(" ");
    if (strList.length() >= 3 ) {
        m_logfileIsReady = true;
        emit logfileIsReadyChanged();
        emit logTxtContentChanged(strList[0], strList[1],  strList[2]);
        for (int i = 0; i < pcbaData.count();  i++) {
            if (strList[0] == pcbaData[i].gettitle()) {
                if (pcbaData[i].getprocessState() == "未测试") {
                    pcbaData[i].setprocessState("已完成");
                    pcbaData[i].setresult(strList[1]);
                }
                beginResetModel();
                endResetModel();
            }
        }
    }
}

QHash<int, QByteArray> PcbaListModel::roleNames() const
{
    QHash<int, QByteArray> role;
    role[shellRole] = "shell";
    role[titleRole] = "title";
    role[processStateRole] = "processState";
    role[resultRole] = "result";
    role[manualRole] = "manual";
    return role;
}

void PcbaListModel::addPcba(QString shell, QString title, QString processState, QString result, bool activate, bool manual) {
    beginInsertRows(QModelIndex(), pcbaData.count(), pcbaData.count());
    pcbaData.append(Pcba(shell, title, processState, result, activate, manual));
    endInsertRows();
    emit countChanged();
}

