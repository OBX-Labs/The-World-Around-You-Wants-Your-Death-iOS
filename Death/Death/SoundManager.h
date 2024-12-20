//
//  SoundManager.h
//  White
//
//  Created by Serge on 2013-10-18.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

//static int LEFT = 0;
//static int RIGHT = 1;

@interface SoundManager : NSObject
{
    //constant for left and right channels
    
    // NSMutableArray *shiftingSamples;    //will contains an array of Fade object
    // NSMutableArray *ambientSamples;     //ambient samples
    // NSMutableArray *threatSamples;      //threat samples
    
	BOOL activeThreats;					//true when threats are active
    AVAudioPlayer *currentThreat;       //the current playing threat
    
	long long currentThreatStart;				//when the current threat started
	long long nextThreatTime;					//when the next threat should start
	float threatVolume;						//threat sample volume
    
    /*
     NSMutableArray *rattleSamples;      //rattle samples
     NSMutableArray *usedRattleSamples;  //used rattle samples
     NSMutableArray *rattleReleaseQueue;     //rattle samples queued for release
     NSMutableArray *strikeSamples;      //strike samples
     NSMutableArray *usedStrikeSamples;  //used strike samples
     NSMutableArray *strikeReleaseQueue; //strike sample queued for release
     AVAudioPlayer *firstStrike;         //sample for the first strike
     */
    
    NSMutableArray *samples;    //loaded samples
    NSMutableDictionary *samplesDict;
    NSMutableArray *shifts;     //shifting samples
    NSMutableDictionary *shiftsDict;
    NSMutableArray *heads;      //current frames
    
}

@property (nonatomic, retain) AVAudioPlayer *player;

-(void) loadSample:(NSString*)sampleId folder:(NSString*)folder;
-(void) crossfade:(int)in out:(int)out duration:(int) duration;
-(void) crossfadeWithString:(NSString*)in out:(NSString*)out duration:(int) duration;
//-(void) fadeout:(int)index duration:(int)duration;
-(void) fadeout:(NSString*)out duration:(int)duration;
-(void) fade:(NSString*)soundString target:(float)target duration:(int)duration;
-(void) repeat:(NSString*)soundString;
-(void) play:(NSString*)soundString volume:(float)volume;
//-(void) loadAmbientSamples:(NSString*) folder;
//-(void) loadStrikeSamples:(NSString*) folder first:(NSString*) first;
//-(void) loadThreatSamples:(NSString*)folder volume:(float) volume;
//-(void) loadRattleSamples:(NSString*) folder;
//-(AVAudioPlayer*) ambient:(int)index;
//-(NSString*) ambientPath:(NSString*) file;
//-(NSString*) strikePath:(NSString*) file;
//-(NSString*) threatPath:(NSString*) file;
//-(NSString*) rattlePath:(NSString*) file;
//-(NSMutableArray*) exclusiveRattles:(int) n;
//-(void) releaseRattles:(NSMutableArray*)samples;
//-(void) fadeOutAndReleaseRattles:(NSMutableArray*)samples duration:(int)duration delay:(int) delay;
//-(NSMutableArray*) exclusiveStrikes:(int) n;
//-(AVAudioPlayer*) exclusiveFirstStrike;
//-(void) releaseStrikes:(NSMutableArray*) samples;
//-(void) fadeOutAndReleaseStrikes:(NSMutableArray*) samples duration:(int) duration;

//-(void) playThreats;
//-(void) stopThreats;

//-(void) fadeAmbient:(int) index to:(float)to duration:(int) duration stopwhendone:(BOOL) stopWhenDone;
//-(void) fadeInAndRepeatAmbient:(int)index to:(float)to duration:(int) duration;
-(void) update;
@end
