//
//  TextLayer.h
//  Death
//
//  Created by Serge on 2013-07-24.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Line.h"

@interface TextLayer : NSObject
{
    NSMutableArray *lines;   //contains the lines
    int size;
    float y;
    float width;
    float height;
    
    // Screen bounds
    CGRect sBounds;
}

@property (nonatomic) float y;
@property (nonatomic, strong) NSMutableArray *lines; 

-(id) initTextLayerWithBounds:(CGRect)aRenderingBounds width:(float)w h:(float)h;
-(void) addLine:(Line*) line;
-(void) draw;
-(void) flicker:(float)speed time:(float)time activity:(float)activity;

@end
