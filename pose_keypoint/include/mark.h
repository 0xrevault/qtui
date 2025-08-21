/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         mark.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef MARK_H
#define MARK_H
#include <QObject>
#include <QString>
#include <opencv2/opencv.hpp>

class Mark
{
public:
    Mark();
    std::vector<cv::Point2f> keypoints_xy;
    std::vector<cv::Vec4i> edges_xy;
    std::vector<cv::Scalar> edge_colors;

    bool operator==(const Mark& other) const {
        return keypoints_xy == other.keypoints_xy && edges_xy == other.edges_xy
               && edge_colors == other.edge_colors;
    }
};

#endif // MARK_H
