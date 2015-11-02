//
//  SVMModel.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 28/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "SVMModel.h"

#import <opencv2/ml.hpp>
#import "MotionData.h"

using namespace cv;
using namespace cv::ml;

// macro
#define DIMENSION 5

@implementation SVMModel
{
    Ptr<SVM> svm;
}

// every array's element is a MotionData Object
- (instancetype)initWithMotionData:(NSArray *)data {
    
    // 初始化SVM模型
    int *labels = NULL;
    float **trainingData = NULL;
    
    int data_count = (int)data.count;
    
    // 使用data来初始化labels和traningData
    // 初始化label
    labels = new int[data_count];
    trainingData = new float*[data_count];
    for (int i = 0; i != data_count; i++) {
        trainingData[i] = new float[DIMENSION];
    }
    for (int i = 0; i != data_count; i++) {
        MotionData *md = data[i];
        labels[i] = md.hand;
        trainingData[i][0] = (float)md.x;
        trainingData[i][1] = (float)md.y;
        trainingData[i][2] = (float)md.roll;
    }
    
    Mat trainingDataMat(data_count, DIMENSION, CV_32FC1);
    
    for (int i = 0; i < data_count; i++) {
        trainingDataMat.at<float>(i, 0) = trainingData[i][0]/300; // 归一化
        trainingDataMat.at<float>(i, 1) = trainingData[i][1]/600; // 归一化
        trainingDataMat.at<float>(i, 2) = trainingData[i][2];
    }
    
    Mat labelsMat(data_count, 1, CV_32SC1, labels);
    
    //    std::cout << trainingDataMat << std::endl;
    //    std::cout << "hehe" << std::endl;
    //    std::cout << labelsMat << std::endl;
    
    svm = SVM::create();
    svm->setType(SVM::C_SVC);
    svm->setKernel(SVM::LINEAR);
    svm->setC(1);
    svm->setTermCriteria(TermCriteria(TermCriteria::MAX_ITER, 1000, 1e-6));
    
    NSLog(@"开始training...");
    svm->train(trainingDataMat, ROW_SAMPLE, labelsMat);
    NSLog(@"结束training");
    
    // 保存训练模型
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"svm_model.xml"];
    svm->save(filepath.UTF8String);
    
    // 记得删除分配的内存(等等，这块内存是直接被Mat给引用了，还是重新创建了一块内存区域？需要考证)
    delete []labels;
    for (int i = 0; i != data_count; i++) {
        delete[] trainingData[i];
    }
    delete []trainingData;
    
    return self;
}

- (BOOL)predictionMotionData:(MotionData *)testData {

    // 初始化测试矩阵
    Mat testMat(1, DIMENSION, CV_32FC1);
    testMat.at<float>(0, 0) = testData.x/300;
    testMat.at<float>(0, 1) = testData.y/600;
    testMat.at<float>(0, 2) = testData.roll;
    
    //std::cout << testMat << std::endl;
    
    float response = svm->predict(testMat);

    NSLog(@"prediction result is %f", response);
    
    // YES means left, NO means right
    return response < 1e-6;
}

@end