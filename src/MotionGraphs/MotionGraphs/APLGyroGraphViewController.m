
/*
     File: APLGyroGraphViewController.m
 Abstract: View controller to manage display of output from the gyroscope.
 */

#import "APLGyroGraphViewController.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"

static const NSTimeInterval gyroMin = 0.01;

@interface APLGyroGraphViewController ()

@property (nonatomic, weak) IBOutlet APLGraphView *graphView;

@property (nonatomic) NSMutableArray* touchMoveAction;          // 记录一次触摸过程中所有的gyroData
@property (nonatomic) NSMutableArray* recordMotion;

@property (strong, nonatomic) IBOutlet UIButton *leftButton;    // 左边的按钮
@property (strong, nonatomic) IBOutlet UIButton *rightButton;   // 右边的按钮

@property (strong, nonatomic) IBOutlet UILabel *countStatu;     // 按钮被点击的显示标签

@property (nonatomic) int  countClick;
@property (nonatomic) BOOL startStatu;

@property (nonatomic) BOOL deviceMotionLeft;

//@property (nonatomic) CMMotionManager *gManager;

@property (strong, nonatomic) UIButton *showButtonOnLeft;

@end


@implementation APLGyroGraphViewController

- (void)startRecordMotion {
    
    // 设置startStatu状态为YES，回调函数知道可以往recordMotion内加数据
    if (self.startStatu == NO) {
        self.startStatu = YES;
    } else {
        self.startStatu = NO;
        //NSLog(@"%@", self.recordMotion);
    }
    
}


- (IBAction)onLeftButtonClick:(id)sender {
    
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    [mManager startDeviceMotionUpdates];
    
    // 暂时用不到，这里主要是用来测试多次点按时的情况
//    if (self.countClick%2 == 0 && mManager.gyroData.rotationRate.y < -1) {
//        self.startStatu = YES;
//    } else {
//        self.startStatu = NO;
//    }
    
    // 方法1: 记录两次按钮之间点击的gyro值变化情况
    // 想法：左边按钮按下，直到右边按钮被按下，不断收集陀螺仪y轴传感器数据。
    //      如果出现小于-1的值,那么就是左手。
    [self startRecordMotion];
    
    // 方法2: 判断左右按钮被单击时，检查deviceMotion.attitude.roll的值
    // 左手按左按钮时，roll约等于0，按右按钮时，roll接近-1
    // 右手按左按钮时，roll接近+1，按右按钮时，roll约等于0
    // 值0.2是可以被 training 的
    //if ( fabs(mManager.deviceMotion.attitude.roll) < 0.2 && self.deviceMotionLeft == YES ) {
    if ( mManager.deviceMotion.attitude.roll < 0.2 && self.deviceMotionLeft == YES ) {
        self.deviceMotionLeft = YES;
        NSLog(@"YESnt; left: %f", mManager.deviceMotion.attitude.roll);
    } else {
        self.deviceMotionLeft = NO;
        NSLog(@"NO left: %f", mManager.deviceMotion.attitude.roll);
    }
    
    
    // 只进行六次单击
    if (self.countClick < 5) {
        self.countClick++;
        [self.leftButton setEnabled:NO];
        [self.rightButton setEnabled:YES];
        [self.countStatu setText:[NSString stringWithFormat:@"%d,%d", self.countClick, self.startStatu]];
    } else {
        [self.countStatu setText:@"Stop"];
        [self.leftButton setEnabled:NO];
        [self.countStatu setBackgroundColor:[UIColor redColor]];
    }
}

