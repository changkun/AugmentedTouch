//
//  findEyeCorner.hpp
//  EyeTrack
//
//  Created by 欧长坤 on 21/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#ifndef findEyeCorner_hpp
#define findEyeCorner_hpp

#include <opencv2/imgproc/imgproc.hpp>
using namespace cv;

#define kEyeLeft true
#define kEyeRight false

void createCornerKernels();
void releaseCornerKernels();
cv::Point2f findEyeCorner(cv::Mat region,bool left, bool left2);
cv::Point2f findSubpixelEyeCorner(cv::Mat region, cv::Point maxP);

#endif /* findEyeCorner_hpp */
