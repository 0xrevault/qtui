/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         posekeypointpp.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-15
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "posekeypointpp.h"
using namespace nn_postproc;

PoseKeyPonitpp::PoseKeyPonitpp(QObject *parent)
    : QObject{parent}, nn_post_proc_first_call(true), KEYPOINT_EDGE_TO_COLOR({
          {{0, 1}, {202, 179, 59}},
          {{0, 2}, {125, 0, 229}},
          {{1, 3}, {202, 179, 59}},
          {{2, 4}, {125, 0, 229}},
          {{5, 7}, {202, 179, 59}},
          {{7, 9}, {202, 179, 59}},
          {{6, 8}, {125, 0, 229}},
          {{8, 10}, {125, 0, 229}},
          {{5, 6}, {0, 209, 255}},
          {{5, 11}, {202, 179, 59}},
          {{6, 12}, {125, 0, 229}},
          {{11, 12}, {0, 209, 255}},
          {{11, 13}, {202, 179, 59}},
          {{13, 15}, {202, 179, 59}},
          {{12, 14}, {125, 0, 229}},
          {{14, 16}, {125, 0, 229}}
      })
{}

double PoseKeyPonitpp::get_ms(timeval t)
{
    return (t.tv_sec * 1000 + t.tv_usec / 1000);
}

float PoseKeyPonitpp::IoU(const ObjDetect_Results &a, const ObjDetect_Results &b)
{
    float areaA = (a.right - a.left) * (a.bottom - a.top);
    if (areaA <= 0.0f)
        return 0.0f;

    float areaB = (b.right - b.left) * (b.bottom - b.top);
    if (areaB <= 0.0f)
        return 0.0f;

    float inter_x1 = std::max(a.left, b.left);
    float inter_y1 = std::max(a.top, b.top);
    float inter_x2 = std::min(a.right, b.right);
    float inter_y2 = std::min(a.bottom, b.bottom);

    float inter_area = std::max(0.0f, inter_x2 - inter_x1) * std::max(0.0f, inter_y2 - inter_y1);

    float union_area = areaA + areaB - inter_area;

    return inter_area / union_area;
}

std::vector<ObjDetect_Results> PoseKeyPonitpp::postprocessyolov8_pose(float *outputs, float conf_threshold, float iou_threshold)
{
    std::vector<ObjDetect_Results> base_objects_list;
    std::vector<ObjDetect_Results> final_dets;
    std::vector<std::vector<float>> outputs_2d(56, std::vector<float>(1344));

    for (int i = 0; i < 56; ++i) {
        for (int j = 0; j < 1344; ++j) {
            outputs_2d[i][j] = outputs[i * 1344 + j];
        }
    }

    std::vector<std::vector<float>> transposed_outputs(1344, std::vector<float>(56));

    for (int i = 0; i < 56; ++i) {
        for (int j = 0; j < 1344; ++j) {
            transposed_outputs[j][i] = outputs_2d[i][j];
        }
    }

    for (int i = 0; i < 1344; ++i) {
        if (transposed_outputs[i][4] > conf_threshold) {

            float x_center = transposed_outputs[i][0];
            float y_center = transposed_outputs[i][1];
            float width = transposed_outputs[i][2];
            float height = transposed_outputs[i][3];

            float left = x_center - width / 2;
            float top = y_center - height / 2;
            float right = x_center + width / 2;
            float bottom = y_center + height / 2;

            float confidence = transposed_outputs[i][4];
            std::vector<float> keypoints;
            for (int j = 5; j < 57; ++j) {
                keypoints.push_back(transposed_outputs[i][j]);
            }
            base_objects_list.push_back({left, top, right, bottom, confidence, width, height, keypoints});
        }
    }

    //NMS
    std::sort(base_objects_list.begin(), base_objects_list.end(), [](const ObjDetect_Results &a, const ObjDetect_Results &b)
              { return a.confidence > b.confidence; });
    while (!base_objects_list.empty())
    {
        final_dets.push_back(base_objects_list.front());
        base_objects_list.erase(std::remove_if(base_objects_list.begin(), base_objects_list.end(), [&](const ObjDetect_Results &obj)
                                               { return IoU(obj, final_dets.back()) > iou_threshold; }),base_objects_list.end());
    }
    return final_dets;
}

