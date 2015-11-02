
/*
     File: APLAppDelegate.h
 Abstract: The app delegate that has an app-wide motion manager.
 */

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface APLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *sharedManager;

@end
