//
//  ViewController.h
//  TouchMotion Collect
//
//  Created by 欧长坤 on 24/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol MainViewControllerDelegate <NSObject>
//
//@optional
//- (void)getUserID
//
//@end

@interface MainViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *useridTextField;

@end

