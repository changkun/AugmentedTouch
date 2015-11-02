//
//  SVMModel.h
//  TouchMotion Collect
//
//  Created by 欧长坤 on 28/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MotionData;

@interface SVMModel : NSObject


- (instancetype)initWithMotionData:(NSArray *)data;

// YES means left, and NO means right
- (BOOL)predictionMotionData:(MotionData *)testData;

@end
