//
//  main.cpp
//  EyeTrack
//
//  Created by 欧长坤 on 21/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//


#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>
#include <queue>
#include <stdio.h>

#include "constants.hpp"
#include "findEyeCenter.hpp"
#include "findEyeCorner.hpp"

/** Function Headers */
void detectAndDisplay( cv::Mat frame );

/** Global variables */
//-- Note, either copy these two files from opencv/data/haarscascades to your current folder, or change these locations
cv::String face_cascade_name = "/Users/ouchangkun/Work/Code/Github/MotionTouch/src/EyeTrack/EyeTrack/res/haarcascade_frontalface_alt.xml";
cv::CascadeClassifier face_cascade;
std::string main_window_name = "Main";
std::string face_window_name = "Face";
std::string left_window_name = "Left";
std::string right_window_name = "Right";
cv::RNG rng(12345);
cv::Mat mainFrame;
cv::Mat skinCrCbHist = cv::Mat::zeros(cv::Size(256, 256), CV_8UC1);

cv::Point leftPupil;
cv::Point rightPupil;

int main( int argc, const char** argv ) {
    cv::VideoCapture capture;
    capture.open(0);
    if (!capture.isOpened()) {
        printf("Can't open camera\n");
        return 1;
    }
    
    cv::Mat raw;
    
    // Load the cascades
    if( !face_cascade.load( face_cascade_name ) ){
        printf("--(!)Error loading face cascade, please change face_cascade_name in source code.\n");
        return -1;
    };
    
    cv::namedWindow(main_window_name,cv::WINDOW_NORMAL);
    cv::moveWindow(main_window_name, 500, 100);
    cv::namedWindow(face_window_name,cv::WINDOW_NORMAL);
    cv::moveWindow(face_window_name, 100, 100);
    cv::namedWindow(right_window_name,cv::WINDOW_NORMAL);
    cv::moveWindow(right_window_name, 500, 500);
    cv::namedWindow(left_window_name,cv::WINDOW_NORMAL);
    cv::moveWindow(left_window_name, 100, 500);
    
    createCornerKernels();
    ellipse(skinCrCbHist, cv::Point(113, 155.6), cv::Size(23.4, 15.2),
            43.0, 0.0, 360.0, cv::Scalar(255, 255, 255), -1);
    
    float mouseX = 0;
    float mouseY = 0;
    float targetMouseX = 0;
    float targetMouseY = 0;
    
//#ifndef WIN32
//    X11Util m_x11Util;
//#endif
    
    // Read the video stream
    while (true) {
        capture >> raw;
        
        if (raw.empty()) {
            printf(" --(!) No captured frame -- Break!");
            break;
        }
        
        // mirror it
        cv::flip(raw, raw, 1);
        raw.copyTo(mainFrame);
        
        detectAndDisplay(raw);
        
//#ifdef WIN32
//        ::SetCursorPos(rightPupil.x, rightPupil.y);
//#else
//        m_x11Util.SetCursorPos(rightPupil.x, rightPupil.y);
//#endif
        
        imshow(main_window_name,mainFrame);
        
        int c = cv::waitKey(1);
        if( (char)c == 'q' ) { break; }
        if( (char)c == 'f' ) {
            imwrite("frame.png", raw);
        }
    }
    
    return 0;
}

