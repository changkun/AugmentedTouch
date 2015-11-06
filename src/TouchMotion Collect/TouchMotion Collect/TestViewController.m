//
//  TestViewController.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 25/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
#import "MotionData.h"
#import "MotionDataTool.h"
#import "MotionBuffer.h"

#import "PlaySound.h"

#import "MainViewController.h"

#import "MBProgressHUD.h"

@interface TestViewController()
{
    ButtonView *button[10];
    PlaySound *sound;
    
    CMMotionManager *mManager;
    
    MotionBuffer *devMotionBuffer;
    MotionBuffer *gyroBuffer;
    MotionBuffer *accBuffer;
    
}
@property (strong, nonatomic) IBOutlet UILabel *randomInputNumber;


@property (nonatomic) int count_touch;
@property (nonatomic) BOOL left;

@property (nonatomic, strong) NSMutableArray *samples;

@property (nonatomic, strong) NSMutableArray *bufferSamples;
@end


@implementation TestViewController

// ButtonView protocol
- (void)onButtonViewClick:(MotionData *)data withFlag:(int)flag{
    if (flag == 0) {
        [sound play];
        
        // 考虑concurrency并发性
        // TODO: 写入tap触发时的缓存
//        for (int i = 0; i < 50; i++) {
//            NSLog(@"devMotionBuffer[x:%f, y:%f, z:%f]", [devMotionBuffer getXbyIndex:i], [devMotionBuffer getYbyIndex:i], [devMotionBuffer getZbyIndex:i]);
//            NSLog(@"accBuffer[x:%f, y:%f, z:%f]", [accBuffer getXbyIndex:i], [accBuffer getYbyIndex:i], [accBuffer getZbyIndex:i]);
//            NSLog(@"gyroBuffer[x:%f, y:%f, z:%f]", [gyroBuffer getXbyIndex:i], [gyroBuffer getYbyIndex:i], [gyroBuffer getZbyIndex:i]);
//            
//        }
        
        // 1. 记录当前左右手情况
        if (self.left) {
            [devMotionBuffer setHand:0 andUserID:self.current_userID andTapIndex:self.count_touch]; // 0 means left
            [accBuffer setHand:0 andUserID:self.current_userID andTapIndex:self.count_touch];
            [gyroBuffer setHand:0 andUserID:self.current_userID andTapIndex:self.count_touch];
        } else {
            [devMotionBuffer setHand:1 andUserID:self.current_userID andTapIndex:self.count_touch]; // 1 means right
            [accBuffer setHand:1 andUserID:self.current_userID andTapIndex:self.count_touch];
            [gyroBuffer setHand:1 andUserID:self.current_userID andTapIndex:self.count_touch];
        }

        // 2. 将整个buffer保存下来
        MotionBuffer *bufferObjectDev = [[MotionBuffer alloc] initWithBuffer:devMotionBuffer];
        MotionBuffer *bufferObjectAcc = [[MotionBuffer alloc] initWithBuffer:accBuffer];
        MotionBuffer *bufferObjectGyro = [[MotionBuffer alloc] initWithBuffer:gyroBuffer];
        if (self.bufferSamples) {
            [self.bufferSamples addObject:bufferObjectDev];
            [self.bufferSamples addObject:bufferObjectAcc];
            [self.bufferSamples addObject:bufferObjectGyro];
        } else {
            self.bufferSamples = [NSMutableArray arrayWithObjects:bufferObjectDev, bufferObjectAcc, bufferObjectGyro, nil];
        }
        
//        [devMotionBuffer writeToSQLWithCurrentUserID:self.current_userID andTapCount:self.count_touch];
//        [accBuffer writeToSQLWithCurrentUserID:self.current_userID andTapCount:self.count_touch];
//        [gyroBuffer writeToSQLWithCurrentUserID:self.current_userID andTapCount:self.count_touch];
        
    }
    
    // write the moment data to memory buffer
    if (self.samples) {
        [self.samples addObject:data];
    } else {
        self.samples = [NSMutableArray arrayWithObjects:data, nil];
    }
    
    
    if (flag == 2) {
        self.count_touch++;
        
        // TODO: 写入tap结束瞬间的的缓存
        
        
    }
    //NSLog(@"count_touch:%d", self.count_touch);
}
- (int)currentUserID {
    return self.current_userID;
}
- (int)whichHand {
    return !(self.left == YES);
}


