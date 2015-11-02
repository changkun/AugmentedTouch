
/*
     File: APLAppDelegate.m
 Abstract: The app delegate that has an app-wide motion manager.
 */

#import "APLAppDelegate.h"

#import "APLGraphViewController.h"

@interface APLAppDelegate ()
{
    CMMotionManager *motionmanager;
}
@end


@implementation APLAppDelegate

- (CMMotionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionmanager = [[CMMotionManager alloc] init];
    });
    return motionmanager;
}


@end
