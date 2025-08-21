/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   pcba
* @brief         pcbaListModel.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2023-04-10
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef PCBALISTMODEL_H
#define PCBALISTMODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QProcess>
#include <QCoreApplication>
#include <QFile>
#include <QDateTime>

class Pcba {
public:
    explicit Pcba(QString shell, QString title, QString processState, QString result, bool activate, bool manual);
    QString getprocessState() const;
    QString getresult() const;
    QString gettitle() const;
    QString getshell() const;
    bool getactivate() const;
    bool getmanual() const;

    void settitle(QString title);
    void setprocessState(QString);
    void setresult(QString);

private:
    QString m_title;
    QString m_shell;
    QString m_processState;
    QString m_result;
    bool m_activate;
    bool m_manual;
};

class PcbaListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit PcbaListModel(QObject *parent = 0);
    int currentIndex() const;
    QString manualLog() const;
    int count() const;
    bool logfileIsReady() const;
    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE int randomIndex();
    Q_INVOKABLE QString getcurrentTitle() const;
    Q_INVOKABLE QString getcurrentShell() const;
    Q_INVOKABLE void add(QString paths);
    Q_INVOKABLE void move(int from, int to);
    Q_INVOKABLE void remove(int first, int last);
    Q_INVOKABLE void removeOne(int index);
    Q_INVOKABLE void setCurrentTitle(QString title);
    Q_INVOKABLE void autoTest();
    Q_INVOKABLE void singleTest();
    Q_INVOKABLE void manualTest();
    Q_INVOKABLE void exitTest();
    Q_INVOKABLE void setItemSuccess(QString  success);
    Q_INVOKABLE bool checkUnfinishedJob();
    Q_INVOKABLE void checkLog();
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QString currentTitle READ getcurrentTitle NOTIFY currentTitleChanged)
    Q_PROPERTY(QString manualLog READ manualLog  NOTIFY manualLogChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool logfileIsReady READ logfileIsReady NOTIFY logfileIsReadyChanged)
    void setCurrentIndex(const int & i);

    enum PcbaRole {
        shellRole = Qt::UserRole + 1,
        titleRole,
        processStateRole,
        resultRole,
        manualRole,
    };

signals:
    void currentIndexChanged();
    void countChanged();
    void manualLogChanged();
    void currentTitleChanged();
    void logfileIsReadyChanged();
    void logTxtContentChanged(QString testTiltle, QString testResult, QString testTime);

public slots:
    void procssHandle(int, QProcess::ExitStatus);
    void manualReadyReadStandardOutput();
    void resultReadStandardOutput();

private:
    QHash<int, QByteArray> roleNames() const;
    void addPcba(QString path, QString title, QString processState, QString result, bool activate, bool manual);

    int m_currentIndex;
    QList<Pcba> pcbaData;

    QProcess *manualPro;
    QString m_manualLog;
    QFile logFile;

    bool m_logfileIsReady;

};

#endif // PCBALISTMODEL_H
