//
//  constants.hpp
//  EyeTrack
//
//  Created by 欧长坤 on 21/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#ifndef constants_hpp
#define constants_hpp

// Debugging
const bool kPlotVectorField = false;

// Size constants
const int kEyePercentTop = 25;
const int kEyePercentSide = 13;
const int kEyePercentHeight = 30;
const int kEyePercentWidth = 35;

// Preprocessing
const bool kSmoothFaceImage = false;
const float kSmoothFaceFactor = 0.005f;

// Algorithm Parameters
const int kFastEyeWidth = 50;
const int kWeightBlurSize = 5;
const bool kEnableWeight = false;
const float kWeightDivisor = 150.0f;
const double kGradientThreshold = 50.0f;

// Postprocessing
const bool kEnablePostProcess = true;
const float kPostProcessThreshold = 0.97f;

// Eye Corner
const bool kEnableEyeCorner = false;

#endif /* constants_hpp */
