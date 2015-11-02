//
//  TestViewController.h
//  TouchMotion Collect
//
//  Created by 欧长坤 on 25/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonView.h"

@interface TestViewController : UIViewController <ButtonViewDelegate>

@property (nonatomic) int current_userID;

@end
