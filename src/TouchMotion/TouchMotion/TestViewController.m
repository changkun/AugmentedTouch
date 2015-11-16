//
//  TestViewController.m
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "TestViewController.h"
#import "PlaySound.h"
#import "AppDelegate.h"
#import <CoreMotion/CoreMotion.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#import "MotionData.h"
#import "MotionBuffer.h"

#import "MBProgressHUD.h"
#import "SQLiteTool.h"

@interface TestViewController ()
{
    NSArray *numberSeries;
    ButtonView *button[10];
    
    CMMotionManager *mManager;
    
    // 随机数 --> Plist文件 or 自行生成
    NSMutableArray *testNumberArray;
    
    // MotionBuffer缓存
    MotionBuffer *devMotionBuffer;
    MotionBuffer *accBuffer;
    MotionBuffer *gyroBuffer;
    
    PlaySound *buttonSound;
    
}

@property (nonatomic) int tapCount;

@property (strong, nonatomic) IBOutlet UILabel *randomInputNumber;

@property (strong, nonatomic) NSMutableArray *motionDataPool;
@property (strong, nonatomic) NSMutableArray *motionBufferPool;

@end

@implementation TestViewController



-(void)viewDidLoad {
    [self loadTestNumberSeries];
    
    self.tapCount = 0;
    buttonSound = [[PlaySound alloc] initForPlayingSoundEffectWith:@"Tock_01.wav"];
    [self addButtonSubViews];
    
    // update alter label
    [self updateInputNumberWithHandPosture:self.currentHandPosture andTestCase:self.currentTestCase andCurrentTapCount:self.tapCount];
    // add tapCount observer
    [self addObserver:self forKeyPath:@"tapCount" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    // start buffer record, it can save 50 data.
    [self startBufferReco];
    
}

// 移除tapCount观察者
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"tapCount"];
}

- (void)startBufferReco {
    mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    // 1. 初始化缓存池
    //    缓存池大小可以保存50条历史数据
    devMotionBuffer = [[MotionBuffer alloc] initWithUserID:self.currentUserID
                                              andTestCount:self.currentTestCount
                                               andTestCase:self.currentTestCase
                                               andTapCount:self.tapCount
                                             andSensorFlag:0
                                            andHandPosture:self.currentHandPosture];
    accBuffer = [[MotionBuffer alloc] initWithUserID:self.currentUserID
                                        andTestCount:self.currentTestCount
                                         andTestCase:self.currentTestCase
                                         andTapCount:self.tapCount
                                       andSensorFlag:1
                                      andHandPosture:self.currentHandPosture];
    gyroBuffer = [[MotionBuffer alloc] initWithUserID:self.currentUserID
                                         andTestCount:self.currentTestCount
                                          andTestCase:self.currentTestCase
                                          andTapCount:self.tapCount
                                        andSensorFlag:2
                                       andHandPosture:self.currentHandPosture];
    
    // 2. 设置传感记录器
    NSTimeInterval delta = 0.01;
    [mManager setDeviceMotionUpdateInterval:delta];
    [mManager setAccelerometerUpdateInterval:delta];
    [mManager setGyroUpdateInterval:delta];
    
    // 3. 每次数据更新时将传感数据写入缓存
    [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        // 写gyro数据进buffer
        [gyroBuffer addX:gyroData.rotationRate.x Y:gyroData.rotationRate.y Z:gyroData.rotationRate.z];
    }];
    [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        // 写acc数据进buffer
        [accBuffer addX:accelerometerData.acceleration.x Y:accelerometerData.acceleration.y Z:accelerometerData.acceleration.z];
    }];
    [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        // 写motion数据进buffer
        [devMotionBuffer addX:motion.attitude.roll Y:motion.attitude.pitch Z:motion.attitude.yaw];
    }];
    
}

// 目前来说=6
#define XTIMES testNumberArray.count
#define YTIMES 5
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 观察到tapcount变化时候，进入这个方法
    // 每输入6次之后产生一次变化，每产生6*YTIMES次后更换一次PIN码
    if (self.tapCount%6 == 0 && self.tapCount < 6*XTIMES*YTIMES) {
        [self updateInputNumberWithHandPosture:self.currentHandPosture andTestCase:self.currentTestCase andCurrentTapCount:self.tapCount/(6*YTIMES)];
        int red, green, blue;
        do {
            red = arc4random()%255;
            green = arc4random()%255;
            blue = arc4random()%255;
        } while (!red && !green && !blue);
        self.view.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    }
    
    
    
    // 当tapcount大于某个值时，退出并写入数据
    if (self.tapCount >= 6*XTIMES*YTIMES) {
        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hub.dimBackground = YES;
        hub.labelText = @"Writing data into Database...";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // SQL Transaction Optimize
            [SQLiteTool beginService];
            // 写入所有touch moment数据
            for (MotionData *data in self.motionDataPool) {
                [SQLiteTool wirteDataWithMotionData:data];
            }
            
            // 写入所有buffer对象
            for (MotionBuffer* buffer in self.motionBufferPool) {
                BOOL result = [SQLiteTool writeBufferWithMotionBuffer:buffer];
                if (result) {
                    NSLog(@"成功写入buffer[%d]", buffer.tapCount);
                } else {
                    NSLog(@"写入失败");
                }
            }
            [SQLiteTool commitService];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"退出测试");
                // 退出当前viewcontroller
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
}


