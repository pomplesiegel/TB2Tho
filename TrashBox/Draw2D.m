//
//  Draw2D.m
//  GraphDraw
//
//  Created by Ian Donovan, Dan Raisbeck, and Michael Siegel
//  Copyright (c) 2012 Possum Kingdom. All rights reserved.
//

#import "Draw2D.h"

//Buncha constants
#define datapoints 16//16
#define granularity 2048//2520
#define granularity2 15
#define totalpoints datapoints*granularity
#define averagepoints 9
#define averagepoints2 75
#define bits16 65536
#define shift16 32768
#define MAXVAL 32768

@implementation Draw2D

//Global variables? FUCK THE POLICE.
float lut[bits16];
float lutfake[bits16];
CGPoint graph[datapoints];
CGPoint points[shift16];
CGPoint averaged[datapoints*granularity];
CGFloat width;
CGFloat height;
int divisor;
bool setup;
bool smoothing;     //pre-splining smoothing
bool smoothing2;    //post-splining smoothing
CGContextRef context;
graphFFT *FFTview;


//Toggle dem smooves
- (void)toggleSmooth1:(bool)state
{
    smoothing = state;
    [self setNeedsDisplay];
}
- (void)toggleSmooth2:(bool)state
{
    smoothing2 = state;
    [self setNeedsDisplay];
}

- (void)resetCurve
{
    setup = FALSE;
    [self setNeedsDisplay];
}

