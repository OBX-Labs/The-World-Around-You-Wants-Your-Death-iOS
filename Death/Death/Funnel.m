//
//  Funnel.m
//  Death
//
//  Created by Serge on 2013-07-10.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "Funnel.h"
#import "OKNoise.h"

@implementation Funnel

@synthesize touch;

-(id) initFunnelWithWords:(NSMutableArray*)theWords x:(int)x y:(int)y font:(OKTessFont*)aFont fontScale:(float)aFontScale renderingBounds:(CGRect)aRenderingBounds;
{
    self = [super init];
    if(self)
    {
        words = theWords;
        wordIndex = 0;
        font = aFont;
        //fontSize = aFontSize;
        fontScale = aFontScale;
        pgi = 0;
        alpha = 255;
        dying = false;
        touch =-1;
        ox = x;
        oy = y;
        
        strings = [[NSMutableArray alloc] init];
        accumulateDrawBuffer = [[NSMutableArray alloc] init];

        
        bounds = aRenderingBounds;
    }
  
    return self;
}

-(void) setSpeed:(float)s
{
    speed = s;
}

-(void) setColorRange:(long long)s e:(long long)e
{
     //color range s=ffdcbe78 to e=ffe89219
    
    as = s >> 24 & 0xFF;
    ae = e >> 24 & 0xFF;
    rs = s >> 16 & 0xFF;
    re = e >> 16 & 0xFF;
    gs = s >> 8 & 0xFF;
    ge = s >> 8 & 0xFF;
    bs = s & 0xFF;
    be = e & 0xFF;
    
    NSLog(@"Color range a: as=%d ae=%d", as, ae);
    NSLog(@"Color range r: as=%d ae=%d", rs, re);
    NSLog(@"Color range g: as=%d ae=%d", gs, ge);
    NSLog(@"Color range b: as=%d ae=%d", bs, be);
}

-(void) setTarget:(int)x y:(int)y
{
    tx = x;
    ty = y;
}

-(void) setSwipeLastString:(bool)swipeDirection
{
    FunnelString *lastString=[self last];
    if(lastString){
        [lastString setTarget:OKPointMake(600, 0, 0) m:1.0 o:1.0];
        [lastString setFlock:speed*10 a:speed*10 c:speed*10 m:speed*10 ];
    }
}


-(FunnelString*) last
{
    if([strings count]==0)
        return nil;
    else
        return [strings objectAtIndex:([strings count]-1)];
    }

-(void) next
{
    //stop the latest string
    if(strings.count!=0){
        FunnelString* lastString = [strings objectAtIndex:(strings.count-1)];
        [lastString kill];
    }
       
    //get next string from the text
    FunnelString* string = [[FunnelString alloc] initWithWord:[words objectAtIndex:wordIndex++] font:font renderingBounds:bounds];
    [string setScale:fontScale];
    if(wordIndex>=words.count)
        wordIndex = 0;
        
    //reset position
    //[string setPosition:ox y:oy];
    [string setPosition:OKPointMake(ox, oy, 0)];
    [string setTarget:(OKPointMake(ox, fontSize, 0)) m:0.8f o:0];
    //[string setTarget:(OKPointMake(0, 50, 0)) m:0.8f o:0];

    //set a random color in the range
    string.color = [self randomColor];
        
    //add the string to the funnel
    [strings addObject:string];

}

-(long long) randomColor {
    int r = rs + (int)(((arc4random() % 100)/100.0f)*(int)(re-rs));
    int g = gs + (int)(((arc4random() % 100)/100.0f)*(ge-gs));
    int b = bs + (int)(((arc4random() % 100)/100.0f)*(be-bs));
    int a = as + (int)(((arc4random() % 100)/100.0f)*(ae-as));
    
    NSLog(@"Random color =  a=%d r=%d g=%d b=%d", a, r, g, b);
    
    long long color = (long long)(a << 24) + (long long)(r << 16) + (long long)(g << 8) + (long long)b;
    NSLog(@"Random color=%lld", color);
    
    return color;
    
}

-(void) kill
{
    dying = true;
}

-(void) nextBuffer
{
    //pgi = (pgi+1)%pg.length;
}

-(void) update:(long)dt
{
    if (dying) {
        alpha -= 1;
        if (alpha <= 0) {
            dying = false;
            alpha = 255;
            
            //PGraphics b = back();
            //b.beginDraw();
            //b.background(0, 0);
            //b.endDraw();
        }
    }
    
    if(strings.count==0)
        return;
    
    //update all strings and remove the dead ones
    NSMutableArray *discardedItems = [NSMutableArray array];
    for(FunnelString *s in strings)
    {
        [s update:dt];
#warning SM - Should we kill it?
        //if([s isDead])
          //  [discardedItems addObject:s];
    }
    [strings removeObjectsInArray:discardedItems];
    
    //move only the latest string
    FunnelString *string = [strings objectAtIndex:(strings.count-1)];
    if (touch == -1) {
       //[string setTarget:OKPointMake(ox+([OKNoise noiseX:20 y:[self getMillis]/1000]-0.5f)*800 , -fontSize, 0) m:(float)(1.6f*speed) o:0.0f];
       [string setFlock:(float)(2*speed) a:(float)(1*speed) c:(float)(2*speed) m:(float)(2*speed)];
    
    }
    else {
        [string setTarget:OKPointMake(tx, ty, 0) m:(3.0f*speed) o:1.0f];
        [string setFlock:(float)(1.0f*speed) a:(float)(0.5f*speed) c:(float)(0.8f*speed) m:(float)(2.0f*speed)];
    }
    
    if ([string bottom] < 0) {
        [self kill];
        string = nil;
        
        //switch buffer
        [self nextBuffer];
    }		
}

-(void) draw
{
    if(dying) {
        glColor4f(1, 1, 1, alpha);
        //p.image(back(), 0, 0);
    }
    
    if(strings.count==0)
        return;
    
    //draw the top current funnel
    /*PGraphics f = front();
    
    f.beginDraw();
    f.noFill();
    for(FunnelString string : strings)
        string.draw(f);
    f.endDraw();
    
    p.noTint();
    p.image(f, 0, 0);
     */
   
    /*
    for(FunnelString *string in strings)
    {
        //[string draw];
        FunnelString *stringCopy = [string copy];
        [accumulateDrawBuffer addObject:stringCopy];
    }
    
    
    for(FunnelString *string in accumulateDrawBuffer)
    {
        [string draw];
    }
     */
     
    
    for(FunnelString *string in strings)
    {
        [string draw];
    }
     
}



-(long long) getMillis{
    
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Convert the mach time to milliseconds
    uint64_t millis = ((machTime / 1000000) * sTimebaseInfo.numer) / sTimebaseInfo.denom;
    
    long long nowMillis = (long long)millis;
    return nowMillis;
}



@end