#define TIMES 2
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 每个用户录入TIMES*6次左手，TIMES*6次右手
    //
    if (self.count_touch < TIMES*6*2) {
        
        // 当检测到一次能够被6整除时，提醒更换手
        if (self.count_touch%6 == 0) {
            if (self.left == YES) {
                // 如果当前为左手, 则切换右手
                self.left = NO;
                [self updateInputNumberWithHandFlag:1];
                self.view.backgroundColor = [UIColor redColor];
            } else {
                self.left = YES;
                [self updateInputNumberWithHandFlag:0];
                self.view.backgroundColor = [UIColor colorWithRed:74.0/255 green:171.0/255 blue:247.0/255 alpha:1];
            }
        }
    }
    
    if (self.count_touch >= TIMES*6*2){
        // data	persistence once
        #warning still need sqlite transaction optimize
        
        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hub.dimBackground = YES;
        hub.labelText = @"Write data into Database...";
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // 写入所有touch moment数据
            for (MotionData *data in self.samples) {
                [MotionDataTool insertAllData:data];
            }
            
            // 写入所有buffer对象
            for (MotionBuffer* buffer in self.bufferSamples) {
                BOOL result = [MotionDataTool writeBufferDataWithBuffer:buffer];
                if (result) {
                    NSLog(@"成功写入buffer[%d]", [buffer getTapIndex]);
                } else {
                    NSLog(@"写入失败");
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                // 退出当前viewcontroller
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
        
    }
}

// 移除观察者
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"count_touch"];
}


- (void)viewDidLoad {
    self.count_touch = 0;
    self.left = YES;
    //self.current_userID = (int)[MotionDataTool recordSamples]+1;
    NSLog(@"current user id:%d", self.current_userID);
    sound = [[PlaySound alloc] initForPlayingSoundEffectWith:@"Tock_01.wav"];
    
    [self addButtonSubViews];
    [self updateInputNumberWithHandFlag:0];
    [self addObserver:self forKeyPath:@"count_touch" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    // start buffer record, it can save 50 data.
    [self startBufferReco];
    
}

- (void)startBufferReco {
    mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    // 1. 初始化缓存池
    //    缓存池大小可以保存50条历史数据
    devMotionBuffer = [[MotionBuffer alloc] initWithSensorFlag:0];
    accBuffer = [[MotionBuffer alloc] initWithSensorFlag:1];
    gyroBuffer = [[MotionBuffer alloc] initWithSensorFlag:2];

    
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

- (void)updateInputNumberWithHandFlag:(int)flag {
    
    NSString *alterStr;
    NSRange hand_range;
    if (flag == 0) {
        alterStr = [NSString stringWithFormat:@"Plese using Left hand \n Input Numbers:\n%d%d%d%d%d%d", arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10];
        hand_range = [alterStr rangeOfString:@"Left"];
    } else {
        alterStr = [NSString stringWithFormat:@"Plese using Right hand \n Input Numbers:\n%d%d%d%d%d%d", arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10];
        hand_range = [alterStr rangeOfString:@"Right"];
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
    if (flag == 0) {
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor redColor]
                        range:hand_range];
    } else {
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor colorWithRed:74.0/255 green:171.0/255 blue:247.0/255 alpha:1]
                        range:hand_range];
    }

    [self.randomInputNumber setAttributedText:attrStr];
}

- (void)addButtonSubViews {
    
    // 创建按钮
    CGFloat button_width = self.view.frame.size.width/5;
    for (int i = 1; i <= 9; i++) {
        button[i] = [ButtonView buttonViewWithCornerRadius:40
                                                     frame:CGRectMake(self.view.frame.size.width*((i-1)%3+1)/4-button_width/2,
                                                                      self.view.frame.size.height*(4+(i-1)/3)/8-button_width/2,
                                                                      button_width,
                                                                      button_width)
                                           backgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8]
                                                 textColor:[UIColor grayColor]
                                                  textFont:[UIFont fontWithName:@"HelveticaNeue" size:30]
                                                    number:i];
    }
    button[0] = [ButtonView buttonViewWithCornerRadius:40
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
        // 注册观察
        
    }
}



@end
