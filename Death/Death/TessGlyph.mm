//
//  TessGlyph.m
//  White
//
//  Created by Christian Gratton on 2013-03-19.
//  Copyright (c) 2013 Christian Gratton. All rights reserved.
//

#import "TessGlyph.h"
#import "OKPoEMMProperties.h"
#import "OKTessData.h"
#import "OKTessFont.h"
#import "OKCharObject.h"
#import "OKCharDef.h"

//DEBUG settings
static BOOL DEBUG_BOUNDS = NO;

static float OUTLINE_WIDTH;// iPad 1.0 iPhone 2.0
static float RENDER_PADDING;// iPad 20.0f iPhone 10.0f
static float MAX_CONTRACTION_ITERATION=8;

@implementation TessGlyph
@synthesize charObj;
@synthesize visible;

- (id) initWithChar:(OKCharObject*)aCharObj font:(OKTessFont*)aFont accurracy:(int)accurracy renderingBounds:(CGRect)aRenderingBounds
{
    self = [super init];
    if(self)
    {
        // Properties
        OUTLINE_WIDTH = [[OKPoEMMProperties objectForKey:OutlineWidth] floatValue];
        RENDER_PADDING = [[OKPoEMMProperties objectForKey:RenderPadding] floatValue];
        
        // Char Object
        charObj = aCharObj;
        
        // Font
        font = aFont;
        
        // Set Rendering Padding
        float x = [font getMaxWidth] + RENDER_PADDING;
        float width = aRenderingBounds.size.width + (x * 2);
        rBounds = CGRectMake(-x, aRenderingBounds.origin.y, width, aRenderingBounds.size.height);
        
        //Color
        fillClr[0] = 0.0f;
		fillClr[1] = 0.0f;
		fillClr[2] = 0.0f;
		fillClr[3] = 0.0f;
		
		outlineClr[0] = 0.0f;
		outlineClr[1] = 0.0f;
		outlineClr[2] = 0.0f;
		outlineClr[3] = 0.0f;
        
        canVertexArray = NO;
        NSString *reqVer = @"5.0.0";
        NSString *currVer = [[UIDevice currentDevice] systemVersion];
        if ([currVer compare:reqVer options:NSNumericSearch] != NSOrderedAscending)
            canVertexArray = YES;
        
        [self buildWithAccuracy:accurracy];
        
        visible = true;
    }
    return self;
}




- (void) buildWithAccuracy:(int)aAccuracy
{
    //Get the center of the glyph and use that as the position
    OKPoint nPoint = [charObj getPositionAbsolute];
    CGRect gBounds = [charObj getLocalBoundingBox];
    
    OKPoint gCenter = OKPointMake((gBounds.origin.x + gBounds.size.width/2.0), (gBounds.origin.y + gBounds.size.height/2.0), 0.0);
    
    
    nPoint = OKPointAdd(nPoint, gCenter);
    //NSLog(@"GET ABS POS:%f %f", nPoint.x, nPoint.y);
    [self setPos:nPoint];
    
    //Tessalate text in original form
    OKCharDef *charDef = [font getCharDefForChar:charObj.glyph];
    origData = [self tesselate:charDef accuracy:aAccuracy];
    [charDef release];
    
    //Offset the vertices so they are relative to the glyph's position
    if(origData.endsCount > 0)
    {
        GLfloat *vertices = [origData getVertices];
        int numVertices = [origData numVertices];
                
        for(int i = 0; i < numVertices; i++)
        {
            vertices[i * 2 + 0] -= gCenter.x;
            vertices[i * 2 + 1] -= gCenter.y;
  
        }
    }
    
    //reset contraction 
    contractionIteration=0;
    contracting = FALSE;
    
    //reset decontracting
    decontracting = FALSE;
    decontractionIteration=0;
    
    //Clone to deformed data
    dfrmData = [origData copy];
    
}

-(void) setWordPosX:(float)posX y:(float)posY
{
    wordPos.x = posX;
    wordPos.y = posY;
    
}

- (OKTessData*) tesselate:(OKCharDef*)aCharDef accuracy:(int)aAccuracy
{
    return [[aCharDef.tessData objectForKey:[NSString stringWithFormat:@"%i", aAccuracy]] copy];
}

#pragma mark - DRAW

