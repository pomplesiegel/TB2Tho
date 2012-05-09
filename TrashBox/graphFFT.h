//
//  graphFFT.h
//  TrashBox
//
//  Created by Dan Raisbeck on 5/8/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>
#import "simpleFFT.h"

@interface graphFFT : UIView

@property bool onOrOff;
@property (nonatomic) int whichEffect;

-(void)generateSineWave:(float*)x;
-(void)calcFFT;
-(void)setGainValue:(float)val;
-(void)setEffectOnOff:(bool)val;

@end

typedef struct {
    float gainSliderValue;
    bool effectOnOff;
    int whichEffect;
} EffectStateForGraph;

