//
//  TestViewController.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 25/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "TestViewController.h"
#import "MotionData.h"
#import "MotionDataTool.h"

#import "PlaySound.h"

#import "MainViewController.h"

@interface TestViewController()
{
    ButtonView *button[10];
    PlaySound *sound;
    
}
@property (strong, nonatomic) IBOutlet UILabel *randomInputNumber;


@property (nonatomic) int count_touch;
@property (nonatomic) BOOL left;

@property (nonatomic, strong) NSMutableArray *samples;
@end


@implementation TestViewController

// ButtonView协议
- (void)onButtonViewClick:(MotionData *)data withFlag:(int)flag{
    if (flag == 0) {
        [sound play];
    }
    
    
    // write to buffer
    if (self.samples) {
        [self.samples addObject:data];
    } else {
        self.samples = [NSMutableArray arrayWithObjects:data, nil];
    }
    
    if (flag == 2) {
        self.count_touch++;
    }
    NSLog(@"count_touch:%d", self.count_touch);
}
- (int)currentUserID {
    return self.current_userID;
}
- (int)whichHand {
    if (self.left == YES) {
        return 0;
    } else {
        return 1;
    }
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
        
//        // 每个用户测试
//        if (self.count_touch < 10 && self.left == YES) {
//            <#statements#>
//        } else if (self.count_touch )

    
    
    if (self.count_touch >= TIMES*6*2){
        // data	persistence once
        #warning still need sqlite transaction optimize
        for (MotionData *data in self.samples) {
            [MotionDataTool insertAllData:data];
        }
        [self.navigationController popViewControllerAnimated:YES];
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
