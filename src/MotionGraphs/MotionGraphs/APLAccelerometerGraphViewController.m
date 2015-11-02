
/*
     File: APLAccelerometerGraphViewController.m
 Abstract: View controller to manage display of output from the accelerometer.
 */

#import "APLAccelerometerGraphViewController.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"

static const NSTimeInterval accelerometerMin = 0.01;

@interface APLAccelerometerGraphViewController ()

@property (nonatomic, weak) IBOutlet APLGraphView *graphView;

@end


@implementation APLAccelerometerGraphViewController

- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = accelerometerMin + delta * sliderValue;

    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    APLAccelerometerGraphViewController * __weak weakSelf = self;
    if ([mManager isAccelerometerAvailable] == YES) {
        [mManager setAccelerometerUpdateInterval:updateInterval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            [weakSelf.graphView addX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z];
            [weakSelf setLabelValueX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z];
        }];
    }

    self.updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}


- (void)stopUpdates
{
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    if ([mManager isAccelerometerActive] == YES) {
        [mManager stopAccelerometerUpdates];
    }
}

@end
