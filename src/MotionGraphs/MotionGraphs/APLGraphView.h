
/*
     File: APLGraphView.h
 Abstract: Displays a graph of output. This class uses Core Animation techniques to avoid needing to render the entire graph every update.
 
 The APLGraphView needs to be able to update the scene quickly in order to track the data at a fast enough frame rate. There is too much content to draw the entire graph every frame and sustain a high framerate. This class therefore uses CALayers to cache previously drawn content and arranges them carefully to create an illusion that we are redrawing the entire graph every frame.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface APLGraphView : UIView

-(void)addX:(double)x y:(double)y z:(double)z;

@end