-(void) updateContraction{
    
    OKTessData *data = dfrmData;
    GLfloat *contractedVertices = [data getVertices];
    int numVertices = [origData numVertices];
    BOOL atLeastOneVerticesContracted=false;
    
    
    //if we are in contracting mode, deform data
    if(contracting){
    
        //make sure we don't go beyond the max iteration
        if(contractionIteration < MAX_CONTRACTION_ITERATION){
            for(int i = 0; i < numVertices; i++)
            {
                //deform y position of vertices if vertices x is positionned near of the contract position
                float distanceFromContraction = fabsf( (wordPos.x + pos.x*sca + contractedVertices[i * 2 + 0]*sca)- contractPosition.x);
                if( distanceFromContraction < (rBounds.size.width/50)*sca){
                    
                    contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] + bounds.size.height/2;
                    float contractValue = ((cosf(distanceFromContraction/((rBounds.size.width/50)*sca)*M_PI)+1)/2)/MAX_CONTRACTION_ITERATION;
                    if(contractValue>0.01)
                        atLeastOneVerticesContracted=true;
                    contractedVertices[i * 2 + 1] *= 1 - contractValue;
                    contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] - bounds.size.height/2;
                  
                }
            }
            //if no vertices got contracted, no need to try contracting the glyphs anymore.
            if(atLeastOneVerticesContracted==false)
                contracting=false;
            
            contractionIteration++;
        }
        else{
            //set decontraction with approximate number of iteration to reform the vertices
            decontractionIteration = contractionIteration;
            decontracting=TRUE;
            
            //reset contraction
            contracting = FALSE;
            contractionIteration=0;
        }
    }
    else if(decontracting){
        //we are in decontracting mode
        [self decontract];
    }
    
}


-(void) decontract{
    //we need to resume original data slowly
    OKTessData *data = dfrmData;
    GLfloat *contractedVertices = [data getVertices];
    int numVertices = [origData numVertices];
    
    //make sure to decontract slower than contrat (x5 slower)
    if(decontractionIteration >= 0){

        for(int i = 0; i < numVertices; i++){
            
            //deform y position of vertices if vertices x is positionned near of the contract position
            float distanceFromContraction = fabsf( (wordPos.x + pos.x*sca + contractedVertices[i * 2 + 0]*sca)- contractPosition.x);
            if( distanceFromContraction < (rBounds.size.width/50)*sca){
                
                contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] + bounds.size.height/2;
                contractedVertices[i * 2 + 1] *= 1 + ((cosf(distanceFromContraction/((rBounds.size.width/50)*sca)*M_PI)+1)/2)/(MAX_CONTRACTION_ITERATION*5);
                contractedVertices[i * 2 + 1] = contractedVertices[i * 2 + 1] - bounds.size.height/2;
            }
        }
        decontractionIteration=decontractionIteration-0.2;
    }
    //decontraction process is done
    else{
        decontracting=FALSE;
        decontractionIteration=0;
        
        //reload original glyph (to make sure we really come back to original form)
        dfrmData = [origData copy];
    }
}



