//
//  TestViewController.m
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "TestViewController.h"
#import "PlaySound.h"
#import "MotionBuffer.h"
#import "MBProgressHUD.h"
#import "SQLiteTool.h"

@interface TestViewController ()
{
    NSArray *numberSeries;
    ButtonView *button[10];
    
    // 保存在plist文件中的随机数
    NSMutableArray *testNumberArray;
    
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


#define RANDOM_TIMES 2
-(void)viewDidLoad {
    // 获得随机数字
    if (self.currentTestCase == 1) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"NumberSeries" ofType:@"plist"];
        testNumberArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    } else {
        testNumberArray = [NSMutableArray array];
        for (int i = 0; i < RANDOM_TIMES; i++) {
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
    
    self.tapCount = 0;
    buttonSound = [[PlaySound alloc] initForPlayingSoundEffectWith:@"Tock_01.wav"];
    [self addButtonSubViews];
    [self loadNumberSeries];
    
    // 更新提示界面
    [self updateInputNumberWithHandPosture:0 andTestCase:0 andCurrentTapCount:0];
    // 开启tapCount观察者
    [self addObserver:self forKeyPath:@"tapCount" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
}
// 移除tapCount观察者
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"tapCount"];
}

#define TIMES testNumberArray.count
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 观察到tapcount变化时候，进入这个方法
    
    // 当tapcount大于某个值时，退出并写入数据
    if (self.tapCount >= 6*TIMES) {
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
            
//            // 写入所有buffer对象
//            for (MotionBuffer* buffer in self.bufferSamples) {
//                BOOL result = [MotionDataTool writeBufferDataWithBuffer:buffer];
//                if (result) {
//                    NSLog(@"成功写入buffer[%d]", [buffer getTapIndex]);
//                } else {
//                    NSLog(@"写入失败");
//                }
//            }
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

- (void)loadNumberSeries {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"NumberSeries" ofType:@"plist"];
    numberSeries = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

// 根据handposture设置提示label
- (void)updateInputNumberWithHandPosture:(int)flag andTestCase:(int)testcase andCurrentTapCount:(int)tap {
    
    NSString *alterStr;
    NSRange hand_range;
    
    switch (flag) {
        case 0:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Left Thumb", numberSeries[tap]];
            hand_range = [alterStr rangeOfString:@"Left Thumb"];
            break;
        case 1:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Right Thumb", numberSeries[tap]];
            hand_range = [alterStr rangeOfString:@"Right Thumb"];
            break;
        case 2:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Left Index", numberSeries[tap]];
            hand_range = [alterStr rangeOfString:@"Left Index"];
            break;
        case 3:
            alterStr = [NSString stringWithFormat:@"Please using %@ \n Input Numbers:\n%@",@"Right Index", numberSeries[tap]];
            hand_range = [alterStr rangeOfString:@"Right Index"];
            break;
        default:
            break;
    }
    
//    if (flag == 0) {
//        alterStr = [NSString stringWithFormat:@"Plese using Left hand \n Input Numbers:\n%d%d%d%d%d%d", arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10];
//        hand_range = [alterStr rangeOfString:@"Left"];
//    } else {
//        alterStr = [NSString stringWithFormat:@"Plese using Right hand \n Input Numbers:\n%d%d%d%d%d%d", arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10, arc4random()%10];
//        hand_range = [alterStr rangeOfString:@"Right"];
//    }
    
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
    
//    switch (flag) {
//        case 0:
//            [attrStr addAttribute:NSForegroundColorAttributeName
//                            value:[UIColor redColor]
//                            range:hand_range];
//            break;
//        case 1:
//            break;
//        case 2:
//            break;
//        case 3:
//            break;
//        default:
//            break;
//    }
//    if (flag == 0) {
//        [attrStr addAttribute:NSForegroundColorAttributeName
//                        value:[UIColor redColor]
//                        range:hand_range];
//    } else {
//        [attrStr addAttribute:NSForegroundColorAttributeName
//                        value:[UIColor colorWithRed:74.0/255 green:171.0/255 blue:247.0/255 alpha:1]
//                        range:hand_range];
//    }
    
    [self.randomInputNumber setAttributedText:attrStr];
}

// 添加键盘布局
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
    }
}

#pragma mark - ButtonView Protocol
- (void)onButtonViewClick:(MotionData *)data withMovingFlag:(int)movingFlag {
    //
    if (movingFlag == 0) {
        [buttonSound play];
        
//        // 1. 记录当前姿势的进buffer
//        switch (self.currentHandPosture) {
//            case 0:
//                
//                break;
//            case 1:
//            case 2:
//            case 3:
//            default:
//                break;
//        }
        
        // 2. 将整个buffer保存下来
        
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
