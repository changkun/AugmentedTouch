//
//  TestViewController.h
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonView.h"

@interface TestViewController : UIViewController <ButtonViewDelegate>

@property (nonatomic) int currentUserID;
@property (nonatomic) int currentTestCount;

@property (nonatomic) int currentHandPosture;
@property (nonatomic) int currentTestCase;
@end