- (void) draw
{
    if(!visible)
        return;
    
    //Transform
    glPushMatrix();
    
    glTranslatef(pos.x, pos.y, pos.z);
    //glScalef(sca, sca, 0.0);
    
    //Keep track of bounding box
    float minX = CGFLOAT_MAX;
    float minY = CGFLOAT_MAX;
    float maxX = CGFLOAT_MIN;
    float maxY = CGFLOAT_MIN;
    
    //Draw deformed data
    if(dfrmData)
    {
        OKTessData *data = dfrmData;
        
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                //glColor4f(fillClr[0], fillClr[1], fillClr[2], fillClr[3]);
 
                // Fill
                for(int i = 0; i < data.shapesCount; i++)
                {
                    glVertexPointer(2, GL_FLOAT, 0, [data getVertices:i]);
                    glDrawArrays([data getType:i], 0, [data numVertices:i]);
                    
                }
            
                
                //glColor4f(outlineClr[0], outlineClr[1], outlineClr[2], outlineClr[3]);
                
                /*
                // Outline
                for(int i = 0; i < data.oShapesCount; i++)
                {
                    if(canVertexArray)
                    {
                        glEnable(GL_LINE_SMOOTH);
                        
                        //glEnableClientState(GL_VERTEX_ARRAY);
                        glVertexPointer(2, GL_FLOAT, 0, [data getVertices]);
                        glLineWidth(OUTLINE_WIDTH);
                        glDrawElements(GL_LINE_LOOP, [data numOutlineIndices:i], GL_UNSIGNED_INT, [data getOutlineIndices:i]);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                    else
                    {
                        // Variables
                        GLfloat *vertices = [data getVertices]; // get existing verts (all of them since there are more shapes in fill than stroke)
                        int numIndices = [data numOutlineIndices:i]; // indexes in outline
                        GLfloat *vert = new GLfloat[numIndices * 2]; // create new array to store outline vertices based on fill
                        //GLfloat *vert = new GLfloat[numIndices * 3]; // create new array to store outline vertices based on fill

                        GLint *indices = [data getOutlineIndices:i]; // get array of indexes
                        
                        for(int j = 0; j < numIndices; j++)
                        {
                            vert[j * 2 + 0] = vertices[indices[j] * 2 + 0]; // x
                            vert[j * 2 + 1] = vertices[indices[j] * 2 + 1]; // y
                           // vert[j * 3 + 0] = vertices[indices[j] * 3 + 0]; // x
                           // vert[j * 3 + 1] = vertices[indices[j] * 3 + 1]; // y
                           // vert[j * 3 + 2] = 0;

                        }
                        
                        // Draw outline
                        glEnable(GL_LINE_SMOOTH);
                        
                        glVertexPointer(2, GL_FLOAT, 0, vert);
                        //glVertexPointer(3, GL_FLOAT, 0, vert);

                        glLineWidth(OUTLINE_WIDTH);
                        glDrawArrays(GL_LINE_LOOP, 0, numIndices);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                }*/
            }
            
            // Determine bounds for actual glyph
            GLfloat *vertices = [origData getVertices:0];
            
            for(int i = 0; i < origData.verticesCount; i++)
            {
                if(vertices[i * 2 + 0] < minX) minX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 0] > maxX) maxX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 1] < minY) minY = vertices[i * 2 + 1];
                if(vertices[i * 2 + 1] > maxY) maxY = vertices[i * 2 + 1];
            }
        }
        else // Should be space
        {
            if([charObj.glyph isEqualToString:@" "])
            {
                minX = [charObj getMinX];
                maxX = [charObj getMaxX];
                minY = [charObj getMinY];
                maxY = [charObj getMaxY];
            }
        }
    }
    
    bounds = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    glPushMatrix();
    
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    
    glPopMatrix();
    
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    //Might need to offset to absPos of Glyph
    CGPoint aPointMin = [self convertPoint:CGPointMake(minX, minY) withZ:0.0];
    CGPoint aPointMax = [self convertPoint:CGPointMake(maxX, maxY) withZ:0.0];

    absBounds = CGRectMake(aPointMin.x, aPointMin.y, aPointMax.x - aPointMin.x, aPointMax.y - aPointMin.y);
    
    //NSLog(@"A POINT: %f %f", pos.x, pos.y);
    if(absBounds.size.width < 1) absBounds.size.width++;
    if(absBounds.size.height < 1) absBounds.size.height++;
    
    if(DEBUG_BOUNDS)
        [self drawDebugBoundsForMinX:minX maxX:maxX minY:minY maxY:maxY];
    
    glPopMatrix();
}

- (void) drawFill
{
    //Transform
    glPushMatrix();
    
    glTranslatef(pos.x, pos.y, pos.z);
    
    glScalef(sca, sca, 0.0);
    
    //Keep track of bounding box
    float minX = CGFLOAT_MAX;
    float minY = CGFLOAT_MAX;
    float maxX = CGFLOAT_MIN;
    float maxY = CGFLOAT_MIN;
        
    //Draw deformed data
    if(dfrmData)
    {
        OKTessData *data = dfrmData;
            
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                glColor4f(fillClr[0], fillClr[1], fillClr[2], fillClr[3]);
                
                for(int i = 0; i < data.shapesCount; i++)
                {
                    glVertexPointer(2, GL_FLOAT, 0, [data getVertices:i]);
                    //glEnableClientState(GL_VERTEX_ARRAY);
                    glDrawArrays([data getType:i], 0, [data numVertices:i]);
                }
            }
                        
            // Determine bounds for actual glyph
            GLfloat *vertices = [origData getVertices:0];
            
            for(int i = 0; i < origData.verticesCount; i++)
            {
                if(vertices[i * 2 + 0] < minX) minX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 0] > maxX) maxX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 1] < minY) minY = vertices[i * 2 + 1];
                if(vertices[i * 2 + 1] > maxY) maxY = vertices[i * 2 + 1];
            }
        }
        else // Should be space
        {
            if([charObj.glyph isEqualToString:@" "])
            {
                minX = [charObj getMinX];
                maxX = [charObj getMaxX];
                minY = [charObj getMinY];
                maxY = [charObj getMaxY];
            }
        }
    }
    
    bounds = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    glPushMatrix();
    
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    
    glPopMatrix();
    
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    //Might need to offset to absPos of Glyph
    CGPoint aPointMin = [self convertPoint:CGPointMake(minX, minY) withZ:0.0];
    CGPoint aPointMax = [self convertPoint:CGPointMake(maxX, maxY) withZ:0.0];
    
    absBounds = CGRectMake(aPointMin.x, aPointMin.y, aPointMax.x - aPointMin.x, aPointMax.y - aPointMin.y);
    
    if(absBounds.size.width < 1) absBounds.size.width++;
    if(absBounds.size.height < 1) absBounds.size.height++;
    
    if(DEBUG_BOUNDS)
        [self drawDebugBoundsForMinX:minX maxX:maxX minY:minY maxY:maxY];
    
    glPopMatrix();
}

