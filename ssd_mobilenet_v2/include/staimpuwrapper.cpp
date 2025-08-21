/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @brief         staimpuwrapper.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @date          2024-09-21
* @link          http://www.openedv.com/forum.php
*******************************************************************/
#include "staimpuwrapper.h"
using namespace wrapper_stai_mpu;
StaiMpuWrapper::StaiMpuWrapper(QObject *parent)
    : QObject{parent}
{}

void StaiMpuWrapper::Initialize(Config *conf)
{
    m_allow_fp16 = false;
    m_inferenceTime = 0;
    m_verbose = conf->verbose;
    m_inputMean = conf->input_mean;
    m_inputStd = conf->input_std;
    m_numberOfThreads = conf->number_of_threads;
    m_numberOfResults = conf->number_of_results;

    if (!conf->model_name.c_str()) {
        LOG(ERROR) << "no model file name\n";
        exit(-1);
    }

    std::string model_path = conf->model_name.c_str();
    m_stai_mpu_model.reset(new stai_mpu_network(model_path, true));
    m_input_infos = m_stai_mpu_model->get_input_infos();
    m_output_infos = m_stai_mpu_model->get_output_infos();
    m_num_inputs = m_stai_mpu_model->get_num_inputs();
    m_num_outputs = m_stai_mpu_model->get_num_outputs();
    m_input_height = GetInputHeight();
    m_input_width = GetInputWidth();
    m_input_channels = GetInputChannels();
    m_sizeInBytes = m_input_height * m_input_width * m_input_channels;
    m_input_tensor_int = new uint8_t[m_sizeInBytes];
    m_input_tensor_f = new float[m_sizeInBytes];
}

int StaiMpuWrapper::GetInputWidth()
{
    for (int i = 0; i < m_num_inputs; i++) {
        stai_mpu_tensor input_info = m_input_infos[i];
        m_input_shape = input_info.get_shape();
    }
    int input_width = m_input_shape[1];
    return input_width;
}

int StaiMpuWrapper::GetInputHeight()
{
    for (int i = 0; i < m_num_inputs; i++) {
        stai_mpu_tensor input_info = m_input_infos[i];
        m_input_shape = input_info.get_shape();
    }
    int input_height = m_input_shape[2];
    return input_height;
}

int StaiMpuWrapper::GetInputChannels()
{
    for (int i = 0; i < m_num_inputs; i++) {
        stai_mpu_tensor input_info = m_input_infos[i];
        m_input_shape = input_info.get_shape();
    }
    int input_channels = m_input_shape[3];
    return input_channels;
}

int StaiMpuWrapper::GetNumberOfInputs()
{
    return m_num_inputs;
}

int StaiMpuWrapper::GetNumberOfOutputs()
{
    return m_num_outputs;
}

std::vector<int> StaiMpuWrapper::GetOutputShape(int index)
{
    for (int i = 0; i < m_num_outputs; i++) {
        stai_mpu_tensor output_info = m_output_infos[i];
        m_output_shape = output_info.get_shape();
    }
    return m_output_shape;
}

std::vector<int> StaiMpuWrapper::GetInputShape(int index)
{
    for (int i = 0; i < m_num_inputs; i++) {
        stai_mpu_tensor input_info = m_input_infos[i];
        m_input_shape = input_info.get_shape();
    }
    return m_input_shape;
}

float StaiMpuWrapper::GetInferenceTime()
{
    return m_inferenceTime;
}

void StaiMpuWrapper::RunInference(uint8_t *img)
{
    bool floating_model = false;

    if (m_input_infos[0].get_dtype() == stai_mpu_dtype::STAI_MPU_DTYPE_FLOAT32){
        floating_model = true;
    }
    if (floating_model) {
        for (int i = 0; i < m_sizeInBytes; i++)
            m_input_tensor_f[i] = (img[i] - m_inputMean) / m_inputStd;
        m_stai_mpu_model->set_input(0, m_input_tensor_f);
    } else {
        for (int i = 0; i < m_sizeInBytes; i++)
            m_input_tensor_int[i] = img[i];
        m_stai_mpu_model->set_input(0, m_input_tensor_int);
    }

    struct timeval start_time, stop_time;
    gettimeofday(&start_time, nullptr);
    m_stai_mpu_model->run();
    gettimeofday(&stop_time, nullptr);
    m_inferenceTime = (get_ms(stop_time) - get_ms(start_time));
}

double StaiMpuWrapper::get_ms(timeval t)
{
    return (t.tv_sec * 1000 + t.tv_usec / 1000);
}
