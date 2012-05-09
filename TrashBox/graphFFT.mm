//
//  graphFFT.m
//  TrashBox
//
//  Created by Dan Raisbeck on 5/8/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "graphFFT.h"

#define Fs 15 //15 Hz sampling rate
#define length 16 //16 samples
#define fundamental 1 //Funamental tone, in Hz

@implementation graphFFT


EffectStateForGraph ES; 
float x[length]; //Vector for sine values
float xforFFT[length+2]; //Vector for FFT output


//take in sine wave, apply gain, apply LUT or Atan, DISPLAY, use FFT, DISPLAY


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                      
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




-(void)calcFFT
{
    [self generateSineWave:x]; //place sine samples in x
    
    //Modify x based on the current scenario


    if(ES.effectOnOff && ES.whichEffect==0) //Effect on, GRIT
    {
        for(int i=0; i<length; i++)
            x[i] = atanf((ES.gainSliderValue)*x[i]);
            
    }
    
    if(ES.effectOnOff && ES.whichEffect==1) //Effect on, DRAW
    {
        for(int i=0; i<length; i++)
            //
            ;
            
                
    }
        

    
    //OUTPUT X IN THE TIME DOMAIN!!!!
    
    //NOW CALCULATE THE FFT, AND EVENTUALLY PLOT THE OUTPUT
    
    for(int i=0; i<length; i++) //copy for FFT array
        xforFFT[i] = x[i];
    RealFFT_forward(xforFFT, length); //Outputs interleaved real & imaginary components of RH spectrum
    

}

-(void)generateSineWave:(float*)x
{
    
    for(int i=0; i<length; i++)
    {
        x[i] = sinf(2*M_PI*fundamental*((float)i/Fs));
    }
}




-(void)setGainValue:(float)val {
    ES.gainSliderValue = val;
    [self calcFFT];
}

-(void)setEffectOnOff:(bool)val
{
    ES.effectOnOff = val;
    [self calcFFT];
}

-(void)setWhichEffect:(int)effectChoice
{
    ES.whichEffect = effectChoice;
    [self calcFFT];
}

@end