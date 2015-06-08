//
//  TextLayer.m
//  Death
//
//  Created by Serge on 2013-07-24.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "TextLayer.h"


@implementation TextLayer

@synthesize y;
@synthesize lines;

-(id) initTextLayerWithBounds:(CGRect)aRenderingBounds width:(float)w h:(float)h
{
    self = [super init];
    if(self)
    {
        y=0;
        width=w;
        height=h;
        lines = [[NSMutableArray alloc] init];
        sBounds = aRenderingBounds;
    }
    return self;
}

-(void) addLine:(Line*) line
{
    [lines addObject:line];
    //Line l = new Line(p, line, font, fontSize);
    //l.justify(width);
    //lines.add(l);
}

-(void) draw
{
   //make sure we have at least one line to draw
    if([lines count]<=0)
        return;

    glPushMatrix();
    
    //current text translation
    glTranslatef(0, y, 0);
    
    //float offset = 0;
    float h = 0;
    int i = 0;
    BOOL resetY = false;
    float newY = 0;
    int safeMargin=200;         //margin to extend from bottom or top. To avoid words to get cut before disappearing.

    //find how much lines we skip in end of text
    i=[lines count]-1;
    while(h+y<-safeMargin)
    {
        Line *line = [lines objectAtIndex:i];
        h += [line getHeight] *1.5;
        i--;
        if(i<0)
        {   resetY = true;
            newY = h;
            i=[lines count]-1;
        }
    }
   
    //we can reset y back to 0
    if(resetY)
        y = y+newY;
    
    //translate to be back to bottom of screen (h might equal y)
    glTranslatef(0, h, 0);
    h=0;
    while(h < sBounds.size.height+safeMargin)
    {
        Line *line = [lines objectAtIndex:i];
        glTranslatef(0, [line getHeight]*0.5, 0);
        
        #warning SM-FONT
        //[line draw];
        [line drawWithImage];
        
        glTranslatef(0, [line getHeight], 0);
        h+= [line getHeight] *1.5;
        i--;
        if(i<0){
            i=[lines count]-1;
        }
    }
    
     
    glPopMatrix();
}


-(void) flicker:(float)speed time:(float)time activity:(float)activity
{
    
    int i=0;
    for(Line *l in lines)
    {
        [l flicker:i s:speed t:time a:activity];
        i++;
    }
}


@end
