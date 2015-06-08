//
//  Word.h
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KineticObject.h"
#import "CMTraerPhysics.h"
#import "Font.h"

@class Line;
@class OKTessFont;

@class OKWordObject;
@class OKCharObject;

typedef enum
{
    FADE_IN,
    FADE_OUT,
    STABLE,
} FadeState;

@interface Word : KineticObject
{
    // Font
    OKTessFont *font;
    
    // Glyphs
    NSMutableArray *glyphs;
    
    // Properties
    float opacity; // opacity
    float fadeInSpeed, fadeOutSpeed; // fading speeds
    FadeState fadeState; // fading state (in, out, stable)
    float fadeTo; // opacity to fade to
    float fadeInTo;
    //CMTPVector3D position;
    CGRect bounds;
    BOOL seen;
    
 	float contractFac;					//contract factor from 0 to 1, where 1 is most contracted
	float contractAcc;					//contract acceleration
	float contractVel;					//velocity affecting the contract factor
	//PVector contractFrom;				//point to contract away from
    CMTPVector3D contractFrom;
	BOOL contracting;				//true when contracting
	float contractPeriod;				//period of contraction for animation
	long long contractStart;					//when did the contract start
    
    OKPoint velocity; // velocity
    float drag; // drag
    
    CGSize size;
    NSString *value;

    OKPoint realPos;
    
    //New variables for png based font
    Font *defaultFont;
    NSString *currentWord;
	float wordWidth;
	float wordHeight;
    NSMutableArray *visibleLetters;     //contains the bool for visible on/off for each letters of the currentword

       
}


- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds;
- (id) initWithWordandImageFont:(OKWordObject*)aWordObj withFont:(Font *)theFont renderingBounds:(CGRect)aRenderingBounds;

- (void) build:(OKWordObject*)aWordObj renderingBounds:(CGRect)aRenderingBounds;

#pragma mark - DRAW

- (void) draw; // Draws fill and outline
- (void) drawWithImage; //draw with png image font
- (void) drawShadow; //draw the shadow for the word
- (void) drawFill; // Draws fill
- (void) drawOutline; // Draws outline
- (void) drawDebugBounds;
- (void) update:(long)dt;
- (void) updateGlyphs:(long)dt;

#pragma mark - SETTERS

- (void) setPosition:(OKPoint)aPosition;
- (void) setRealPosX:(float)posX y:(float)posY;
- (void) setOpacity:(float)aOpacity;
- (void) fadeTo:(float)aOpacity speed:(float)aSpeed;
- (void) fadeIn:(float)aOpacity;
- (void) fadeOut:(float)aOpacity;
- (void) fadeIn:(float)aOpacity speed:(float)aSpeed;
- (void) fadeOut:(float)aOpacity speed:(float)aSpeed;
- (void) setFadeInSpeed:(float)aFadeInSpeed fadeOutSpeed:(float)aFadeOutSpeed;
- (void) fadeIn:(float)aOpacity speed:(float)aSpeed outspeed:(float)aOutspeed;
- (void) fadeOut;
- (void) setGlyphsScaling:(float)aScale;
-(void) updateContract;
-(void) contract:(float)x y:(float)y;
-(void) decontract;
-(void) setSeen:(BOOL)s;
-(void) flicker:(int)index s:(float)speed t:(float)time a:(float)activity;

#pragma mark - GETTERS

- (CGRect) getAbsoluteBounds;
- (CGSize) getSize;
- (BOOL) isInside:(OKPoint)pt;
//- (OKPoint) center;
- (CMTPVector3D) center;
- (BOOL) isFadingIn;
- (BOOL) isFadingOut;
- (BOOL) isFadedOut;
- (float) opacity;
-(BOOL) isContracted;
-(BOOL) isContracting;
-(BOOL) wasSeen;
-(BOOL) isFading;




- (NSString*) description;
- (NSString*) value;

@end