#define RANDOM_XTIMES 6
- (void)loadTestNumberSeries {
    // 获得随机数字
    if (self.currentTestCase == 1) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"NumberSeries" ofType:@"plist"];
        testNumberArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    } else {
        testNumberArray = [NSMutableArray array];
        for (int i = 0; i < RANDOM_XTIMES; i++) {
            NSString *randomNumberStr = [NSString stringWithFormat:@"%d%d%d%d%d%d",
                                         arc4random()%10,
                                         arc4random()%10,
                                         arc4random()%10,
                                         arc4random()%10,
                                         arc4random()%10,
                                         arc4random()%10];
            [testNumberArray addObject:randomNumberStr];
        }
    }
    NSLog(@"%@", testNumberArray);
}

// 根据handposture设置提示label
- (void)updateInputNumberWithHandPosture:(int)flag andTestCase:(int)testcase andCurrentTapCount:(int)tap {
    
    NSString *alterStr;
    NSRange hand_range;
    
    switch (flag) {
        case 0:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Left Thumb", testNumberArray[tap]];
            hand_range = [alterStr rangeOfString:@"Left Thumb"];
            break;
        case 1:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Right Thumb", testNumberArray[tap]];
            hand_range = [alterStr rangeOfString:@"Right Thumb"];
            break;
        case 2:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Left Index", testNumberArray[tap]];
            hand_range = [alterStr rangeOfString:@"Left Index"];
            break;
        case 3:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Right Index", testNumberArray[tap]];
            hand_range = [alterStr rangeOfString:@"Right Index"];
            break;
        default:
            break;
    }
    
    // 调整数字大小
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:alterStr];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:35.0f]
                    range:NSMakeRange([alterStr length]-6, 6)];
    
    // 设置富文本提醒
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:30.0f]
                    range:hand_range];
    [attrStr addAttribute:NSUnderlineStyleAttributeName
                    value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                    range:hand_range];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor redColor]
                    range:hand_range];
    
    [self.randomInputNumber setAttributedText:attrStr];
}
- (NSString*)hardwareString {
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}
// 添加键盘布局
- (void)addButtonSubViews {
    
    // 创建按钮
    CGFloat button_width = self.view.frame.size.width/5;
    
    int radius = 40;
    if ([[self hardwareString] isEqualToString:@"iPhone7,1"]) {
        radius = 40;
    } else if ([[self hardwareString] isEqualToString:@"iPhone5,2"]) {
        radius = 30;
    }
    NSLog(@"%@", [self hardwareString]);
    
    for (int i = 1; i <= 9; i++) {
        button[i] = [ButtonView buttonViewWithCornerRadius:radius
                                                     frame:CGRectMake(self.view.frame.size.width*((i-1)%3+1)/4-button_width/2,
                                                                      self.view.frame.size.height*(4+(i-1)/3)/8-button_width/2,
                                                                      button_width,
                                                                      button_width)
                                           backgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8]
                                                 textColor:[UIColor grayColor]
                                                  textFont:[UIFont fontWithName:@"HelveticaNeue" size:30]
                                                    number:i];
    }
    button[0] = [ButtonView buttonViewWithCornerRadius:radius
                                                 frame:CGRectMake(self.view.frame.size.width*2/4-button_width/2,
                                                                  self.view.frame.size.height*7/8-button_width/2,
                                                                  button_width,
                                                                  button_width)
                                       backgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8]
                                             textColor:[UIColor grayColor]
                                              textFont:[UIFont fontWithName:@"HelveticaNeue" size:30]
                                                number:0];
    for (int i = 0; i < 10; i++) {
        [self.view addSubview:button[i]];
        // 注册代理
        button[i].delegate = self;
    }
}

#pragma mark - ButtonView Protocol
- (void)onButtonViewClick:(MotionData *)data withMovingFlag:(int)movingFlag {
    
    if (movingFlag == 0) {
        [buttonSound play];
        
        // 1. 记录当前姿势的进buffer
        [devMotionBuffer setUserID:self.currentUserID andTestCount:self.currentTestCount andTestCase:self.currentTestCase andTapCount:self.tapCount andHandPosture:self.currentHandPosture];
        [accBuffer setUserID:self.currentUserID andTestCount:self.currentTestCount andTestCase:self.currentTestCase andTapCount:self.tapCount andHandPosture:self.currentHandPosture];
        [gyroBuffer setUserID:self.currentUserID andTestCount:self.currentTestCount andTestCase:self.currentTestCase andTapCount:self.tapCount andHandPosture:self.currentHandPosture];
        
        // 2. 将整个buffer保存下来
        MotionBuffer *bufferObjectDev = [[MotionBuffer alloc] initWithBuffer:devMotionBuffer];
        MotionBuffer *bufferObjectAcc = [[MotionBuffer alloc] initWithBuffer:accBuffer];
        MotionBuffer *bufferObjectGyro = [[MotionBuffer alloc] initWithBuffer:gyroBuffer];
        if (self.motionBufferPool) {
            [self.motionBufferPool addObject:bufferObjectDev];
            [self.motionBufferPool addObject:bufferObjectAcc];
            [self.motionBufferPool addObject:bufferObjectGyro];
        } else {
            self.motionBufferPool = [NSMutableArray arrayWithObjects:bufferObjectDev, bufferObjectAcc, bufferObjectGyro, nil];
        }
        NSLog(@"%@", bufferObjectDev);
        NSLog(@"%@", bufferObjectAcc);
        NSLog(@"%@", bufferObjectGyro);
    }
    
    // write the moment data to memory buffer
    if (self.motionDataPool)
        [self.motionDataPool addObject:data];
    else
        self.motionDataPool = [NSMutableArray arrayWithObjects:data, nil];
    
    if (movingFlag == 2) {
        self.tapCount++;
    }
}
- (int)currentTapCount {
    return self.tapCount;
}

@end
