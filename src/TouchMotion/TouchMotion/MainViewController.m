//
//  ViewController.m
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "SQLiteTool.h"
#import <CoreMotion/CoreMotion.h>

#import "TestViewController.h"


@interface MainViewController ()
{
    CMMotionManager *mManager;
    
    NSMutableArray* strUserID;
    NSArray* strPosture;
    NSArray* strTestCase;
}

@property (strong, nonatomic) UIBarButtonItem *pickerDone;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 确定当前用户状态
    NSInteger userNumbers = [SQLiteTool recordUserNumbers];
//    NSInteger userTestCount   = [SQLiteTool currentUserIDsTestCount:0];
    if (userNumbers == 0) {
        [self.userStatus setText:@"Non record"];
    } else {
        [self.userStatus setText:[NSString stringWithFormat:@"Current Sample Number: %ld", (long)userNumbers]];
    }
    
    
    // 定义选择器数据源
    // 1. 从数据库中查找当前有多少个用户
    NSInteger currentUserNumber = [SQLiteTool recordUserNumbers];
    // 2. 初始化strUserID数组
    strUserID = [NSMutableArray array];
    for (NSInteger i = 0; i < currentUserNumber+1; i++) {
        [strUserID addObject:[NSString stringWithFormat:@"%ld", i+1]];
    }
    NSLog(@"%@", strUserID);
    // 3. 定义手势数组
    strPosture = @[@"Left Thumb",
                   @"Right Thumb",
                   @"Left Index Finger",
                   @"Right Index Finger"];
    // 4. 定义测试用例情况
    strTestCase = @[@"Random",
                    @"Preinstall"];
    
    // 定义选择器ToolBar
    UIToolbar* pickerBar = [[UIToolbar alloc] init];
    [pickerBar sizeToFit];
    self.pickerDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(doneClicked)];
    [pickerBar setItems:[NSArray arrayWithObjects:self.pickerDone, nil]];

    
    // 设置UserID选择器
    UIPickerView *userIDPicker = [[UIPickerView alloc] init];
    userIDPicker.tag = 0;
    userIDPicker.dataSource = self;
    userIDPicker.showsSelectionIndicator = YES;
    userIDPicker.delegate = self;
    
    self.userIDTextField.inputView = userIDPicker;
    self.userIDTextField.inputAccessoryView = pickerBar;
    
    // 设置手势选择器
    UIPickerView *posturePicker = [[UIPickerView alloc] init];
    posturePicker.tag = 1;
    posturePicker.dataSource = self;
    posturePicker.showsSelectionIndicator = YES;
    posturePicker.delegate = self;
    self.handPostureTextField.inputView = posturePicker;
    self.handPostureTextField.inputAccessoryView = pickerBar;
    
    // 设置TestCase选择器
    UIPickerView *testCasePicker = [[UIPickerView alloc] init];
    testCasePicker.tag = 2;
    testCasePicker.dataSource = self;
    testCasePicker.showsSelectionIndicator = YES;
    testCasePicker.delegate = self;
    self.TestCaseTextField.inputView = testCasePicker;
    self.TestCaseTextField.inputAccessoryView = pickerBar;
    
    
    // 设置返回功能
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel Test" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    // 设置分享按钮
    UIBarButtonItem *leftShareBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    self.navigationItem.leftBarButtonItem = leftShareBar;
    // 设置数据移除按钮
    UIBarButtonItem *rightTrashBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashBarClick)];
    self.navigationItem.rightBarButtonItem = rightTrashBar;
    
    // 开始追踪设备数据
    mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    NSTimeInterval updateInterval = 0.01;
    
    [mManager setDeviceMotionUpdateInterval:updateInterval];
    [mManager setAccelerometerUpdateInterval:updateInterval];
    [mManager setGyroUpdateInterval:updateInterval];
    
    [mManager startDeviceMotionUpdates];
    [mManager startAccelerometerUpdates];
    [mManager startGyroUpdates];

    
}

- (void)viewDidAppear:(BOOL)animated {
    // 确定当前用户状态
    NSInteger userNumbers = [SQLiteTool recordUserNumbers];
    if (userNumbers == 0) {
        [self.userStatus setText:@"Non record"];
    } else {
        [self.userStatus setText:[NSString stringWithFormat:@"Current Sample Number: %ld", userNumbers]];
    }
    if (userNumbers == strUserID.count) {
        [strUserID addObject:[NSString stringWithFormat:@"%ld", userNumbers+1]];
    }
    
    UIPickerView* pv =  (UIPickerView *)self.userIDTextField.inputView;
    [pv reloadAllComponents];
}