- (void) drawOutline
{    
    //Transform
    glPushMatrix();
    glTranslatef(pos.x, pos.y, pos.z);
    glScalef(sca, sca, 0.0);
    
    //Keep track of bounding box
    float minX = CGFLOAT_MAX;
    float minY = CGFLOAT_MAX;
    float maxX = CGFLOAT_MIN;
    float maxY = CGFLOAT_MIN;
    
    //Draw deformed data
    if(dfrmData)
    {
        OKTessData *data = dfrmData;
        
        if(data.endsCount > 0)
        {
            //sBounds
            if(![self isOutside:rBounds])
            {
                glColor4f(outlineClr[0], outlineClr[1], outlineClr[2], outlineClr[3]);
                
                for(int i = 0; i < data.oShapesCount; i++)
                {
                    if(canVertexArray)
                    {
                        glEnable(GL_LINE_SMOOTH);
                        
                        //glEnableClientState(GL_VERTEX_ARRAY);
                        glVertexPointer(2, GL_FLOAT, 0, [data getVertices]);
                        glLineWidth(OUTLINE_WIDTH);
                        glDrawElements(GL_LINE_LOOP, [data numOutlineIndices:i], GL_UNSIGNED_INT_OES, [data getOutlineIndices:i]);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                    else
                    {
                        // Variables
                        GLfloat *vertices = [data getVertices]; // get existing verts (all of them since there are more shapes in fill than stroke)
                        int numIndices = [data numOutlineIndices:i]; // indexes in outline
                        GLfloat *vert = new GLfloat[numIndices * 2]; // create new array to store outline vertices based on fill
                        GLint *indices = [data getOutlineIndices:i]; // get array of indexes
                        
                        for(int j = 0; j < numIndices; j++)
                        {
                            vert[j * 2 + 0] = vertices[indices[j] * 2 + 0]; // x
                            vert[j * 2 + 1] = vertices[indices[j] * 2 + 1]; // y
                        }
                        
                        // Draw outline
                        glEnable(GL_LINE_SMOOTH);
                        
                        glVertexPointer(2, GL_FLOAT, 0, vert);
                        glLineWidth(OUTLINE_WIDTH);
                        glDrawArrays(GL_LINE_LOOP, 0, numIndices);
                        
                        glDisable(GL_LINE_SMOOTH);
                    }
                }
            }
                        
            // Determine bounds for actual glyph
            GLfloat *vertices = [origData getVertices:0];
            
            for(int i = 0; i < origData.verticesCount; i++)
            {
                if(vertices[i * 2 + 0] < minX) minX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 0] > maxX) maxX = vertices[i * 2 + 0];
                if(vertices[i * 2 + 1] < minY) minY = vertices[i * 2 + 1];
                if(vertices[i * 2 + 1] > maxY) maxY = vertices[i * 2 + 1];
            }
        }
        else // Should be space
        {
            if([charObj.glyph isEqualToString:@" "])
            {
                minX = [charObj getMinX];
                maxX = [charObj getMaxX];
                minY = [charObj getMinY];
                maxY = [charObj getMaxY];
            }
        }
    }
    
    bounds = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    
    glPushMatrix();
    
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    
    glPopMatrix();
    
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    //Might need to offset to absPos of Glyph
    CGPoint aPointMin = [self convertPoint:CGPointMake(minX, minY) withZ:0.0];
    CGPoint aPointMax = [self convertPoint:CGPointMake(maxX, maxY) withZ:0.0];
        
    absBounds = CGRectMake(aPointMin.x, aPointMin.y, aPointMax.x - aPointMin.x, aPointMax.y - aPointMin.y);
    
    if(absBounds.size.width < 1) absBounds.size.width++;
    if(absBounds.size.height < 1) absBounds.size.height++;
        
    if(DEBUG_BOUNDS)
        [self drawDebugBoundsForMinX:minX maxX:maxX minY:minY maxY:maxY];
    
    glPopMatrix();
}