//Gonna have to look in to this; empty if statement
- (id)initWithFrame:(CGRect)frame
{
    smoothing = false;
    smoothing2 = false;
    setup = FALSE;
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (float *)getLUTPointer
{
    return lut;
    //return lutfake;
}

-(void)setFFTPointer:(graphFFT*)graph
{
    FFTview = graph;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect
{
    //Set up some of those variables for drawing
    width = self.frame.size.width;
    height = self.frame.size.height;
    divisor = width / datapoints;
    context = UIGraphicsGetCurrentContext();

    //Nice naming convention
    int count = 0;

    
    //draw vertical bars to separate datapoints
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context,[UIColor greenColor].CGColor);
    for(int i=0; i<=datapoints; i++)
    {
        CGFloat vert = width/datapoints*i;
        CGContextMoveToPoint(context, vert,0);
        CGContextAddLineToPoint(context, vert, height);
    }
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    
    
    //initialize the graph variable to a linear function
    if(setup == false)
    {  
        for(int i=0; i<datapoints; i++)
        {
            //special x values to allow data points to fall between vertical bars
            CGFloat vert = width/datapoints*(i+0.5f);
            graph[i].x = vert;
            graph[i].y = height - height/width * vert;
        }
        for(int i=0; i<bits16; i++) {
            lutfake[i] = i-shift16;
        }
        setup = true;
    }
    
    //set up initial point for drawing
    CGPoint pi;
    CGContextSetLineWidth(context, 4.0);
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);

    //count = datapoints;
    
    //pre-splining smoothing
    if (smoothing == true) {
        for(int i=0; i<datapoints; i++) {
            int j = i - averagepoints/2;
            averaged[i].y = 0;
            averaged[i].x = graph[i].x;
            while(j<(i+averagepoints/2)) {
                if(j<0) {
                    averaged[i].y += height;
                }
                else {
                    averaged[i].y += graph[i].y;
                }
                j++;
            }
            averaged[i].y = averaged[i].y / averagepoints;
        }
    }
    /*
    for(int i = 1; i<2*datapoints; i++) {
        pi.x = 0.0f + i/2.0f;
        pi.y = height - height/width * i/2.0f;
        points[i] = pi;
    }
    */
        
    //This smooths out the graph by interpolating curves between points
    for(int i=0; i<datapoints; i++) {
        CGPoint p0, p1, p2, p3;
        
        //If first index, use mirrored point to help calculate smoothed line
        if(smoothing == true) {
            if(i==0) {
                p0.x = -1 * averaged[0].x;
                p0.y = 2*height - averaged[0].y;
            }
            else {
                p0 = averaged[i-1];
            }
            p1 = averaged[i];
            p2 = averaged[i+1];
            p3 = averaged[i+2];
        }
        else {
            if(i==0) {
                p0.x = -1 * graph[0].x;
                p0.y = 2*height - graph[0].y;
                p1 = graph[i];
                p2 = graph[i+1];
                p3 = graph[i+2];
                //NSLog(@"slope: p1/p0: %f",(p1.y-p0.y)/(p1.x-p0.x));
            }
            else if (i==datapoints-2) {
                p0 = graph[i-1];
                p1 = graph[i];
                p2 = graph[i+1];
                p3.x = width/datapoints*(datapoints+0.5);
                p3.y = p1.y * -1.0f;
            }
            else if(i==datapoints-1) {
                p0 = graph[i-1];
                p1 = graph[i];
                p2.x = width/datapoints*(datapoints+0.5);
                p2.y = p1.y * -1.0f;
                p3.x = width/datapoints*(datapoints+1.5);
                p3.y = p0.y * -1.0f;
            }
            else {
                p0 = graph[i-1];
                p1 = graph[i];
                p2 = graph[i+1];
                p3 = graph[i+2];
            }
        }
        
        
        for(int j = 1; j < granularity; j++) {
            float t = (float) j * (1.0f / (float) granularity);
            float tt = t*t;
            float ttt = tt * t;
            
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            points[count].x = pi.x;
            
            //must account for boundary conditions
            if(pi.y < 0.0f) {
                points[count].y = 0.0f;
            }
            else if (pi.y > height) {
                points[count].y = height;
            }
            else {
                points[count].y = pi.y;
            }
            count++;
        }
        points[count] = p2;
        count++;
    }
    //NSLog(@"Count = %d", count);
    
    //post-splining smoothing
    if(smoothing2 == true) {
        for(int i = 0; i<count; i++) {
            int j = i - averagepoints2/2;
            averaged[i].y = 0;
            averaged[i].x = points[i].x;
            while(j<(i+averagepoints2/2)) {
                if(j<0) {
                    averaged[i].y += height;
                }
                else {
                    averaged[i].y += points[i].y;
                }
                j++;
            }
            averaged[i].y = averaged[i].y / averagepoints2;
        }
        for(int i = 0; i<count; i++) {
            points[i] = averaged[i];
        }

    }
    //draw final graph
    CGContextMoveToPoint(context, 0.0f, height);
    lut[shift16] = 0.0f;
    for(int i = 1; i<count/8;i++) {
        CGContextAddLineToPoint(context, points[i*8].x, points[i*8].y);
    }
    for(int i = 1; i<count; i++) {
        CGFloat y = points[i].y;
        //CGContextAddLineToPoint(context, points[i].x, points[i].y);
        if(y <= 0.0f) {
            lut[shift16+i] = 1.0f * (MAXVAL-1);
            lut[shift16-i] = -1.0f * MAXVAL;
        }
        else if (pi.y > height) {
            lut[shift16+i] = 0.0f;
            lut[shift16-i] = 0.0f;
        }
        else {
            float tempval = -1 * ((y/height - 1)*MAXVAL + 1025);
            lut[shift16+i] = tempval;
            lut[shift16-i] = tempval * -1;
        }
        
    }
    lut[0] = lut[1];
    CGContextStrokePath(context);
    //NSLog(@"Count: %d",count);
    //for(int i = 0; i < bits16/2048; i++) {
        //NSLog(@"fake: %f",lutfake[i*2048]);
        //NSLog(@"real: %f",lut[i*2048]);
    //}
    
    [FFTview calcFFT];
}

//Start dat touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self]; 
    if(point.x >= 0 && point.x < width) {
        int temp = point.x / divisor;
        if(point.y <0) {
            graph[temp].y = 0;
        }
        else if(point.y > height) {
            graph[temp].y = height;
        }
        else {
            graph[temp].y = point.y;
        }
    }
    [self setNeedsDisplay];
}

//Move dat touch
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(point.x >= 0 && point.x < width) {
        int temp = point.x / divisor;
        if(point.y <0) {
            graph[temp].y = 0;
        }
        else if(point.y > height) {
            graph[temp].y = height;
        }
        else {
            graph[temp].y = point.y;
        }
    }
    [self setNeedsDisplay];
}

//End dat touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(point.x >= 0 && point.x < width) {
        int temp = point.x / divisor;
        if(point.y <0) {
            graph[temp].y = 0;
        }
        else if(point.y > height) {
            graph[temp].y = height;
        }
        else {
            graph[temp].y = point.y;
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}


@end
