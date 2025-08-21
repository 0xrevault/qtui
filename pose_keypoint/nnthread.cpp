/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         nnthread.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-20
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "nnthread.h"
#include <QCoreApplication>
#include <QDebug>
#include <QColor>
NnThread::NnThread(QObject *parent)
    : QThread{parent},
    m_confidenceThresh(0.75),
    iou_thresh(0.5),
    video_width(640),
    video_height(480),
    drawing_width(640),
    drawing_height(480)
{
    model_file_str = QCoreApplication::applicationDirPath().toStdString() + "/resource/x-linux-ai/pose-estimation/models/yolov8n_pose/yolov8n_256_quant_pt_uf_pose_coco-st.nb";

    /* stai_mpu wrapper initialization */
    config.model_name = model_file_str;
    config.number_of_threads = 2;
    config.number_of_results = 5;
    stai_mpu_wrapper.Initialize(&config);

    nn_input_width = stai_mpu_wrapper.GetInputWidth();
    nn_input_height = stai_mpu_wrapper.GetInputHeight();

    connect(&poseKeyPonitpp, SIGNAL(drawMark(Mark)),
            this, SIGNAL(drawMarkChanged(Mark)));
}

void NnThread::run()
{
    static int count = 0;
    static float timercount = 0;
    cv::Mat inferimage(m_image.height(), m_image.width(), CV_8UC3);
    memcpy(inferimage.data, m_image.bits(), m_image.width() * m_image.height() * 3);
    nn_inference(inferimage.data);
    nn_postprocessing();

    timercount += results.inference_time;
    count++;
    if (count == 30) {
        float inferTimer = timercount / 30;
        setInferenceTime(QString::number(inferTimer, 'f', 0));
        setInferenceFrameRate(QString::number(1000.0f / inferTimer, 'f', 0));
        count = 0;
        timercount = 0;
    }
}

void NnThread::nn_inference(uint8_t *img)
{
    stai_mpu_wrapper.RunInference(img);
    results.inference_time = stai_mpu_wrapper.GetInferenceTime();
}

void NnThread::nn_postprocessing()
{
    poseKeyPonitpp.nn_post_proc(stai_mpu_wrapper.m_stai_mpu_model, stai_mpu_wrapper.m_output_infos, &results, m_confidenceThresh, iou_thresh);
}

QString NnThread::inferenceFrameRate() const
{
    return m_inferenceFrameRate;
}

void NnThread::setInferenceFrameRate(const QString &newInferenceFrameRate)
{
    if (m_inferenceFrameRate == newInferenceFrameRate)
        return;
    m_inferenceFrameRate = newInferenceFrameRate;
    emit inferenceFrameRateChanged();
}

QString NnThread::inferenceTime() const
{
    return m_inferenceTime;
}

void NnThread::setInferenceTime(const QString &newInferenceTime)
{
    if (m_inferenceTime == newInferenceTime)
        return;
    m_inferenceTime = newInferenceTime;
    emit inferenceTimeChanged();
}

QImage NnThread::image() const
{
    return m_image;
}

void NnThread::setImage(const QImage &newImage)
{
    if (m_image == newImage)
        return;
    if (newImage.isNull())
        return;
    if (this->isRunning())
        return;
    m_image = newImage.scaled(nn_input_width, nn_input_height);
    emit imageChanged();
    this->start();
}

float NnThread::confidenceThresh() const
{
    return m_confidenceThresh;
}

void NnThread::setConfidenceThresh(float newConfidenceThresh)
{
    if (qFuzzyCompare(m_confidenceThresh, newConfidenceThresh))
        return;
    m_confidenceThresh = newConfidenceThresh;
    emit confidenceThreshChanged();
}