void PoseKeyPonitpp::keypoints_and_edges_for_display(const std::vector<ObjDetect_Results> &final_detections, std::vector<cv::Point2f> &keypoints_xy, std::vector<cv::Vec4i> &edges_xy, std::vector<cv::Scalar> &edge_colors)
{
    const float keypoint_threshold = 0.4;
    std::vector<cv::Point2f> keypoints_all;
    std::vector<cv::Vec4i> keypoint_edges_all;

    for (const auto &detection : final_detections)
    {
        const std::vector<float> &kpts = detection.keypoints;
        std::vector<float> kpts_x, kpts_y, kpts_scores;

        for (size_t i = 0; i < kpts.size(); i += 3)
        {
            kpts_x.push_back(kpts[i]);
            kpts_y.push_back(kpts[i + 1]);
            kpts_scores.push_back(kpts[i + 2]);
        }

        std::vector<cv::Point2f> kpts_absolute_xy;
        for (size_t i = 0; i < kpts_x.size(); ++i)
        {
            kpts_absolute_xy.push_back(Point2f(disp_width * kpts_x[i], disp_height * kpts_y[i]));
        }

        for (size_t i = 0; i < kpts_scores.size(); ++i)
        {
            if (kpts_scores[i] > keypoint_threshold)
            {
                keypoints_all.push_back(kpts_absolute_xy[i]);
            }
        }

        for (const auto &edge_pair : KEYPOINT_EDGE_TO_COLOR)
        {
            if (kpts_scores[edge_pair.first.first] > keypoint_threshold && kpts_scores[edge_pair.first.second] > keypoint_threshold)
            {
                Vec4i line_seg(kpts_absolute_xy[edge_pair.first.first].x, kpts_absolute_xy[edge_pair.first.first].y,
                               kpts_absolute_xy[edge_pair.first.second].x, kpts_absolute_xy[edge_pair.first.second].y);
                keypoint_edges_all.push_back(line_seg);
                edge_colors.push_back(Scalar(edge_pair.second.r, edge_pair.second.g, edge_pair.second.b));
            }
        }
    }

    if (!keypoints_all.empty())
    {
        keypoints_xy = keypoints_all;
    }
    else
    {
        keypoints_xy = {};
    }

    if (!keypoint_edges_all.empty())
    {
        edges_xy = keypoint_edges_all;
    }
    else
    {
        edges_xy = {};
    }
}

void PoseKeyPonitpp::draw_keypoints_and_edges(Mat &img, const std::vector<Point2f> keypoints_xy, const std::vector<Vec4i> edges_xy, const std::vector<Scalar> edge_colors)
{
    for (const auto &kp : keypoints_xy)
    {
        circle(img, kp, 5, Scalar(0, 255, 0), -1);
    }

    for (size_t i = 0; i < edges_xy.size(); ++i)
    {
        line(img, Point(edges_xy[i][0], edges_xy[i][1]), Point(edges_xy[i][2], edges_xy[i][3]), edge_colors[i], 2);
    }
}

void PoseKeyPonitpp::nn_post_proc(std::unique_ptr<stai_mpu_network> &nn_model, std::vector<stai_mpu_tensor> output_infos, Frame_Results *results, float conf_threshold, float iou_threshold)
{
    /* Get backend used */
    results->ai_backend = nn_model->get_backend_engine();

    /* Get inference outputs */
    float *outputs = static_cast<float *>(nn_model->get_output(0));

    std::vector<ObjDetect_Results> final_dets = postprocessyolov8_pose(outputs, conf_threshold, iou_threshold);
    std::vector<cv::Point2f> keypoints_xy;
    std::vector<cv::Vec4i> edges_xy;
    std::vector<cv::Scalar> edge_colors;
    free(outputs);

    keypoints_and_edges_for_display(final_dets, keypoints_xy, edges_xy, edge_colors);
    Mark mark;
    mark.keypoints_xy = keypoints_xy;
    mark.edges_xy = edges_xy;
    mark.edge_colors = edge_colors;
    emit drawMark(mark);
    //draw_keypoints_and_edges(results->resultsframe, keypoints_xy, edges_xy, edge_colors);
}
