/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         nnthread.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-20
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef NNTHREAD_H
#define NNTHREAD_H

#include <QObject>
#include <QThread>
#include <QVector>
#include <QImage>
#include "ssdmobilenetpp.h"
#include "staimpuwrapper.h"
#include <mark.h>
#include <fstream>
#include <iostream>
#include <iomanip>

class NnThread : public QThread
{
    Q_OBJECT
    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(float confidenceThresh READ confidenceThresh WRITE setConfidenceThresh NOTIFY confidenceThreshChanged)
    Q_PROPERTY(QString inferenceTime READ inferenceTime NOTIFY inferenceTimeChanged)
     Q_PROPERTY(QString inferenceFrameRate READ inferenceFrameRate  NOTIFY inferenceFrameRateChanged)
public:
    explicit NnThread(QObject *parent = nullptr);
    QImage image() const;
    void setImage(const QImage &newImage);

    float confidenceThresh() const;
    void setConfidenceThresh(float newConfidenceThresh);

    QString inferenceTime() const;
    void setInferenceTime(const QString &newInferenceTime);

    QString inferenceFrameRate() const;
    void setInferenceFrameRate(const QString &newInferenceFrameRate);

private:
    wrapper_stai_mpu::StaiMpuWrapper stai_mpu_wrapper;
    nn_postproc::SsdMobilenetpp ssdMobilenetpp;
    struct wrapper_stai_mpu::Config config;
    nn_postproc::Frame_Results results;
    std::vector<std::string> labels;

    std::string labels_file_str;
    std::string model_file_str;

    float m_confidenceThresh;
    float iou_thresh;
    int video_width;
    int video_height;
    float drawing_width;
    float drawing_height;

    /* NN input size */
    int nn_input_width;
    int nn_input_height;

    std::vector<uint8_t> in;

    void run() override;

    float check_bb_drawing(float x,float y, float width, float height, float drawing_width, float drawing_height, int offset);

private:
    /**
 * This function execute an NN inference
 */
    void nn_inference(uint8_t *img);
    /**
 * This function used to process outputs of the NN model inference
 * and extract relevant results => bb coordinates, classes, scores
 */
    void nn_postprocessing();

    QImage m_image;
    QString m_inferenceTime;
    QString m_inferenceFrameRate;

signals:
    void drawMarksChanged(Marks marks);
    void imageChanged();
    void confidenceThreshChanged();
    void inferenceTimeChanged();
    void inferenceFrameRateChanged();
};

#endif // NNTHREAD_H
