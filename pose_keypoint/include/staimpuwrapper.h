/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         staimpuwrapper.h
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-10-15
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#ifndef STAIMPUWRAPPER_H
#define STAIMPUWRAPPER_H

#include <QObject>
#include <algorithm>
#include <functional>
#include <queue>
#include <memory>
#include <string>
#include <sys/time.h>
#include <vector>
#include <fstream>

#include "stai_mpu_network.h"
#include <QVector>

#define LOG(x) std::cerr
namespace wrapper_stai_mpu{
    /* Wrapper configuration structure */
    struct Config {
        bool verbose;
        int number_of_threads = 2;
        int number_of_results = 5;
        std::string model_name;
    };

    /* STAI Mpu Wrapper class */
    class StaiMpuWrapper : public QObject
    {
        Q_OBJECT
    public:
        explicit StaiMpuWrapper(QObject *parent = nullptr);
    private:
        std::vector<stai_mpu_tensor>                 m_input_infos;
        std::vector<int> 							 m_input_shape;
        std::vector<int> 							 m_output_shape;
        uint8_t* 									 m_input_tensor_int;
        float* 										 m_input_tensor_f;
        bool                                     	 m_verbose;
        int                                      	 m_numberOfThreads;
        int                                      	 m_numberOfResults;
        int 										 m_num_inputs;
        int 										 m_num_outputs;
        int 										 m_input_width;
        int 										 m_input_height;
        int 										 m_input_channels;
        int											 m_sizeInBytes;
        float                                   	 m_inferenceTime;
    public:
        std::unique_ptr<stai_mpu_network>            m_stai_mpu_model;
        std::vector<stai_mpu_tensor>				 m_output_infos;

        /* STAI Mpu Wrapper initialization */
        void Initialize(Config* conf);

        /* Get the NN model inputs width */
        int GetInputWidth();

        /* Get the NN model inputs height */
        int GetInputHeight();

        /* Get the NN model inputs channels */
        int GetInputChannels();

        /* Get the number of NN model inputs */
        int GetNumberOfInputs();

        /* Get the number of NN model outputs */
        int GetNumberOfOutputs();

        /* Get the shape of NN model outputs */
        std::vector<int> GetOutputShape(int index);

        /* Get the shape of NN model inputs */
        std::vector<int> GetInputShape(int index);

        /* Get the NN model inference time */
        float GetInferenceTime();

        /* Run NN model inference based on a picture */
        void RunInference(uint8_t* img);

        /**
         * Return time value in millisecond
         */
        double get_ms(struct timeval t);

    signals:
    };
} // namespace stai_mpu_wrapper
#endif // STAIMPUWRAPPER_H
