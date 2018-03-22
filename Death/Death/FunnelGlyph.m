//
//  FunnelGlyph.m
//  Death
//
//  Created by Serge on 2013-07-11.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import "FunnelGlyph.h"

@implementation FunnelGlyph

@synthesize location, velocity, value;

-(id) initFunnelGlyph:(TessGlyph*)v x:(float)x y:(float)y
{
    self = [super init];
    if(self)
    {
        value = v;
        acceleration = OKPointMake(0, 0, 0);
        target = OKPointMake(0, 0, 0);
        offset = OKPointMake(x, y, 0);
    
        //velocity = PVector.random2D();
        velocity = OKPointMake( 0, 0.0005, 0);
        location = OKPointMake(x, y, 0);
   
        //r = 144.0f; //set with font size XXX
        maxspeed = 25;
        maxforce = 0.03f;
        friction = 0.02f;
        
        sepMult = 1.5f;
        aliMult = 0.8f;
        cohMult = 1.0f;
        
        dying = false;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    FunnelGlyph *copy = [[[self class] allocWithZone: zone] init];
    
    copy.location = location;
    copy.value = [value copy];
       
    return copy;
}


-(void) kill
{
    dying = true;
}

-(BOOL) isDead
{
    return dying && OKPointMag(velocity) < 0.1f;
}

-(void) setTarget:(OKPoint)aTarget m:(float)m o:(float)o
{
    target = aTarget;
    target = OKPointAdd(target, OKPointMultf(offset, o));
    targetMult = m;
}

-(void) setFlock:(float)s a:(float)a c:(float)c m:(float)m
{
    sepMult = s;
    aliMult = a;
    cohMult = c;
    maxspeed = m;
}

/*
-(void) setPosition:(float)x y:(float)y
{
    location = OKPointMake(x, y, 0.0f);
}
*/

-(void) applyForce:(OKPoint) force
{
    // We could add mass here if we want A = F / M
    acceleration = OKPointAdd(acceleration, force);
}

// We accumulate a new acceleration each time based on three rules
-(void) flock:(NSMutableArray*) glyphs
{
    OKPoint sep = [self separate:glyphs];
    OKPoint ali = [self align:glyphs];
    OKPoint coh = [self cohesion:glyphs];
    OKPoint up = [self seek:target];
    
    sep = OKPointMultf(sep, sepMult);
    ali = OKPointMultf(ali, aliMult);
    up = OKPointMultf(up, targetMult);
    coh = OKPointMultf(coh, cohMult);
    
    [self applyForce:sep];
    [self applyForce:ali];
    [self applyForce:up];
    [self applyForce:coh];
}

// Method to update location
-(void) update:(NSMutableArray*) glyphs
{    
    if(!dying)
        [self flock:glyphs];
    
    //NSLog(@"velocity = %f %f", velocity.x, velocity.y);
    //NSLog(@"acceleration = %f %f", acceleration.x, acceleration.y);
    
    // Update velocity
    velocity = OKPointAdd(velocity, acceleration);
    
    // Limit speed
    velocity = OKPointNormalize(velocity);
    velocity = OKPointMultf(velocity, maxspeed);
    //velocity = OKPointMultf(velocity, 10);
    
    //NSLog(@"Velocity x=%f y=%f", velocity.x, velocity.y);
    
    //add velocity to location
    location = OKPointAdd(location, velocity);

    velocity = OKPointMultf(velocity, 1-friction);
    acceleration = OKPointMultf(acceleration, 0);
  
 

}

// A method that calculates and applies a steering force towards a target
// STEER = DESIRED MINUS VELOCITY
-(OKPoint) seek:(OKPoint)aTarget {
    
   // NSLog(@"RealPos: %f %f", wordPos.x, wordPos.y);
   // NSLog(@"Location: %f %f", location.x, location.y);
   // NSLog(@"aTarget: %f %f", aTarget.x, aTarget.y);
    
    //OKPoint desired = OKPointSub(aTarget, location);
    OKPoint realPos = OKPointAdd(location, wordPos);   //location or a glyph is relative to word position.
    OKPoint distance = OKPointSub(aTarget, realPos);

    // Scale to maximum speed
    OKPoint desired = OKPointNormalize(distance);  //normalize to 1
    desired = OKPointMultf(desired, maxspeed);
        
    // Steering = Desired minus Velocity
    OKPoint steer = OKPointSub(desired, velocity);
    
    // Limit to maximum steering force
    steer = OKPointNormalize(steer);    
    steer = OKPointMultf(steer, maxforce);
    
    return steer;
}


-(void) draw
{
    
    glPushMatrix();
    glTranslatef(location.x, location.y, 0);
    [value draw];
    glPopMatrix();
}

-(OKPoint) separate:(NSMutableArray*) glyphs
{
    float desiredseparation = 40.0f;
    OKPoint steer = OKPointMake(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (FunnelGlyph *other in glyphs) {
        float d = OKPointDist(location, other.location);
        //NSLog(@"d = %f", d);
        // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
        if ((d > 0) && (d < desiredseparation)) {
            // Calculate vector pointing away from neighbor
            OKPoint diff = OKPointSub(location, other.location);
           // NSLog(@"Count = %d", count);
           // NSLog(@"Diff 1: %f %f", diff.x, diff.y);
            diff = OKPointNormalize(diff);
           // NSLog(@"Diff 2: %f %f", diff.x, diff.y);
            diff = OKPointDivf(diff, d);  // Weight by distance
            //NSLog(@"Diff 3: %f %f", diff.x, diff.y);
            steer = OKPointAdd(steer, diff);
            count++;            // Keep track of how many
        }
    }
    // Average -- divide by how many
    if (count > 0) {
        steer = OKPointDivf(steer, (float)count);
    }
    
    // As long as the vector is greater than 0
    if (OKPointMag(steer) > 0) {
          
        // Implement Reynolds: Steering = Desired - Velocity
        steer = OKPointNormalize(steer);
        steer = OKPointMultf(steer, maxspeed);
        steer = OKPointSub(steer, velocity);
        
        steer = OKPointNormalize(steer);
        steer = OKPointMultf(steer, maxforce);
    }
    return steer;
}

// Alignment
// For every nearby boid in the system, calculate the average velocity
-(OKPoint) align:(NSMutableArray*) glyphs
{
    float neighbordist = 100;
    OKPoint sum = OKPointMake(0, 0, 0);
    int count = 0;
    for (FunnelGlyph *other in glyphs) {
        float d = OKPointDist(location, other.location);
     
        if ((d > 0) && (d < neighbordist)) {
            sum = OKPointAdd(sum, other.velocity);
            count++;
        }
    }
    if (count > 0) {
        sum = OKPointDivf(sum, (float)count);
           
        // Implement Reynolds: Steering = Desired - Velocity
        sum = OKPointNormalize(sum);
        sum = OKPointMultf(sum, maxspeed);
        
        OKPoint steer = OKPointSub(sum, velocity);
        steer = OKPointNormalize(steer);
        steer = OKPointMultf(steer, maxspeed);
                
        //limit to maxforce
        steer = OKPointNormalize(steer);
        steer = OKPointMultf(steer, maxforce);

        return steer;
    } 
    else {
        return OKPointMake(0, 0, 0);
    }
}

// Cohesion
// For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
-(OKPoint) cohesion:(NSMutableArray*) glyphs {
    float neighbordist = 20;
    OKPoint sum = OKPointMake(0, 0, 0); //// Start with empty vector to accumulate all locations
    int count = 0;
    for (FunnelGlyph *other in glyphs) {
        float d = OKPointDist(location, other.location);
        if ((d > 0) && (d < neighbordist)) {
            sum = OKPointSub(sum, other.location);
            count++;
        }
    }
    if (count > 0) {
        sum = OKPointDivf(sum, (float)count);
        sum = OKPointAdd(sum, offset);
        return ([self seek:sum]);  // Steer towards the location
    } 
    else {
        return OKPointMake(0, 0, 0);
    }
}

-(void) setWordPosX:(float)posX y:(float)posY
{
    wordPos.x = posX;
    wordPos.y = posY;
}

@end