- (void) drawDebugBoundsForMinX:(float)minX maxX:(float)maxX minY:(float)minY maxY:(float)maxY
{
    //debug bounding box
    const GLfloat line[] =
    {
        minX, minY, //point A
        minX, maxY, //point B
        maxX, maxY, //point C
        maxX, minY, //point D
    };
    
    glVertexPointer(2, GL_FLOAT, 0, line);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
}

- (void) update:(long)dt
{
    [super update:dt];
}


#pragma mark - COLOR

- (float*) getFillColor { return fillClr; }

- (float*) getOutlineColor  { return outlineClr; }

- (void) setFillColor:(float*)clr { fillClr[0] = clr[0]; fillClr[1] = clr[1]; fillClr[2] = clr[2]; fillClr[3] = clr[3]; }

- (void) setOutlineColor:(float*)clr { outlineClr[0] = clr[0]; outlineClr[1] = clr[1]; outlineClr[2] = clr[2]; outlineClr[3] = clr[3]; }

#pragma mark - PROPERTIES

- (BOOL) isOutside:(CGRect)b { return (CGRectIntersectsRect(b, absBounds) ? NO : YES); }

- (BOOL) isInside:(CGPoint)p { return (CGRectContainsPoint(absBounds, p) ? YES : NO); }

#pragma mark - GETTERS

- (CGRect) getBounds { return bounds; }

- (CGRect) getAbsoluteBounds { return absBounds; }

- (OKPoint) getAbsoluteCoordinates { return OKPointMake(absBounds.origin.x, absBounds.origin.y, 0.0); }

- (OKPoint) transform:(OKPoint)aPoint
{
    OKPoint ac = [self getAbsoluteCoordinates];
    OKPoint ptSca = aPoint;
    
    return OKPointMake(ac.x + ptSca.x, ac.y + ptSca.y, ac.z + ptSca.z);
}


#pragma mark - POINT CONVERSION

- (CGPoint) convertPoint:(CGPoint)aPoint withZ:(float)z
{
    float ax = ((modelview[0] * aPoint.x) + (modelview[4] * aPoint.y) + (modelview[8] * z) + modelview[12]);
	float ay = ((modelview[1] * aPoint.x) + (modelview[5] * aPoint.y) + (modelview[9] * z) + modelview[13]);
	float az = ((modelview[2] * aPoint.x) + (modelview[6] * aPoint.y) + (modelview[10] * z) + modelview[14]);
	float aw = ((modelview[3] * aPoint.x) + (modelview[7] * aPoint.y) + (modelview[11] * z) + modelview[15]);
	
	float ox = ((projection[0] * ax) + (projection[4] * ay) + (projection[8] * az) + (projection[12] * aw));
	float oy = ((projection[1] * ax) + (projection[5] * ay) + (projection[9] * az) + (projection[13] * aw));
	float ow = ((projection[3] * ax) + (projection[7] * ay) + (projection[11] * az) + (projection[15] * aw));
	
	if(ow != 0)
		ox /= ow;
	
	if(ow != 0)
		oy /= ow;
	
    //VICTOR - PROPER SCREEN BOUNDS
	return CGPointMake(([UIScreen mainScreen].bounds.size.width * (1 + ox) / 2.0f), ([UIScreen mainScreen].bounds.size.height * (1 + oy) / 2.0f));
}

#pragma mark - RANDOM

- (float) floatRandom
{
    return (float)arc4random()/ARC4RANDOM_MAX;
}

- (float) arc4randomf:(float)max :(float)min
{
    return ((max - min) * [self floatRandom]) + min;
}


- (void) setContractPoint:(float)x y:(float)y{
    contractPosition.x=x;
    contractPosition.y=y;
}

- (void) setContract:(BOOL)aContractState{
    contracting = aContractState;
}


- (void) dealloc
{
    [origData release];
    [dfrmData release];
    
    [super dealloc];
}

@end
