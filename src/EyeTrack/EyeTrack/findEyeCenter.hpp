//
//  findEyeCenter.hpp
//  EyeTrack
//
//  Created by 欧长坤 on 21/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#ifndef findEyeCenter_hpp
#define findEyeCenter_hpp

#include <opencv2/imgproc/imgproc.hpp>
using namespace cv;

cv::Point findEyeCenter(cv::Mat face, cv::Rect eye, std::string debugWindow);

#endif /* findEyeCenter_hpp */
