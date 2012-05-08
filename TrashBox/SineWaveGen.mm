//
//  SineWaveGen.m
//  TrashBox
//
//  Created by Michael Siegel on 5/8/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "SineWaveGen.h"


#define Fs 20 //20 Hz sampling rate
#define length 21 //21 samples
#define fundamental 1 //Funamental tone, in Hz


@implementation SineWaveGen


-(float*)generateSineWave
{
    
    float x[length];
    
    for(int i=0; i<length; i++)
    {
        x[i] = sinf(2*M_PI*fundamental*((float)i/Fs));
        
        NSLog(@"%f",x[i]);
     
    }

}

@end
