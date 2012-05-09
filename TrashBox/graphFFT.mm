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
#define fundamental .9375 //Funamental tone, in Hz
#define bitOffset 32768 //offset for 16bit indicies
#define fftLength (length+2)/2 //NOT FFT SIZE!!!! This is the size of FFT magnitude output vector, for a one-sided spectrum
#define sineWaveGain 100 //input gain for sine wave into nonlinear curve
#define fftpoints 8

@implementation graphFFT

@synthesize LUT;

EffectStateForGraph ES;
float x[length]; //Vector for sine values
float xforFFT[length+2]; //Vector for FFT output
float xMagnitude[fftLength];
int max;


CGContextRef context;
CGFloat width;
CGFloat height;
int divisor;

//take in sine wave, apply gain, apply LUT or Atan, DISPLAY, use FFT, DISPLAY

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //initialize
        ES.effectOnOff = 1;
        ES.whichEffect = 0;
        ES.gainSliderValue = .5;
        

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    width = self.frame.size.width;
    height = self.frame.size.height;
    divisor = width / fftpoints;
    context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, divisor/2.0f);
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
    for(int i=0; i<fftpoints; i++) {
        CGFloat vert = width/fftpoints*(i+0.5f);
        CGContextMoveToPoint(context, vert,height);
        //NSLog(@"mag: %f", xMagnitude[i+1]);
        CGContextAddLineToPoint(context, vert, height*(1-xMagnitude[i+1]));
    }
    CGContextStrokePath(context);

}

-(void)calcFFT
{
    
    [self generateSineWave:x]; //place sine samples in x
    
    //Modify x based on the current scenario


    if(ES.effectOnOff && ES.whichEffect==0) //Effect on, GRIT
    {
        for(int i=0; i<length; i++)
            x[i] = atanf((ES.gainSliderValue)*x[i]/22); //scale down for atan?
                    
    }
    
   // NSLog(@"on or off: %i which effect: %i",ES.effectOnOff,ES.whichEffect);
    
    if(ES.effectOnOff && ES.whichEffect==1) //Effect on, DRAW
    {
        
        for(int i=0; i<length; i++) 
        {
            //NSLog(@"old: %f",bitOffset*x[i]);
            x[i] = LUT[(int)((x[i])+bitOffset)]; //scale x to 16 amplitude, offset for 0-65537 //bitOffset/sineWaveGain
            //NSLog(@"LUT: %f",x[i]);
        }
       
    }
    
        
    //OUTPUT X IN THE TIME DOMAIN!!!!
    
    //NOW CALCULATE THE FFT, Find its magnitude, AND EVENTUALLY PLOT THE OUTPUT
    
    for(int i=0; i<length; i++) //copy for FFT array and apply Hann window
        xforFFT[i] = x[i];//(float)((1.-cos(2.*M_PI*(i+.5)/((float)length)))/2.); //or blackman
    RealFFT_forward(xforFFT, length); //Outputs interleaved real & imaginary components of RH spectrum
    
    for(int i=0; i<fftLength; i++) 
    {
        xMagnitude[i] = (sqrtf(pow(xforFFT[2*i],2) + pow(xforFFT[2*i+1],2))/16); //Magnitude by frequency bin        
    }
    
    for(int i=1; i<fftLength; i++) //normalize xMagnitude based on Fundamental's amplitude;
        xMagnitude[i] = xMagnitude[i]/xMagnitude[1];
    
    
    //normalize sine wave by largest positive value
    max = x[0];
    for(int i=0; i<length; i++) //Normalize sine wave
        if(x[i] > max) max = x[i];
    for(int i=0; i<length; i++)
        x[i] = x[i]/max;

    

     
    //NSLog(@"Calc FFT");

    [self setNeedsDisplay];
}

-(void)generateSineWave:(float*)x
{
    
    for(int i=0; i<length; i++)
    {
        x[i] = sineWaveGain*sinf(2*M_PI*fundamental*((float)i/Fs));
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

-(void)setLUTPointer:(float*)pointer;
{
    LUT = pointer;
}

-(float*)getSinePointer
{
    return x;
}

@end