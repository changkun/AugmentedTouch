//
//  helpers.hpp
//  EyeTrack
//
//  Created by 欧长坤 on 21/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#ifndef helpers_hpp
#define helpers_hpp

using namespace cv;
bool rectInImage(cv::Rect rect, cv::Mat image);
bool inMat(cv::Point p,int rows,int cols);
cv::Mat matrixMagnitude(const cv::Mat &matX, const cv::Mat &matY);
double computeDynamicThreshold(const cv::Mat &mat, double stdDevFactor);

#endif /* helpers_hpp */
