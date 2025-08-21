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
NnThread::NnThread(QObject *parent)
    : QThread{parent},
    m_confidenceThresh(0.70),
    iou_thresh(0.45),
    video_width(640),
    video_height(480),
    drawing_width(640),
    drawing_height(480)
{
    labels_file_str = QCoreApplication::applicationDirPath().toStdString() + "/resource/x-linux-ai/object-detection/models/coco_ssd_mobilenet/labels_coco_dataset_80.txt";
    model_file_str = QCoreApplication::applicationDirPath().toStdString() + "/resource/x-linux-ai/object-detection/models/coco_ssd_mobilenet/ssd_mobilenet_v2_fpnlite_10_256_int8_per_tensor.nb";

    size_t label_count;

    /* stai_mpu wrapper initialization */
    config.model_name = model_file_str;
    config.labels_file_name = labels_file_str;
    config.input_mean = 127.5f;
    config.input_std = 127.5f;
    config.number_of_threads = 2;
    config.number_of_results = 5;
    stai_mpu_wrapper.Initialize(&config);

    results.model_type = "ssd_mobilenet_v2";

    nn_input_width = stai_mpu_wrapper.GetInputWidth();
    nn_input_height = stai_mpu_wrapper.GetInputHeight();

    /* Recover labels from label file */
    if (ssdMobilenetpp.ReadLabelsFile(config.labels_file_name, &labels, &label_count) != 0){
        exit(1);
    }
}

void NnThread::run()
{
    static int count = 0;
    static float timercount = 0;
    memcpy(in.data(), m_image.bits(), m_image.width() * m_image.height() * 3);
    nn_inference(&in[0]);
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
    QVector <Mark> marks;
    for (unsigned int i = 0; i < results.vect_ObjDetect_Results.size() ; i++) {
        if (results.vect_ObjDetect_Results[i].score > m_confidenceThresh) {
            Mark mark;
            std::stringstream info_sstr;
            if (results.vect_ObjDetect_Results[i].class_index > labels.size() - 1)
                return;
            info_sstr << labels[results.vect_ObjDetect_Results[i].class_index] << " " << std::fixed << std::setprecision(1) << results.vect_ObjDetect_Results[i].score * 100 << "%";
            //std::cout<< info_sstr.str() << std::endl;
            float x1 = results.vect_ObjDetect_Results[i].location.x0*drawing_width;
            float y1 = results.vect_ObjDetect_Results[i].location.y0*drawing_height;
            float width = drawing_width*(results.vect_ObjDetect_Results[i].location.x1 - results.vect_ObjDetect_Results[i].location.x0);
            float height = drawing_height*(results.vect_ObjDetect_Results[i].location.y1 - results.vect_ObjDetect_Results[i].location.y0);
            width, height = check_bb_drawing(x1, y1, width, height, drawing_width, drawing_height, 0);
            mark.x = x1;
            mark.y = y1;
            mark.width = width;
            mark.height = height;
            mark.text = QString::fromStdString(info_sstr.str());
            marks.append(mark);
        }
    }
    //if (marks.count() != 0)
    emit drawMarksChanged(marks);
}

float NnThread::check_bb_drawing(float x, float y, float width, float height, float drawing_width, float drawing_height, int offset)
{
    if((x + width) > drawing_width){
        float diff = (x + width) - drawing_width;
        width = width - diff - offset;
    }
    if((y + height) > drawing_height){
        //float diff = (y + height) - drawing_height;
        height = drawing_height;
    }
    return (width, height);
}

void NnThread::nn_inference(uint8_t *img)
{
    stai_mpu_wrapper.RunInference(img);
    results.inference_time = stai_mpu_wrapper.GetInferenceTime();
}

void NnThread::nn_postprocessing()
{
    ssdMobilenetpp.nn_post_proc(stai_mpu_wrapper.m_stai_mpu_model, stai_mpu_wrapper.m_output_infos, &results, m_confidenceThresh, iou_thresh, results.model_type);
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
    in.resize(m_image.width() * m_image.height() * 3);
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
