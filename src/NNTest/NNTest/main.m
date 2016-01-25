//
//  main.m
//  NNTest
//
//  Created by 欧长坤 on 1/20/16.
//  Copyright © 2016 Changkun Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPNeuralNet.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray *netConfig = @[@3, @2, @1];
        double b1, w1, w2, w3, b2, w4, w5, w6, b3, w7, w8 = 100;
        double wgt[] = {b1, w1, w2, w3, b2, w4, w5, w6, b3, w7, w8};
        NSData *weights = [NSData dataWithBytes:wgt length:sizeof(wgt)];
        
        MLPNeuralNet *net = [[MLPNeuralNet alloc] initWithLayerConfig:netConfig weights:weights outputMode:MLPClassification];
        
        net.hiddenActivationFunction = MLPSigmoid;
        net.outputActivationFunction = MLPNone;
        
        double sample[] = {0,1,2};
        NSData *vector = [NSData dataWithBytes:sample length:sizeof(sample)];
        NSMutableData *prediction = [NSMutableData dataWithLength:sizeof(double)];
        
        [net predictByFeatureVector:vector intoPredictionVector:prediction];
        
        double *assessment = (double *)prediction.bytes;
        NSLog(@"model assessment is %f", assessment[0]);
        NSLog(@"%@", net);
        
    }
    return 0;
}
