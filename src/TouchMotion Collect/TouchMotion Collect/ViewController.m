//
//  ViewController.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 24/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MotionData.h"
#import "MotionDataTool.h"
#import "ButtonView.h"

#import "SVMModel.h"

@interface ViewController ()
{
    CMMotionManager *mManager;
}
@property (nonatomic, assign) NSInteger sampleNumber;
@property (strong, nonatomic) IBOutlet UILabel *sampleDisplay;
@end

@implementation ViewController

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
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.sampleNumber = [MotionDataTool recordSamples];
    [self.sampleDisplay setText:[NSString stringWithFormat:@"Current Sample Number:\n\n%ld", (long)self.sampleNumber]];
}

- (IBAction)onStartButton:(id)sender {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 在单点触摸时，可以用下面这行代码取出UITouch对象
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

}

@end
