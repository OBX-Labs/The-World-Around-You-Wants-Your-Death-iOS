//
//  Funnel.h
//  Death
//
//  Created by Serge on 2013-07-10.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

#import "OKTessFont.h"
#import "FunnelString.h"

@interface Funnel : NSObject
{
    //PApplet p;
	//PGraphics[] pg;
    int pgi;
    NSMutableArray *strings;   //will contain a list of FunnelString object
    float alpha;
    int touch;
    float ox, oy;
    float tx, ty;
    float speed;
    
    NSMutableArray *accumulateDrawBuffer;
    
    //PFont font;
    OKTessFont* font;
	int fontSize;
    float fontScale;
	
	NSMutableArray *words;
	int wordIndex;
	
	int rs, re, gs, ge, bs, be, as, ae;
	
	BOOL dying;
    CGRect bounds;
    
}

@property (nonatomic) int touch;
@property (nonatomic, strong) NSMutableArray *strings;

-(id) initFunnelWithWords: (NSMutableArray*) theWords x:(int)x y:(int)y font:(OKTessFont*)aFont fontScale:(float)aFontScale renderingBounds:(CGRect)aRenderingBounds;
-(void) setSpeed:(float)s;
-(void) setColorRange:(long long) s e:(long long)e;
-(void) setTarget:(int)x y:(int)y;
-(void) setSwipeLastString:(bool)swipeDirection;
-(FunnelString*) last;
-(void) next;
-(void) update:(long)dt;
-(void) draw;
- (void)setupFBO;
@end