#pragma mark - Segue
- (IBAction)startTestView:(id)sender {
    // 当三个输入框有一个输入框为空时，就不能进入TestView
    if (!self.userIDTextField.text.length || !self.handPostureTextField.text.length || !self.TestCaseTextField.text.length) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please Input Information first!" preferredStyle:UIAlertControllerStyleAlert];
        [alter addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"fuck");
//            [self.useridTextField becomeFirstResponder];
//            self.keyboardDoneButton.enabled = self.useridTextField.text.length;
        }]];
        [self presentViewController:alter animated:YES completion:nil];
        return;
    }
    
    // 执行segue
    [self performSegueWithIdentifier:@"intoTestView" sender:sender];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"intoTestView"]) {
        TestViewController *vc = segue.destinationViewController;
        
        vc.currentUserID      = [self.userIDTextField.text intValue];
        
        if ([self.handPostureTextField.text isEqualToString:@"Left Thumb"]) {
            vc.currentHandPosture = 0;
        } else if ([self.handPostureTextField.text isEqualToString:@"Right Thumb"]){
            vc.currentHandPosture = 1;
        } else if ([self.handPostureTextField.text isEqualToString:@"Left Index Finger"]){
            vc.currentHandPosture = 2;
        } else if ([self.handPostureTextField.text isEqualToString:@"Right Index Finger"]){
            vc.currentHandPosture = 3;
        }
        
        if ([self.TestCaseTextField.text isEqualToString:@"Random"]) {
            vc.currentTestCase = 0;
        } else if ([self.TestCaseTextField.text isEqualToString:@"Preinstall"]){
            vc.currentTestCase = 1;
        }
        
        vc.currentTestCount = (int)[SQLiteTool currentUserIDsTestCount:vc.currentUserID]+1;
    }
}

#pragma mark - NavigationBar Item
// Airdrop sending file
- (void)share {
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TouchWithMotion.sqlite"];
//    NSString *filepath2 = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"NumberSeries.plist"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
//    NSURL *url2 = [NSURL fileURLWithPath:filepath2];
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

- (void)trashBarClick {
    
    // clean all the text from textfield
    self.userIDTextField.text = @"";
    self.handPostureTextField.text = @"";
    self.TestCaseTextField.text = @"";
    
    // remove all data from database
    [SQLiteTool removeAllMotion];
    NSInteger userNumbers = [SQLiteTool recordUserNumbers];
    [self.userStatus setText:[NSString stringWithFormat:@"Current Sample Number: %ld", (long)userNumbers]];
    
    // update userIDTextField.inputView's pickview datasource
    [strUserID removeAllObjects];
    [strUserID addObject:@"1"];
    
    // Reload Datasource
    #pragma mark - this inputview must be a uipickerview
    UIPickerView* pv =  (UIPickerView *)self.userIDTextField.inputView;
    [pv reloadAllComponents];
    
}

- (void)doneClicked {
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}



#pragma mark - PickView Datasource
// 在指定数据源之前，PickView不会显示
// 选择器的列数(Component)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
// 每一列(Component)的行数(row)
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case 0:
            return strUserID.count;
            break;
        case 1:
            return strPosture.count;
        case 2:
            return strTestCase.count;
        default:
            return 1;
            break;
    }
}

#pragma mark - PickView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (pickerView.tag) {
        case 0:
            if (row == strUserID.count-1) {
                return [NSString stringWithFormat:@"%@ (As A New User)", strUserID[row]];
            } else {
                return strUserID[row];
            }
            break;
        case 1:
            return strPosture[row];
            break;
        case 2:
            return strTestCase[row];
            break;
        default:
            return @"";
            break;
    }
    
}

// 某行被选中就会调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (pickerView.tag) {
        case 0:
            [self.userIDTextField setText:[NSString stringWithFormat:@"%@", strUserID[row]]];
            break;
        case 1:
            [self.handPostureTextField setText:[NSString stringWithFormat:@"%@", strPosture[row]]];
            break;
        case 2:
            [self.TestCaseTextField setText:[NSString stringWithFormat:@"%@", strTestCase[row]]];
            break;
        default:
            break;
    }
    
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIPickerView *picker = (UIPickerView *)textField.inputView;
    NSInteger row = [picker selectedRowInComponent:0];
    switch (textField.tag) {
        case 0:
            [textField setText:[NSString stringWithFormat:@"%@", strUserID[row]]];
            break;
        case 1:
            [textField setText:[NSString stringWithFormat:@"%@", strPosture[row]]];
            break;
        case 2:
            [textField setText:[NSString stringWithFormat:@"%@", strTestCase[row]]];
            break;
        default:
            break;
    }
}

#pragma mark - Memory Warning Process
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
