//
//  TrainingViewController.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 29/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "TrainingViewController.h"

#import "MotionData.h"
#import "MotionDataTool.h"
#import <opencv2/ml.hpp>
#import "AppDelegate.h"

using namespace cv;
using namespace cv::ml;

@interface TrainingViewController()
{
    Ptr<SVM> svmModel;
    CMMotionManager *mManager;
}

@property (strong, nonatomic) IBOutlet UILabel *touchLocationLabel;

@end

@implementation TrainingViewController


#define DIMENSION 3
- (void)viewDidLoad {
    
    NSArray *data = [MotionDataTool getMotionData];
    
    // 初始化SVM模型
    int *labels = NULL;
    float **trainingData = NULL;
    
    int data_count = (int)data.count;
    
    // 使用data来初始化labels和traningData
    // 初始化label
    labels = new int[data_count];
    //trainingData = new double[data_count * DIMENSION];
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
    
//    for (int i = 0; i != data_count; i++) {
//        //NSLog(@"%d", labels[i]);
//        
//        for (int j = 0; j != DIMENSION; j++) {
//            NSLog(@"%f,", trainingData[i][j]);
//        }
//    }
    
    Mat trainingDataMat(data_count, DIMENSION, CV_32FC1);
    
    for (int i = 0; i < data_count; i++) {
        trainingDataMat.at<float>(i, 0) = trainingData[i][0]/300;
        trainingDataMat.at<float>(i, 1) = trainingData[i][1]/600;
        trainingDataMat.at<float>(i, 2) = trainingData[i][2];
    }
    
    Mat labelsMat(data_count, 1, CV_32SC1, labels);
    
//    std::cout << trainingDataMat << std::endl;
//    std::cout << "hehe" << std::endl;
//    std::cout << labelsMat << std::endl;
    
    svmModel = SVM::create();
    svmModel->setType(SVM::C_SVC);
    svmModel->setKernel(SVM::LINEAR);
    svmModel->setC(1);
    svmModel->setTermCriteria(TermCriteria(TermCriteria::MAX_ITER, 1000, 1e-6));
    
    NSLog(@"开始training...");
    svmModel->train(trainingDataMat, ROW_SAMPLE, labelsMat);
    NSLog(@"结束training");
    
    delete []labels;
    for (int i = 0; i != data_count; i++) {
        delete[] trainingData[i];
    }
    delete []trainingData;
    
    mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 在单点触摸时，可以用下面这行代码取出UITouch对象
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

    [self.touchLocationLabel setText:[NSString stringWithFormat:@"(%f, %f)", point.x, point.y]];
    
    // 初始化测试矩阵
    Mat testMat(1, DIMENSION, CV_32FC1);
    testMat.at<float>(0, 0) = point.x/300;
    testMat.at<float>(0, 1) = point.y/600;
    testMat.at<float>(0, 2) = mManager.deviceMotion.attitude.roll;
    
    //std::cout << testMat << std::endl;
    
    float response = svmModel->predict(testMat);
    NSLog(@"prediction result is %f", response);
    
    if (response < 1e-6) {
        [self.touchLocationLabel setText:[NSString stringWithFormat:@"(%f, %f, %f)\nYou may using Left Hand", point.x, point.y, mManager.deviceMotion.attitude.roll]];
    } else {
        [self.touchLocationLabel setText:[NSString stringWithFormat:@"(%f, %f, %f)\nYou may using Right Hand", point.x, point.y, mManager.deviceMotion.attitude.roll]];
    }

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesBegan:touches withEvent:event];
}

@end
