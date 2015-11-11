//
//  ViewController.h
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *userIDTextField;

@property (strong, nonatomic) IBOutlet UITextField *handPostureTextField;

@property (strong, nonatomic) IBOutlet UITextField *TestCaseTextField;

@property (strong, nonatomic) IBOutlet UILabel *userStatus;

@end

