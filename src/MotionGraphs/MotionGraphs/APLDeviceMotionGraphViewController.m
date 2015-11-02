
/*
     File: APLDeviceMotionGraphViewController.m
 Abstract: View controller to manage display of output from the motion detector.
 */

#import "APLDeviceMotionGraphViewController.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"


static const NSTimeInterval deviceMotionMin = 0.01;

typedef enum {
    kDeviceMotionGraphTypeAttitude = 0,
    kDeviceMotionGraphTypeRotationRate,
    kDeviceMotionGraphTypeGravity,
    kDeviceMotionGraphTypeUserAcceleration
} DeviceMotionGraphType;

@interface APLDeviceMotionGraphViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) IBOutletCollection(APLGraphView) NSArray *graphViews;
@property (strong, nonatomic) IBOutlet UILabel *graphLabel;

@property (strong, nonatomic) NSArray *graphTitles;

// 新添加
@property (nonatomic) int  countClick;
@property (nonatomic) BOOL startStatu;
@property (nonatomic) BOOL deviceMotionLeft;

@end



@implementation APLDeviceMotionGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.graphTitles = @[@"deviceMotion.attitude", @"deviceMotion.rotationRate", @"deviceMotion.gravity", @"deviceMotion.userAcceleration"];
    [self showGraphAtIndex:0];
}


- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender
{
    NSUInteger selectedIndex = sender.selectedSegmentIndex;
    [self showGraphAtIndex:selectedIndex];
}


- (void)showGraphAtIndex:(NSUInteger)selectedIndex
{
    [self.graphViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL hidden = (idx != selectedIndex);
        UIView *graphView = obj;
        graphView.hidden = hidden;
    }];

    self.graphLabel.text = [self.graphTitles objectAtIndex:selectedIndex];
}


- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = deviceMotionMin + delta * sliderValue;

    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    APLDeviceMotionGraphViewController * __weak weakSelf = self;

    if ([mManager isDeviceMotionAvailable] == YES) {
        [mManager setDeviceMotionUpdateInterval:updateInterval];
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            // attitude
            [[weakSelf.graphViews objectAtIndex:kDeviceMotionGraphTypeAttitude] addX:deviceMotion.attitude.roll y:deviceMotion.attitude.pitch z:deviceMotion.attitude.yaw];
            //rotationRate
            [[weakSelf.graphViews objectAtIndex:kDeviceMotionGraphTypeRotationRate] addX:deviceMotion.rotationRate.x y:deviceMotion.rotationRate.y z:deviceMotion.rotationRate.z];
            // gravity
            [[weakSelf.graphViews objectAtIndex:kDeviceMotionGraphTypeGravity] addX:deviceMotion.gravity.x y:deviceMotion.gravity.y z:deviceMotion.gravity.z];
            // userAcceleration
            [[weakSelf.graphViews objectAtIndex:kDeviceMotionGraphTypeUserAcceleration] addX:deviceMotion.userAcceleration.x y:deviceMotion.userAcceleration.y z:deviceMotion.userAcceleration.z];

            switch (weakSelf.segmentedControl.selectedSegmentIndex) {
                case kDeviceMotionGraphTypeAttitude:
                    [weakSelf setLabelValueRoll:deviceMotion.attitude.roll pitch:deviceMotion.attitude.pitch yaw:deviceMotion.attitude.yaw];
                    break;
                case kDeviceMotionGraphTypeRotationRate:
                    [weakSelf setLabelValueX:deviceMotion.rotationRate.x y:deviceMotion.rotationRate.y z:deviceMotion.rotationRate.z];
                    break;
                case kDeviceMotionGraphTypeGravity:
                    [weakSelf setLabelValueX:deviceMotion.gravity.x y:deviceMotion.gravity.y z:deviceMotion.gravity.z];
                    break;
                case kDeviceMotionGraphTypeUserAcceleration:
                    [weakSelf setLabelValueX:deviceMotion.userAcceleration.x y:deviceMotion.userAcceleration.y z:deviceMotion.userAcceleration.z];
                    break;
                default:
                    break;
            }
        }];
    }

    self.graphLabel.text = [self.graphTitles objectAtIndex:[self.segmentedControl selectedSegmentIndex]];
    self.updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}


- (void)stopUpdates
{
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    if ([mManager isDeviceMotionActive] == YES) {
        [mManager stopDeviceMotionUpdates];
    }
}


- (IBAction)onLeftButtonClick:(id)sender {
}

- (IBAction)onRightButtonClick:(id)sender {
}

@end
