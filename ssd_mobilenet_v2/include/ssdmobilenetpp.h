/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         ssdmobilenetpp.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef SSDMOBILENETPP_H
#define SSDMOBILENETPP_H

#include <QObject>
#include <memory>
#include <string>
#include <vector>
#include <fstream>
#include "stai_mpu_network.h"

#define LOG(x) std::cerr

namespace nn_postproc{

    /* Structure used for box coordinates */
    struct ObjDetect_Location {
        float y0, x0, y1, x1;
    };

    /* Structure used to store bounding box information : class, score, box coordinates */
    struct ObjDetect_Results {
        int class_index;
        float score;
        ObjDetect_Location location;
    };

    /* Structure used to store frame inference result: inference time, vector of ObjDetect_Results */
    struct Frame_Results {
        std::vector<ObjDetect_Results> vect_ObjDetect_Results;
        float inference_time;
        stai_mpu_backend_engine ai_backend;
        std::string model_type;
    };

    class SsdMobilenetpp : public QObject
    {
        Q_OBJECT
    public:
        explicit SsdMobilenetpp(QObject *parent = nullptr);
        bool nn_post_proc_first_call;
        double get_ms(struct timeval t);
        /**
         * Function used to filter the raw NN output by score
         * Each results that are not over the confidence threshold are dropped
         * Return the vector of box index that are over the threshold
         */
        std::vector<int> Filter_by_score(float* predictions, int rows, int cols, float confidence_thresh);

        /**
         * Function used to decode raw NN output using associated anchors
         * Return a float vector of decoded outputs
         */
        std::vector<float> BB_decoding(std::vector<float> encoded_bbox, std::vector<float> anchors);

        /**
         * Function used to calculate intersection over union of two boxes
         * Used in the Non Max Suppression process
         * Return IOU of the two boxes
         */
        float IoU(const ObjDetect_Location& a, const ObjDetect_Location& b);

        /**
         * Function used to reproduce Non Max Supression technique
         * This technique is used to filter boxes that are redondant
         * or with too much overlap
         * Return the final vector of ObjDetect_Results
         */
        std::vector<ObjDetect_Results> non_max_suppression(const std::vector<float>& bb_predictions, std::vector<int>& class_index, std::vector<float>& filtered_scores,float iou_threshold);

        /**
         * Function used to extract from the class prediction output relevant information such as
         * highest score and class index
         */
        void recover_score_info(const std::vector<float>& scores, int number_of_boxes, int number_of_classes,
                                std::vector<float>& highest_scores, std::vector<int>& class_indices);

        /**
         * NN post processing :
         * Get NN inference outputs
         * Decode
         * Filter
         * Populate Frame result structure for drawing phase
         */
        void nn_post_proc(std::unique_ptr<stai_mpu_network>& nn_model,std::vector<stai_mpu_tensor> output_infos, Frame_Results* results, float confidenceThresh, float iou_threshold, std::string model_type);


        // Takes a file name, and loads a list of labels from it, one per line, and
        // returns a vector of the strings. It pads with empty strings so the length
        // of the result is a multiple of 16, because our model expects that.
        int ReadLabelsFile(const std::string& file_name,
                           std::vector<std::string>* result,
                           size_t* found_label_count);
    signals:
    };
} // namespace nn_postproc
#endif // SSDMOBILENETPP_H
