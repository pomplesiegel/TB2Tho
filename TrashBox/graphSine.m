//
//  graphSine.m
//  TrashBox
//
//  Created by Dan Raisbeck on 5/9/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import "graphSine.h"

#define sinepoints 16
#define graphpoints 256
#define granularity 16

@implementation graphSine

CGContextRef context;
CGFloat width;
CGFloat height;
int divisor;
float* sine;
CGPoint sinep[sinepoints];
CGPoint graph[graphpoints];

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    width = self.frame.size.width;
    height = self.frame.size.height;
    divisor = width / sinepoints;
    context = UIGraphicsGetCurrentContext();
    
    int count = 0;
    
    for(int i=0; i<sinepoints; i++)
    {
        sinep[i].y = height/2.0f - (height/2.0f * sine[i]);
        sinep[i].x = width/sinepoints * i;
    }
    
    
    for(int i=0; i<sinepoints; i++) {
        CGPoint p0, p1, p2, p3;
        
        if(i==0) {
            p0.x = -1.0f * sinep[1].x;
            p0.y = -1.0f *  sinep[1].y;
            p1 = sinep[i];
            p2 = sinep[i+1];
            p3 = sinep[i+2];
        }
        else if (i==sinepoints-2) {
            p0 = sinep[i-1];
            p1 = sinep[i];
            p2 = sinep[i+1];
            p3.x = width/sinepoints*(sinepoints+0.5);
            p3.y = p1.y * -1.0f;
        }
        else if(i==sinepoints-1) {
            p0 = sinep[i-1];
            p1 = sinep[i];
            p2.x = width/sinepoints*(sinepoints+0.5);
            p2.y = p1.y * -1.0f;
            p3.x = width/sinepoints*(sinepoints+1.5);
            p3.y = p0.y * -1.0f;
        }
        else {
            p0 = sinep[i-1];
            p1 = sinep[i];
            p2 = sinep[i+1];
            p3 = sinep[i+2];
        }
        
        
        for(int j = 1; j < granularity; j++) {
            float t = (float) j * (1.0f / (float) granularity);
            float tt = t*t;
            float ttt = tt * t;
            CGPoint pi;
            
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            graph[count].x = pi.x;
            
            //must account for boundary conditions
            if(pi.y < 0.0f) {
                graph[count].y = 0.0f;
            }
            else if (pi.y > height) {
                graph[count].y = height;
            }
            else {
                graph[count].y = pi.y;
            }
            count++;
        }
        graph[count] = p2;
        count++;
    }
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
    CGContextMoveToPoint(context, 0.0f,height/2.0f);
    for(int i=0; i<count; i++) {
        CGContextAddLineToPoint(context, graph[i].x, graph[i].y);
    }
    CGContextStrokePath(context);
    [self setNeedsDisplay];
}

-(void)setSinePointer:(float *)pointer 
{
    sine = pointer;
}


@end
