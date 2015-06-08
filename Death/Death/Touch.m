//
//  Touch.m
//  Rattlesnakes
//
//  Created by Serge on 2013-05-10.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "Touch.h"

@implementation Touch

@synthesize x, y, touchID, start, delay, bites;
/**
 * Constructor.
 * @param id id
 * @param x x position
 * @param y y position
 */
-(id) initWithTouch:(int)aTouchId x:(float)posx y:(float)posy start:(long long)touchStart
{
    NSLog(@"Init touch: %f, %f", posx, posy);
    touchId = aTouchId;
    x = posx;
    y = posy;
    start = touchStart;
    
    return self;
}

/**
 * Set the position.
 * @param x x position
 * @param y y position
 */
-(void) set:(float)posx y:(float) posy {
    lx = x;
    ly = y;
    x = posx;
    y = posy;
}


-(float) getX
{
    return x;
}


-(float) getY{
    return y;
}

-(float) getOX
{
    return ox;
}


-(float) getOY{
    return oy;
}

-(float) getDX
{
    return x-lx;
}


-(float) getDY{
    return y-ly;
}

-(float) getODX
{
    return x-ox;
}


-(float) getODY{
    return y-oy;
}



-(int) getTouchId{
    return touchId;
}

@end
