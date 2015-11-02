
/*
     File: APLGraphViewController.m
 Abstract: Superclass for the view controllers responsible for all UI interactions with the user and the sensors.
 */

#import "APLGraphViewController.h"
#import "APLGraphView.h"
#import "APLAppDelegate.h"


@interface APLGraphViewController ()

@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;

@property (weak, nonatomic) IBOutlet UISlider *updateIntervalSlider;

@end



@implementation APLGraphViewController


#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.updateIntervalSlider.value = 0.0f;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startUpdatesWithSliderValue:(int)(self.updateIntervalSlider.value * 100)];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopUpdates];
}


#pragma mark - Responding to events

- (IBAction)takeSliderValueFrom:(UISlider *)sender
{
    [self startUpdatesWithSliderValue:(int)(sender.value * 100)];
}


- (void)setLabelValueX:(double)x y:(double)y z:(double)z
{
    self.xLabel.text = [NSString stringWithFormat:@"x: %f", x];
    self.yLabel.text = [NSString stringWithFormat:@"y: %f", y];
    self.zLabel.text = [NSString stringWithFormat:@"z: %f", z];
}

- (void)setLabelValueRoll:(double)roll pitch:(double)pitch yaw:(double)yaw
{
    self.xLabel.text = [NSString stringWithFormat:@"roll: %f", roll];
    self.yLabel.text = [NSString stringWithFormat:@"pitch: %f", pitch];
    self.zLabel.text = [NSString stringWithFormat:@"yaw: %f", yaw];
}


#pragma mark - Update methods stub implementations

- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    return;
}


- (void)stopUpdates
{
    return;
}



@end
