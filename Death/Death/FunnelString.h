//
//  FunnelString.h
//  
//
//  Created by Serge on 2013-07-10.
//
//

#import <Foundation/Foundation.h>
#import "OKTessFont.h"
#import "KineticObject.h"
#import "FunnelGlyph.h"

@interface FunnelString : KineticObject
{
    NSMutableArray *glyphs;  //will contain a list of FunnelGlyph objects
    int color;
    int width, height;
    NSString *value;
    OKTessFont *font;
    CGSize size; //int size;
    
    // Properties
   /* float opacity;
    float fadeInSpeed, fadeOutSpeed; 

    float fadeTo; // opacity to fade to
    float fadeInTo;
    CGRect bounds;
    BOOL seen;

    OKPoint velocity; // velocity
    float drag; // drag
        
    OKPoint realPos;*/
    CGRect bounds;
    OKPoint realPos;

}

@property (nonatomic) int color, width, height;
@property (nonatomic, strong) NSMutableArray *glyphs;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) OKTessFont *font;
@property (nonatomic) CGSize size;
@property (nonatomic) CGRect bounds;
@property (nonatomic) OKPoint realPos;

- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds;
- (void) update:(long)dt;
- (void) setPosition:(OKPoint)aPosition;
- (void) setTarget:(OKPoint)aTarget m:(float)m o:(float)o;
-(void) setFlock:(float)s a:(float) a c:(float)c m:(float)m;
-(float) bottom;
- (BOOL) isInside:(OKPoint)pt;
- (void) draw;

@end
