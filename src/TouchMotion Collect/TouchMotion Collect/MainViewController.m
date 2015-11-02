//
//  ViewController.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 24/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "MotionData.h"
#import "MotionDataTool.h"
#import "ButtonView.h"

#import "SVMModel.h"

#import "TestViewController.h"

@interface MainViewController ()
{
    CMMotionManager *mManager;
}

@property (nonatomic, assign) NSInteger sampleNumber;
@property (strong, nonatomic) IBOutlet UILabel *sampleDisplay;

@property (strong, nonatomic) UIBarButtonItem* keyboardDoneButton;
@end

@implementation MainViewController

- (void)trashBarClick {
    NSLog(@"trashBarClick----test");
    [MotionDataTool removeAllData];
    self.sampleNumber = [MotionDataTool recordNumber];
    [self.sampleDisplay setText:[NSString stringWithFormat:@"Current Sample Number:\n\n%ld", (long)self.sampleNumber]];
}

// airdrop 发送文件
- (void)share {
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TouchWithMotionData.sqlite"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    // Present the controller
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置数据移除按钮
    UIBarButtonItem *rightTrashBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashBarClick)];
    self.navigationItem.rightBarButtonItem = rightTrashBar;
    // 设置返回功能
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel Test" style:UIBarButtonItemStylePlain target:nil action:nil];
    // 设置分享按钮
    UIBarButtonItem *leftShareBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    self.navigationItem.leftBarButtonItem = leftShareBar;
   
    // 开始追踪设备数据
    mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    NSTimeInterval updateInterval = 0.01;
    
    [mManager setDeviceMotionUpdateInterval:updateInterval];
    [mManager setAccelerometerUpdateInterval:updateInterval];
    [mManager setGyroUpdateInterval:updateInterval];
    
    [mManager startDeviceMotionUpdates];
    [mManager startAccelerometerUpdates];
    [mManager startGyroUpdates];
    
    self.sampleNumber = [MotionDataTool recordSamples];
    [self.sampleDisplay setText:[NSString stringWithFormat:@"Current Sample Number:\n\n%ld", (long)self.sampleNumber]];
    
    // set number pad
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:self.keyboardDoneButton, nil]];
    [self.useridTextField addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    self.useridTextField.inputAccessoryView = keyboardDoneButtonView;
    [self.useridTextField setText:[NSString stringWithFormat:@"%d", (int)self.sampleNumber]];
    
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.keyboardDoneButton.enabled = self.useridTextField.text.length;
}

- (void)viewDidAppear:(BOOL)animated {
    self.sampleNumber = [MotionDataTool recordSamples];
    [self.sampleDisplay setText:[NSString stringWithFormat:@"Current Sample Number:\n\n%ld", (long)self.sampleNumber]];
}


- (IBAction)onStartRecord:(id)sender {
    if (self.sampleNumber == 0 && [self.useridTextField.text intValue] == 0) {
        [self performSegueWithIdentifier:@"intoTestView" sender:sender];
        return;
    }
    
    if ([self.useridTextField.text intValue] == (int)self.sampleNumber || [self.useridTextField.text intValue] == (int)self.sampleNumber+1) {
        // 执行segue
        [self performSegueWithIdentifier:@"intoTestView" sender:sender];
        return;
    } else {
        
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"Error" message:@"Only accept current user_id or user_id+1. " preferredStyle:UIAlertControllerStyleAlert];
        [alter addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"fuck");
            [self.useridTextField becomeFirstResponder];
        }]];
        [self presentViewController:alter animated:YES completion:nil];
        
    }
}
- (IBAction)onStartTraining:(id)sender {
    
    if (self.sampleNumber == 0) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please Record Data first!" preferredStyle:UIAlertControllerStyleAlert];
        [alter addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"fuck");
            [self.useridTextField becomeFirstResponder];
            self.keyboardDoneButton.enabled = self.useridTextField.text.length;
        }]];
        [self presentViewController:alter animated:YES completion:nil];
    } else {
        // 执行segue
        [self performSegueWithIdentifier:@"intoTrainView" sender:sender];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"intoTestView"]) {
        TestViewController *vc = segue.destinationViewController;
        vc.current_userID = [self.useridTextField.text intValue];
    }
}

// 定制键盘
- (void)textChanged {
    self.keyboardDoneButton.enabled = self.useridTextField.text.length;
}
- (IBAction)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}
@end
