/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         videodata.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-11-09
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef VIDEODATA_H
#define VIDEODATA_H

#include <QObject>
#include <QUrl>

class VideoData : public QObject {
    Q_OBJECT
    Q_PROPERTY(QUrl coverArtUrl READ coverArtUrl WRITE setCoverArtUrl NOTIFY coverArtUrlChanged FINAL)
    Q_PROPERTY(QUrl sourceUrl READ sourceUrl WRITE setSourceUrl NOTIFY sourceUrlChanged FINAL)
    Q_PROPERTY(QString duration READ duration WRITE setDuration NOTIFY durationChanged FINAL)
    Q_PROPERTY(bool checked READ checked WRITE setChecked NOTIFY checkedChanged FINAL)
public:
    explicit VideoData(QObject *parent = nullptr);

    QUrl coverArtUrl() const;
    void setCoverArtUrl(const QUrl &newCoverArtUrl);

    QUrl sourceUrl() const;
    void setSourceUrl(const QUrl &newSourceUrl);

    QString duration() const;
    void setDuration(const QString &newDuration);

    bool checked() const;
    void setChecked(bool newChecked);

signals:
    void coverArtUrlChanged();
    void sourceUrlChanged();
    void durationChanged();

    void checkedChanged();

private:
    QUrl m_coverArtUrl;
    QUrl m_sourceUrl;
    QString m_duration;
    bool m_checked;
};

#endif // VIDEODATA_H
