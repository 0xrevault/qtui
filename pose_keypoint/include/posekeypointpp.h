/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         posekeypointpp.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-15
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef POSEKEYPOINTPP_H
#define POSEKEYPOINTPP_H

#include <QObject>
#include <memory>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include "stai_mpu_network.h"
#include <cmath>
#include <algorithm>
#include <map>
#include <opencv2/opencv.hpp>
#include <mark.h>
// #define disp_width 256
// #define disp_height 256

#define disp_width 640
#define disp_height 480

namespace nn_postproc{
    using namespace cv;
    /* Structure used to store bounding box information : confidence, location, keypoints */
    struct ObjDetect_Results
    {
        float left, top, right, bottom, confidence, width, height;
        std::vector<float> keypoints;
    };
    /* Structure used to store frame inference result: inference time, vector of ObjDetect_Results */
    struct Frame_Results
    {
        std::vector<ObjDetect_Results> vect_ObjDetect_Results;
        //cv::Mat resultsframe;
        float inference_time;
        stai_mpu_backend_engine ai_backend;
    };

    struct Color
    {
        int r, g, b;
    };

class PoseKeyPonitpp : public QObject
{
    Q_OBJECT
public:
    explicit PoseKeyPonitpp(QObject *parent = nullptr);
    bool nn_post_proc_first_call;
    double get_ms(struct timeval t);

    std::map<std::pair<int, int>, Color> KEYPOINT_EDGE_TO_COLOR;

    /**
     * Function used to calculate intersection over union of two boxes
     * Used in the Non Max Suppression process
     * Return IOU of the two boxes
     */
    float IoU(const ObjDetect_Results &a, const ObjDetect_Results &b);

    std::vector<ObjDetect_Results> postprocessyolov8_pose(float *outputs, float conf_threshold, float iou_threshold);

    void keypoints_and_edges_for_display(const std::vector<ObjDetect_Results> &final_detections,
                                         std::vector<cv::Point2f> &keypoints_xy,
                                         std::vector<cv::Vec4i> &edges_xy,
                                         std::vector<cv::Scalar> &edge_colors);

    void draw_keypoints_and_edges(Mat &img, const std::vector<Point2f> keypoints_xy, const std::vector<Vec4i> edges_xy, const std::vector<Scalar> edge_colors);

    void nn_post_proc(std::unique_ptr<stai_mpu_network> &nn_model, std::vector<stai_mpu_tensor> output_infos, Frame_Results *results, float conf_threshold, float iou_threshold);
signals:
    void drawMark(const Mark &mark);
};
} // namespace nn_postproc
#endif // POSEKEYPOINTPP_H
