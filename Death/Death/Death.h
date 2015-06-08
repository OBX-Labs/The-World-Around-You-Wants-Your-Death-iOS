//
//  Death.h
//  Death
//
//  Created by Serge Maheu on 2013-07-15.
//  Copyright (c) 2013 Serge Maheu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "OKGeometry.h"
#import "EAGLView.h"
#import "SoundManager.h"
#import "Word.h"
#import "Funnel.h"
#import "Touch.h"
#import "Font.h"

@class OKTessFont;
@class OKTextObject;
@class OKSentenceObject;
@class OKCharObject;

@class OKTessData;
@class OKCharDef;
@class Line;

@class PerlinTexture;

@interface Death : NSObject
{
    // Screen bounds
    CGRect sBounds;
    
    // Touches
    NSMutableDictionary *ctrlPts;
    NSMutableDictionary *ctrlPtsTouch;
    NSMutableDictionary *ctrlPtsTouchRemoved;
    
    // Properties
    OKTessFont *font;  //background font
    OKTessFont *funnelFont;
    OKTextObject *text;
    float bgOpacity;
    OKPoint bgCenter;
    NSMutableArray *bgWords;
    
    NSMutableArray *scrollTextLines;
    NSMutableArray *cScrollTextLines;
    NSMutableArray *removableScrollTextLines;
    int scrollTextWords;
    int nextWordLine1;
    int nextWordLine2;
    
    NSMutableArray *wordsLeft;
    NSMutableArray *wordsRight;
    
    //Funnel
    OKTextObject *funnelText;
    OKTextObject *funnelTextRight;
        
    // Animation time tracking
    NSDate *lUpdate;
    NSDate *now;
    long DT;
    int frameCount;
    
    // Blood
    PerlinTexture *blood;
    
    //Particle system
    CMTPParticleSystem *physics;
    

    int textIndex;							//index of the current background text
    NSMutableArray *allTextsObjects;
    
    NSMutableArray *textFiles;              //contains the whole text separated in blocks (array of OKTextObject)
    NSMutableArray *textLines;              //lines of the background texts
    NSMutableArray *textWords;              //words of the background texts

    OKTessFont *textFonts;                      //fonts of the background lines
    //NSMutableArray *textFontSizes;              //fonts of the background lines
	
    NSMutableArray *textWordSpacing;            //word spacing offset for the background lines
    
	int totalWordsSeen;						//counter of total word seen for a page
	int totalWords;							//counter of total words in a page
    OKWordObject *wordTest;
    Word *wordForTest;
    
    long long lastTouch;							//last time there was a touch
	long lastBgSnake;						//last time an idle animatiom started

    BOOL changingLock;					//true (locked) until we get a first touch
	BOOL changing;						//true when we are changing the text
	int changingText;						//index of the changing text
	long long lastChanging;						//last time the text changed
	//int[] textChangingDelays;				//array of text changing delays
    NSMutableArray *textChangingDelays;
	long long nextTextChange;					//time (in millis) when the text is allowed to change
	float textChangeSpeed;					//offset for text change speed used when touching during

    EAGLView *parentEaglView;
    SoundManager *soundManager;
    
    BOOL swipeDirectionRight;
    BOOL swipeOccured;
    
    NSMutableArray *funnels;  //will contain the list of Funnel object
    NSMutableArray *layers;
    
    Touch *firstTouch;              //pointer to first touch object
   // float touchActivity[2];         //activity counter from 0-0.5 for both touch
    float touchActivity;
    long long touchActivityEnd;     //time that touch activity ends
    int touchCount;
    long long lastTouchTimes[2];    //last times touches were added
    long long flickerLastUpdate;   //time of last flicker update

    //png based font.
    Font *currentFont;
    
    NSMutableArray *funnelSounds;
    
    int incrementSpeedLayer;
    
}

- (id) initWithFont:(OKTessFont*)tFont text:(OKTextObject*)textObj andBounds:(CGRect)bounds eaglview:(EAGLView*)aView;
//- (id) initWithFont:(OKTessFont*)tFont text:(OKTextObject*)textObj allTexts:(NSMutableArray*)theTexts andBounds:(CGRect)bounds eaglview:(EAGLView*)aView;
//- (id) initWithBounds:(CGRect)bounds eaglview:(EAGLView*)aView;
- (Line*) createLine:(int)start;

- (long long) getMillis;

-(void) updateFunnelText:(OKTextObject*)textObj;
-(void) updateFunnelTextLeft:(OKTextObject*)textObjLeft right:(OKTextObject*)textObjRight;

#pragma mark - DRAW

- (void) draw;
- (void) update:(long)dt;
- (void) updateText:(long)dt;

#pragma mark - Touches

- (void) setCtrlPts:(int)aID atPosition:(CGPoint)aPosition;
- (void) removeCtrlPts:(int)aID atPosition:(CGPoint)aPosition;

- (void) touchesBegan:(int)aID atPosition:(CGPoint)aPosition;
- (void) touchesMoved:(int)aID atPosition:(CGPoint)aPosition;
- (void) touchesEnded:(int)aID atPosition:(CGPoint)aPosition;
- (void) touchesCancelled:(int)aID atPosition:(CGPoint)aPosition;

@end
