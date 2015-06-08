//
//  FunnelGlyph.h
//  Death
//
//  Created by Serge on 2013-07-11.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "KineticObject.h"
#import "TessGlyph.h"

@interface FunnelGlyph : NSObject
{
    OKPoint location;       //location of glyph withing the word
    OKPoint offset;
	OKPoint velocity;
	OKPoint acceleration;
	OKPoint target;
    OKPoint wordPos;
	float targetMult;
	
	float sepMult, aliMult, cohMult;
	
	float maxforce;    // Maximum steering force
	float maxspeed;    // Maximum speed
    float friction;
	TessGlyph *value;
    
    BOOL dying;
}

@property (nonatomic) OKPoint location;
@property (nonatomic) OKPoint velocity;
@property (nonatomic, strong) TessGlyph *value;

-(id) initFunnelGlyph:(TessGlyph*)v x:(float)x y:(float)y;
-(void) kill;
-(BOOL) isDead;
-(void) setTarget:(OKPoint)aTarget m:(float)m o:(float)o;
-(void) setFlock:(float)s a:(float)a c:(float)c m:(float)m;
-(void) update:(NSMutableArray*) glyphs;
-(void) draw;
-(void) setWordPosX:(float)posX y:(float)posY;

@end