- (IBAction)onRightButtonClick:(id)sender {
    
    // 暂时用不到
//    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
//    if (self.countClick%2 == 1 && mManager.gyroData.rotationRate.y > 1) {
//        self.startStatu = YES;
//    } else {
//        self.startStatu = NO;
//    }
    
    [self startRecordMotion];
    
    // 只进行六次单击
    if (self.countClick < 5) {
        
        self.countClick++;
        [self.rightButton setEnabled:NO];
        [self.leftButton setEnabled:YES];
        [self.countStatu setText:[NSString stringWithFormat:@"%d", self.countClick]];
    
    } else {
        
        if (self.startStatu == YES) {
            [self.countStatu setText:@"Left"];
        } else {
            
            // 在最后一次点按时，检查deviceMotionLeft是否还是YES，如果是，那么说明是左手
            if (self.deviceMotionLeft == YES) {
                [self.countStatu setText:@"Left"];
                
                // 设置按钮pic位置
                self.showButtonOnLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [self.showButtonOnLeft setFrame:CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height/2+30, 50, 30)];
                [self.showButtonOnLeft setTitle:@"click" forState:UIControlStateNormal];
                [self.showButtonOnLeft setBackgroundColor:[UIColor blueColor]];
                [self.view addSubview:self.showButtonOnLeft];
                
                
            } else {
                [self.countStatu setText:@"Right"];
                
                // 设置按钮pic位置
                self.showButtonOnLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [self.showButtonOnLeft setFrame:CGRectMake(self.view.frame.size.width/2+100, self.view.frame.size.height/2+30, 50, 30)];
                [self.showButtonOnLeft setTitle:@"click" forState:UIControlStateNormal];
                [self.showButtonOnLeft setBackgroundColor:[UIColor greenColor]];
                [self.view addSubview:self.showButtonOnLeft];
            }
            
            // 暂时不用
            //[self.countStatu setText:@"Stop"];
        }
        [self.rightButton setEnabled:NO];
        [self.countStatu setBackgroundColor:[UIColor redColor]];
        
    }
}
- (IBAction)onStopUpdateButtonClick:(id)sender {
    
    [self stopUpdates];
}

- (IBAction)onResetButtonClick:(id)sender {
    self.countClick = 0;
    [self.leftButton setEnabled:YES];
    [self.rightButton setEnabled:YES];
    [self.countStatu setBackgroundColor:[UIColor blueColor]];
    [self.countStatu setText:@"Start"];
    [self startUpdatesWithSliderValue:0.01];
    [self.showButtonOnLeft removeFromSuperview];
}

- (void)initProperty {
    // 设置基本属性
    self.touchMoveAction = [[NSMutableArray alloc] init];
    self.recordMotion = [[NSMutableArray alloc] init];
    self.deviceMotionLeft = YES;
    self.startStatu = NO;   // NO 表示不是左手, YES表示左手
    self.countClick = 0;
    [self.leftButton setEnabled:YES];
    [self.rightButton setEnabled:NO];
    
}


// 根据Slide的值调整刷新速度
- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    [self initProperty];
    
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = gyroMin + delta * sliderValue;

    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    APLGyroGraphViewController * __weak weakSelf = self;
    if ([mManager isGyroAvailable] == YES) {
        [mManager setGyroUpdateInterval:updateInterval];
        [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
            [weakSelf.graphView addX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
            [weakSelf setLabelValueX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
            
            if (self.startStatu == YES) {
//                NSArray *gyroXYZ = [[NSArray alloc] initWithObjects:@(mManager.gyroData.rotationRate.x),
//                                    @(mManager.gyroData.rotationRate.y),
//                                    @(mManager.gyroData.rotationRate.z), nil];
                [self.recordMotion addObject:@(mManager.gyroData.rotationRate.y)];
            } else {
                [self.recordMotion removeAllObjects];
            }
            
        }];
    }

    self.updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}


- (void)stopUpdates
{
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    if ([mManager isGyroActive] == YES) {
        [mManager stopGyroUpdates];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"开始触摸");
    [self.touchMoveAction removeAllObjects];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"结束触摸");
    NSLog(@"%@", self.touchMoveAction);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 在单点触摸时，可以用下面这行代码取出UITouch对象
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
//    NSLog(@"触摸移动中..当前坐标为：(%f, %f), 当前gyro值为(%.1f,%.1f,%.1f)", point.x, point.y,
//          mManager.gyroData.rotationRate.x,
//          mManager.gyroData.rotationRate.y,
//          mManager.gyroData.rotationRate.z);
    NSLog(@"(%.2f,%.2f,%.2f,%.2f,%.2f)", point.x, point.y,
          mManager.deviceMotion.attitude.roll,
          mManager.deviceMotion.attitude.pitch,
          mManager.deviceMotion.attitude.yaw);
    
    NSArray *gyroXYZ = [[NSArray alloc] initWithObjects:@(mManager.gyroData.rotationRate.x),
                                                        @(mManager.gyroData.rotationRate.y),
                                                        @(mManager.gyroData.rotationRate.z), nil];
    [self.touchMoveAction addObject:gyroXYZ];
}



@end
