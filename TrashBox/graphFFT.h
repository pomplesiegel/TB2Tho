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

@property float* LUT;



-(void)generateSineWave:(float*)x;
-(void)calcFFT;
-(void)setGainValue:(float)val;
-(void)setEffectOnOff:(bool)val;
-(void)setWhichEffect:(int)whichEffect;
-(void)setLUTPointer:(float*)pointer; //set the pointer to the lookup table

@end

typedef struct {
    float gainSliderValue;
    bool effectOnOff;
    int whichEffect;
} EffectStateForGraph;

