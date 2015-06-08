//
//  Touch.h
//  Rattlesnakes
//
//  Created by Serge on 2013-05-10.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Touch : NSObject
{
    int touchId;			//id of the touch
	float x, y; 	//x and y positions
    float ox, oy;   //original x and y positions
    float lx, ly;   //last x and y positions
	long long start;		//start time in millis
	//int delay;		//random delay for bite
	//int bites;		//number of active bites on that touch
}

@property float x, y;
//@property (nonatomic) int touchID;
@property int touchID, delay, bites;
@property long long start;

-(id) initWithTouch:(int)aTouchId x:(float)posx y:(float)posy start:(long long)touchStart;
-(void) set:(float)posx y:(float)posy;
-(float) getX;
-(float) getY;
-(float) getOX;
-(float) getOY;
-(float) getDX;
-(float) getDY;
-(float) getODX;
-(float) getODY;
-(int) getTouchId;

@end