void findEyes(cv::Mat frame_gray, cv::Rect face) {
    cv::Mat faceROI = frame_gray(face);
    cv::Mat debugFace = faceROI;
    
    if (kSmoothFaceImage) {
        double sigma = kSmoothFaceFactor * face.width;
        GaussianBlur( faceROI, faceROI, cv::Size( 0, 0 ), sigma);
    }
    //-- Find eye regions and draw them
    int eye_region_width = face.width * (kEyePercentWidth/100.0);
    int eye_region_height = face.width * (kEyePercentHeight/100.0);
    int eye_region_top = face.height * (kEyePercentTop/100.0);
    cv::Rect leftEyeRegion(face.width*(kEyePercentSide/100.0),
                           eye_region_top,eye_region_width,eye_region_height);
    cv::Rect rightEyeRegion(face.width - eye_region_width - face.width*(kEyePercentSide/100.0),
                            eye_region_top,eye_region_width,eye_region_height);
    
    //-- Find Eye Centers
    // TODO: Refactor
    leftPupil = findEyeCenter(faceROI,leftEyeRegion,left_window_name);
    rightPupil = findEyeCenter(faceROI,rightEyeRegion,right_window_name);
    
    // get corner regions
    cv::Rect leftRightCornerRegion(leftEyeRegion);
    leftRightCornerRegion.width -= leftPupil.x;
    leftRightCornerRegion.x += leftPupil.x;
    leftRightCornerRegion.height /= 2;
    leftRightCornerRegion.y += leftRightCornerRegion.height / 2;
    cv::Rect leftLeftCornerRegion(leftEyeRegion);
    leftLeftCornerRegion.width = leftPupil.x;
    leftLeftCornerRegion.height /= 2;
    leftLeftCornerRegion.y += leftLeftCornerRegion.height / 2;
    cv::Rect rightLeftCornerRegion(rightEyeRegion);
    rightLeftCornerRegion.width = rightPupil.x;
    rightLeftCornerRegion.height /= 2;
    rightLeftCornerRegion.y += rightLeftCornerRegion.height / 2;
    cv::Rect rightRightCornerRegion(rightEyeRegion);
    rightRightCornerRegion.width -= rightPupil.x;
    rightRightCornerRegion.x += rightPupil.x;
    rightRightCornerRegion.height /= 2;
    rightRightCornerRegion.y += rightRightCornerRegion.height / 2;
    rectangle(debugFace,leftRightCornerRegion,200);
    rectangle(debugFace,leftLeftCornerRegion,200);
    rectangle(debugFace,rightLeftCornerRegion,200);
    rectangle(debugFace,rightRightCornerRegion,200);
    // change eye centers to face coordinates
    rightPupil.x += rightEyeRegion.x;
    rightPupil.y += rightEyeRegion.y;
    leftPupil.x += leftEyeRegion.x;
    leftPupil.y += leftEyeRegion.y;
    // draw eye centers
    circle(debugFace, rightPupil, 3, 1234);
    circle(debugFace, leftPupil, 3, 1234);
    
    //-- Find Eye Corners
    if (kEnableEyeCorner) {
        cv::Point2f leftRightCorner = findEyeCorner(faceROI(leftRightCornerRegion), true, false);
        leftRightCorner.x += leftRightCornerRegion.x;
        leftRightCorner.y += leftRightCornerRegion.y;
        cv::Point2f leftLeftCorner = findEyeCorner(faceROI(leftLeftCornerRegion), true, true);
        leftLeftCorner.x += leftLeftCornerRegion.x;
        leftLeftCorner.y += leftLeftCornerRegion.y;
        cv::Point2f rightLeftCorner = findEyeCorner(faceROI(rightLeftCornerRegion), false, true);
        rightLeftCorner.x += rightLeftCornerRegion.x;
        rightLeftCorner.y += rightLeftCornerRegion.y;
        cv::Point2f rightRightCorner = findEyeCorner(faceROI(rightRightCornerRegion), false, false);
        rightRightCorner.x += rightRightCornerRegion.x;
        rightRightCorner.y += rightRightCornerRegion.y;
        circle(faceROI, leftRightCorner, 3, 200);
        circle(faceROI, leftLeftCorner, 3, 200);
        circle(faceROI, rightLeftCorner, 3, 200);
        circle(faceROI, rightRightCorner, 3, 200);
    }
    
    imshow(face_window_name, faceROI);
    
    leftPupil.x += face.x;
    leftPupil.y += face.y;
    rightPupil.x += face.x;
    rightPupil.y += face.y;
    //  cv::Rect roi( cv::Point( 0, 0 ), faceROI.size());
    //  cv::Mat destinationROI = mainFrame( roi );
    //  faceROI.copyTo( destinationROI );
}

cv::Mat findSkin(cv::Mat &frame) {
    cv::Mat input;
    cv::Mat output = cv::Mat(frame.rows,frame.cols, CV_8U);
    
    cvtColor(frame, input, cv::COLOR_BGR2YCrCb);
    
    for (int y = 0; y < input.rows; ++y) {
        const cv::Vec3b *Mr = input.ptr<cv::Vec3b>(y);
        //    uchar *Or = output.ptr<uchar>(y);
        cv::Vec3b *Or = frame.ptr<cv::Vec3b>(y);
        for (int x = 0; x < input.cols; ++x) {
            cv::Vec3b ycrcb = Mr[x];
            //      Or[x] = (skinCrCbHist.at<uchar>(ycrcb[1], ycrcb[2]) > 0) ? 255 : 0;
            if(skinCrCbHist.at<uchar>(ycrcb[1], ycrcb[2]) == 0) {
                Or[x] = cv::Vec3b(0,0,0);
            }
        }
    }
    return output;
}

void detectAndDisplay( cv::Mat frame ) {
    std::vector<cv::Rect> faces;
    cv::Mat frame_gray;
    
#if 0
    // WTF
    std::vector<cv::Mat> rgbChannels(3);
    cv::split(frame, rgbChannels);
    frame_gray = rgbChannels[2];
#else
    cvtColor( frame, frame_gray, cv::COLOR_BGR2GRAY );
    //equalizeHist( frame_gray, frame_gray );
    //cv::pow(frame_gray, CV_64F, frame_gray);
#endif
    
    face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2,
                                  0|cv::CASCADE_SCALE_IMAGE|cv::CASCADE_FIND_BIGGEST_OBJECT, cv::Size(150, 150) );
    //  findSkin(mainFrame);
    
    for (int i = 0; i < faces.size(); i++)
    {
        rectangle(mainFrame, faces[i], 1234);
    }
    //-- Show what you got
    if (faces.size() > 0) {
        findEyes(frame_gray, faces[0]);
    }
}