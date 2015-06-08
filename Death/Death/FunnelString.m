//
//  FunnelString.m
//  
//
//  Created by Serge on 2013-07-10.
//
//

#import "FunnelString.h"
#import "OKPoEMMProperties.h"

#import "OKTessFont.h"
#import "TessGlyph.h"

#import "OKWordObject.h"
#import "OKCharObject.h"

//DEBUG settings
static BOOL DEBUG_BOUNDS = NO;

static float WORD_FILL_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static int WORD_ACCURRACY;// iPad 4 iPhone 4



@implementation FunnelString : KineticObject

@synthesize color, width, height, glyphs, value, font, size, bounds, realPos;

- (id) initWithWord:(OKWordObject*)aWordObj font:(OKTessFont*)aFont renderingBounds:(CGRect)aRenderingBounds
{
    self = [super init];
    if(self)
    {
        
        // Properties
        //NSArray *fillClr = [OKPoEMMProperties objectForKey:WordFillColor];
        //NSArray *fillClr = [OKPoEMMProperties objectForKey:TextColor];
        WORD_FILL_COLOR[0] = 0;
        WORD_FILL_COLOR[1] = 0;
        WORD_FILL_COLOR[2] = 0;
        WORD_FILL_COLOR[3] = 1;

        WORD_ACCURRACY = [[OKPoEMMProperties objectForKey:WordTessellationAccurracy] intValue];
        
        // Font
        font = aFont;
        
        // Glyphs
        glyphs = [[NSMutableArray alloc] init];
        
        // Build
        //[self build:aWordObj renderingBounds:aRenderingBounds];
        value = [[NSString alloc] initWithString:aWordObj.word];
        

        int i=0;
        for(OKCharObject *charObj in aWordObj.charObjects)
        {
            //first create a tessglyph
            TessGlyph *glyph = [[TessGlyph alloc] initWithChar:charObj font:font accurracy:WORD_ACCURRACY renderingBounds:aRenderingBounds];
            [glyph setFillColor:WORD_FILL_COLOR];
            
            float x;
            if(i==0)
                x=0;
            else
                x=20;   //p.textWidth(value.substring(i, i));
            
            //then create the funnelglyph
            #warning SM - update the way we create the funnel glyph
            FunnelGlyph *fGlyph = [[FunnelGlyph alloc] initFunnelGlyph:glyph x:0 y:0];
            [glyphs addObject:fGlyph];
            //[glyph release];
            
            i++;
        }
        
            
        // Properties
     /*   opacity = 1.0f;
        fadeInSpeed = 0.05f;
        fadeOutSpeed = 0.01f;

        fadeTo = 1.0f;
        velocity = OKPointMake(0.0f, 0.0f, 0.0f);
        drag = 0.98f;
        bounds = [self getAbsoluteBounds];
       */ 
        // Size
        size = CGSizeMake([aWordObj getWitdh], [aWordObj getHeight]);
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FunnelString *copy = [[[self class] allocWithZone: zone] init];
    
    copy.glyphs = [glyphs copy];
    copy.color = [self color];
    copy.width = [self width];
    copy.height = [self height];
    copy.value = [self value];
    copy.font = [self font];
    copy.size = [self size];
    copy.bounds = bounds;
    copy.realPos = realPos;
    
    return copy;
}


-(void) kill
{
    for(FunnelGlyph *g in glyphs)
        [g kill];
}

-(BOOL) isDead
{
    for(FunnelGlyph *g in glyphs){
        if(![g isDead])
            return false;
    }
    return true;
}

-(float) bottom
{
    //check the position of all glyphs to find the lowest
    float y = FLT_MIN;
    for(FunnelGlyph *g in glyphs)
    {
        if(g.location.y > y)
            y = g.location.y;
    }
    return y;
  
}


#pragma mark - DRAW

- (void) draw
{
    //Transform
    glPushMatrix();
    
    //NSLog(@"Color funnel = %f %f %f", (float)(color>>16 & 0xFF)/255,(float)(color>>8 & 0xFF)/255,(float)(color & 0xFF)/255 );
    glColor4f( (float)(color>>16 & 0xFF)/255, (float)(color>>8 & 0xFF)/255, (float)(color & 0xFF)/255, 1);

    //NSLog(@"Position: %f %f %f", pos.x, pos.y, pos.z);
    //glTranslatef(pos.x, pos.y, pos.z);
    
    glTranslatef(pos.x, pos.y, 0);
    
    glScalef(sca, sca, 0.0);
    for(FunnelGlyph *fg in glyphs)
    {
        [fg draw];
    }
    
    if(DEBUG_BOUNDS) [self drawDebugBounds];
    
    glPopMatrix();
}



- (void) drawDebugBounds
{
    glColor4f(0, 0, 0, 1);
    
    //debug bounding box
    const GLfloat line[] =
    {
        0.0f - (size.width/2.0f) , 0.0f, //point A Bottom left
        0.0f - (size.width/2.0f), size.height, //point B Top left
        size.width/2.0f, size.height, //point C Top Right
        size.width/2.0f, 0.0f, //point D Bottom Right
    };
    
    glVertexPointer(2, GL_FLOAT, 0, line);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
}

- (void) update:(long)dt
{
    [super update:dt];
        
    for(FunnelGlyph *tg in glyphs)
    {
        [tg update:glyphs];
    }

}


#pragma mark - SETTERS

- (void) setPosition:(OKPoint)aPosition {
    [self setPos:aPosition];
    for(FunnelGlyph *aGlyph in glyphs){
        [aGlyph setWordPosX:aPosition.x y:aPosition.y];
        //[aGlyph.value setWordPosX:aPosition.x y:aPosition.y];
    }
}


-(void) setRealPosX:(float)posX y:(float)posY
{
    realPos.x = posX;
    realPos.y = posY;
    for(FunnelGlyph *aGlyph in glyphs){
        [aGlyph.value setWordPosX:posX y:posY];
    }
}


- (void) setGlyphsScaling:(float)aScale
{
    for(FunnelGlyph *aGlyphs in glyphs)
    {
        [aGlyphs.value setSca:aScale];
    }
}

-(void) setTarget:(OKPoint)aTarget m:(float)m o:(float)o //(float x, float y, float m, float o)
{
    for(FunnelGlyph *g in glyphs) {
        [g setTarget:aTarget m:m o:o];
    }
    
}

-(void) setFlock:(float)s a:(float) a c:(float)c m:(float)m
{
    for(FunnelGlyph *g in glyphs){
        [g setFlock:s a:a c:c m:m];
    }
}

#pragma mark - GETTERS

- (CGRect) getAbsoluteBounds
{
    CGRect bnds = CGRectNull;
    
    for(FunnelGlyph *glyph in glyphs)
    {
        if(CGRectIsNull(bnds)) bnds = [glyph.value getAbsoluteBounds];
        else bnds = CGRectUnion(bnds, [glyph.value getAbsoluteBounds]);
    }
    
    return bnds;
}

- (CGSize) getSize { return size; }

- (BOOL) isInside:(OKPoint)pt {// return CGRectContainsPoint([self getAbsoluteBounds], CGPointMake(pt.x, pt.y)); }
    
    BOOL isInside = NO;
    
    for(FunnelGlyph *glyph in glyphs)
    {
        if([glyph.value isInside:CGPointMake(pt.x, pt.y)]) isInside = YES;
    }
    
    
    /*if(pt.x>realPos.x-size.width && pt.x<realPos.x+size.width)
        isInside=YES;
    */
    return isInside;
}

/*- (OKPoint) center
 {
 return OKPointMake(0.0f, 0.0f, 0.0f);
 }*/
- (CMTPVector3D) center { return CMTPVector3DMake(bounds.origin.x, bounds.origin.y, 0);}

- (NSString*) description { return [NSString stringWithFormat:@"VALUE %@ COLOR %f %f %f %f ACCURRACY %i", value, WORD_FILL_COLOR[0], WORD_FILL_COLOR[1], WORD_FILL_COLOR[2], WORD_FILL_COLOR[3], WORD_ACCURRACY]; }

- (NSString*) value { return value; }


-(long long) getMillis{
    long long nowMillis = (long long)([[NSDate date] timeIntervalSince1970])*1000;
    return nowMillis;
}



- (void) dealloc
{
  //  [glyphs release];
  //  [super dealloc];
}

@end


