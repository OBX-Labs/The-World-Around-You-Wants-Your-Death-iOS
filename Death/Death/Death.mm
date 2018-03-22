//
//  Death.m
//  Death
//
//  Created by Serge Maheu on 2013-05-03.
//  Copyright (c) 2013 Serge Maheu. All rights reserved.
//

#include <mach/mach.h>
#include <mach/mach_time.h>
#import "Death.h"
#import "OKPoEMMProperties.h"
#import "OKTessFont.h"
#import "OKTextObject.h"
#import "OKSentenceObject.h"
#import "OKCharObject.h"
#import "OKTessData.h"
#import "OKCharDef.h"
#import "OKTextManager.h"
#import "Line.h"
#import "Word.h"
#import "Touch.h"
#import "OKNoise.h"
#import "PerlinTexture.h"
#import "TextLayer.h"
#import "SoundManager.h"

#define ARC4RANDOM_MAX      0x100000000
#define DEGREES_TO_RADIANS(x) (3.14159265358979323846 * x / 180.0)

//White stuff
#warning TO REMOVE WHAT IS NOT NEEDED
static NSString *BG_TEXT = @"";
static float BG_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static float BG_TEXT_SPEED;// iPad 6.0f iPhone 3.0f
static float BG_TEXT_HMARGIN;// iPad 350.0f iPhone 165.0f
static float BG_TEXT_VMARGIN;// iPad 250.0f iPhone 105.0f
static float BG_TEXT_SCALE;// iPad 7.75f iPhone 5.25f
static float BG_TEXT_TOP;
static float BG_TEXT_LEADING;
static float BG_TEXT_LEADING_SCALAR;// iPad 0.8f iPhone 0.8f
static int MAX_SENTENCES;// iPad 2 iPhone 2
static float BG_FLICKER_SPEED;// iPad 0.5f iPhone 0.5f
static float BG_FLICKER_PROPABILITY;// iPad 0.7f iPhone 0.7f
static float BG_FLICKER_SCALAR;// iPad 0.235f iPhone 0.235f
static int MAX_FADING_LINES;// iPad 10 iPhone 10


//Death stuff
static float SCROLL_VERTICAL_MARGINS[]={0,0,0};		//top margin between edge and text
static float SCROLL_HORIZONTAL_MARGINS[]={0,0,0} ;	//left and right margins between e
static NSString *SCROLL_TEXT_FILES[]={@"", @"", @""}; //static String[] SCROLL_TEXT_FILES;
static NSString *SCROLL_FONTS[]={@"", @""};  //static String[] SCROLL_FONTS;
static float SCROLL_SPEEDS[]={0,0,0};
static long long SCROLL_COLORS[]={0,0,0};
static float SCROLL_FLICKER_SPEED;
static float SCROLL_FLICKER_TIME;
static float SCROLL_FLICKER_ACTIVITY_MULTIPLIER;
static bool SCROLL_FLICKER_LAYERS[]={false,false,false};

static NSString *FUNNEL_TEXT_FILE= @"";
static NSString *FUNNEL_TEXT_FILES[]= {@"", @""};
static NSString *FUNNEL_FONT = @"";
static int FUNNEL_FONT_SIZE;
static float FUNNEL_FONT_SCALING;
static long long FUNNEL_COLOR_RANGE[]={0,0};
static float FUNNEL_SPEED;

static int LIGHTNING_CELL_HEIGHT;
static int LIGHTNING_CELL_MARGIN;
static float LIGHTNING_ROWS_SPEED;
static int LIGHTNING_COLUMNS;
static float LIGHTNING_HORIZONTAL_NOISE;
static float LIGHTNING_VERTICAL_NOISE;
static float LIGHTNING_HORIZONTAL_SPEED;
static float LIGHTNING_VERTICAL_SPEED;
static float LIGHTNING_TOUCH_EFFECT;
static float LIGHTNING_MASS;
static float LIGHTNING_MASS_SPEED;
static long long LIGHTNING_COLOR;

static float SKY_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static float GROUND_COLOR[] = {0.0, 0.0, 0.0, 0.0};
static int HORIZON_MARGIN;
static float HORIZON_SPEED;

static float TOUCH_ACTIVITY_INCREMENT;
static float TOUCH_ACTIVITY_DECREMENT;
static int TOUCH_ACTIVITY_HOLD_TIME;


static NSString *AUDIO_DRONE = @"drone";	//filename of sound for forward motion of first touch
static NSString *AUDIO_SHORT = @"short";		//filename of sound for backward motion of first touch
static NSString *AUDIO_FORMAT = @"mp3";
static int AUDIO_NUM_SHORT_SOUNDS = 8;

GLuint triangleVBO;

static float TOUCH_OFFSET;



@implementation Death

//- (id) initWithFont:(OKTessFont*)tFont text:(OKTextObject*)textObj allTexts:(NSMutableArray*)theTexts andBounds:(CGRect)bounds eaglview:(EAGLView*)aView
//- (id) initWithBounds:(CGRect)bounds eaglview:(EAGLView*)aView
//- (id) initWithFont:(OKTessFont*)tFont text:(NSMutableArray*)aText andBounds:(CGRect)bounds eaglview:(EAGLView*)aView
- (id) initWithFont:(OKTessFont*)tFont text:(OKTextObject*)textObj andBounds:(CGRect)bounds eaglview:(EAGLView*)aView
{
    self = [super init];
    if(self)
    {
        // Load propeties
        BG_TEXT = [OKPoEMMProperties objectForKey:Title];
        NSArray *bgColor = [OKPoEMMProperties objectForKey:BackgroundColor];
        BG_COLOR[0] = [[bgColor objectAtIndex:0] floatValue];
        BG_COLOR[1] = [[bgColor objectAtIndex:1] floatValue];
        BG_COLOR[2] = [[bgColor objectAtIndex:2] floatValue];
        BG_COLOR[3] = [[bgColor objectAtIndex:3] floatValue];
        NSLog(@"BG COLOR= %f, %f, %f, %f", BG_COLOR[0],BG_COLOR[1],BG_COLOR[2],BG_COLOR[3]);

        //white
        BG_TEXT_SPEED = [[OKPoEMMProperties objectForKey:BackgroundTextSpeed] floatValue];
        BG_TEXT_HMARGIN = [[OKPoEMMProperties objectForKey:BackgroundTextHorizontalMargin] floatValue];
        BG_TEXT_VMARGIN = [[OKPoEMMProperties objectForKey:BackgroundTextVerticalMargin] floatValue];
        BG_TEXT_SCALE = [[OKPoEMMProperties objectForKey:BackgroundTextScale] floatValue];
        BG_TEXT_LEADING_SCALAR = [[OKPoEMMProperties objectForKey:BackgroundTextLeadingScalar] floatValue];
        MAX_SENTENCES = [[OKPoEMMProperties objectForKey:MaximumSentences] floatValue];
        BG_FLICKER_SPEED = [[OKPoEMMProperties objectForKey:BackgroundFlickerSpeed] floatValue];
        BG_FLICKER_PROPABILITY = [[OKPoEMMProperties objectForKey:BackgroundFlickerPropability] floatValue];
        BG_FLICKER_SCALAR = [[OKPoEMMProperties objectForKey:BackgroundFlickerScalar] floatValue];
        MAX_FADING_LINES = [[OKPoEMMProperties objectForKey:MaximumFadingLines] intValue];
                
        //DEATH
        NSLog(@"Read Death properties");
        NSArray *aValue = [OKPoEMMProperties objectForKey:ScrollVerticalMargins];
        SCROLL_VERTICAL_MARGINS[0] = [[aValue objectAtIndex:0]floatValue];
        SCROLL_VERTICAL_MARGINS[1] = [[aValue objectAtIndex:1]floatValue];
        SCROLL_VERTICAL_MARGINS[2] = [[aValue objectAtIndex:2]floatValue];
       
        aValue = [OKPoEMMProperties objectForKey:ScrollHorizontalMargins];
        SCROLL_HORIZONTAL_MARGINS[0] = [[aValue objectAtIndex:0]floatValue];
        SCROLL_HORIZONTAL_MARGINS[1] = [[aValue objectAtIndex:1]floatValue];
        SCROLL_HORIZONTAL_MARGINS[2] = [[aValue objectAtIndex:2]floatValue];        
        aValue = [OKPoEMMProperties objectForKey:ScrollTextFiles];
        SCROLL_TEXT_FILES[0] = [aValue objectAtIndex:0];
        SCROLL_TEXT_FILES[1] = [aValue objectAtIndex:1];
        SCROLL_TEXT_FILES[2] = [aValue objectAtIndex:2];
        aValue = [OKPoEMMProperties objectForKey:ScrollFonts];
        SCROLL_FONTS[0] = [aValue objectAtIndex:0];
        SCROLL_FONTS[1] = [aValue objectAtIndex:1];
        aValue = [OKPoEMMProperties objectForKey:ScrollSpeeds];
        SCROLL_SPEEDS[0] = [[aValue objectAtIndex:0] floatValue];
        SCROLL_SPEEDS[1] = [[aValue objectAtIndex:1] floatValue];
        SCROLL_SPEEDS[2] = [[aValue objectAtIndex:2] floatValue];
       
        aValue = [OKPoEMMProperties objectForKey:ScrollColors];
        SCROLL_COLORS[0] = [[aValue objectAtIndex:0] longLongValue];
        SCROLL_COLORS[1] = [[aValue objectAtIndex:1] longLongValue];
        SCROLL_COLORS[2] = [[aValue objectAtIndex:2] longLongValue];
        NSLog(@"SCROLL_COLOR: %lli %lli %lli", SCROLL_COLORS[0],SCROLL_COLORS[1],SCROLL_COLORS[2]);
        
        SCROLL_FLICKER_SPEED = [[OKPoEMMProperties objectForKey:ScrollFlickerSpeed] floatValue];
        SCROLL_FLICKER_TIME = [[OKPoEMMProperties objectForKey:ScrollFlickerTime] floatValue];
        SCROLL_FLICKER_ACTIVITY_MULTIPLIER = [[OKPoEMMProperties objectForKey:ScrollFlickerActivityMultiplier] floatValue];
        aValue = [OKPoEMMProperties objectForKey:ScrollFlickerLayers];
        SCROLL_FLICKER_LAYERS[0] = [[aValue objectAtIndex:0] boolValue];
        SCROLL_FLICKER_LAYERS[1] = [[aValue objectAtIndex:1] boolValue];
        SCROLL_FLICKER_LAYERS[2] = [[aValue objectAtIndex:2] boolValue];

        
        FUNNEL_TEXT_FILE = [OKPoEMMProperties objectForKey:FunnelTextFile];
        aValue = [OKPoEMMProperties objectForKey:FunnelTextFiles];
        FUNNEL_TEXT_FILES[0]=[aValue objectAtIndex:0];
        FUNNEL_TEXT_FILES[1]=[aValue objectAtIndex:1];
        FUNNEL_FONT = [OKPoEMMProperties objectForKey:FunnelFont];
        FUNNEL_FONT_SIZE =[[OKPoEMMProperties objectForKey:FunnelFontSize] integerValue];
        FUNNEL_FONT_SCALING =[[OKPoEMMProperties objectForKey:FunnelFontScaling] floatValue];
        aValue = [OKPoEMMProperties objectForKey:FunnelColorRange];
        FUNNEL_COLOR_RANGE[0] = [[aValue objectAtIndex:0] longLongValue];
        FUNNEL_COLOR_RANGE[1] = [[aValue objectAtIndex:1] longLongValue];
        FUNNEL_SPEED = [[OKPoEMMProperties objectForKey:FunnelSpeed] floatValue];
        
        LIGHTNING_CELL_HEIGHT =[[OKPoEMMProperties objectForKey:LightningCellHeight] integerValue];
        LIGHTNING_CELL_MARGIN = [[OKPoEMMProperties objectForKey:LightningCellMargin] integerValue];
        LIGHTNING_ROWS_SPEED = [[OKPoEMMProperties objectForKey:LightningRowsSpeed] floatValue];
        LIGHTNING_COLUMNS = [[OKPoEMMProperties objectForKey:LightningColumns] integerValue];
        LIGHTNING_HORIZONTAL_NOISE = [[OKPoEMMProperties objectForKey:LightningHorizontalNoise] floatValue];
        LIGHTNING_VERTICAL_NOISE = [[OKPoEMMProperties objectForKey:LightningVerticalNoise] floatValue];
        LIGHTNING_HORIZONTAL_SPEED = [[OKPoEMMProperties objectForKey:LightningHorizontalSpeed] floatValue];
        LIGHTNING_VERTICAL_SPEED = [[OKPoEMMProperties objectForKey:LightningVerticalSpeed] floatValue];
        LIGHTNING_TOUCH_EFFECT = [[OKPoEMMProperties objectForKey:LightningTouchEffect] floatValue];
        LIGHTNING_MASS = [[OKPoEMMProperties objectForKey:LightningMass] floatValue];
        LIGHTNING_MASS_SPEED = [[OKPoEMMProperties objectForKey:LightningMassSpeed] floatValue];
        LIGHTNING_COLOR = [[OKPoEMMProperties objectForKey:LightningColor] longLongValue];
        
        aValue = [OKPoEMMProperties objectForKey:SkyColor];
        SKY_COLOR[0]= [[aValue objectAtIndex:0] floatValue];
        SKY_COLOR[1]= [[aValue objectAtIndex:1] floatValue];
        SKY_COLOR[2]= [[aValue objectAtIndex:2] floatValue];
        SKY_COLOR[3]= [[aValue objectAtIndex:3] floatValue];
        aValue = [OKPoEMMProperties objectForKey:GroundColor];
        GROUND_COLOR[0] = [[aValue objectAtIndex:0] floatValue];
        GROUND_COLOR[1] = [[aValue objectAtIndex:1] floatValue];
        GROUND_COLOR[2] = [[aValue objectAtIndex:2] floatValue];
        GROUND_COLOR[3] = [[aValue objectAtIndex:3] floatValue];
        
        HORIZON_MARGIN = [[OKPoEMMProperties objectForKey:HorizonMargin] integerValue];
        HORIZON_SPEED = [[OKPoEMMProperties objectForKey:HorizonSpeed] floatValue];
        
        TOUCH_ACTIVITY_INCREMENT = [[OKPoEMMProperties objectForKey:TouchActivityIncrement] floatValue];
        TOUCH_ACTIVITY_DECREMENT = [[OKPoEMMProperties objectForKey:TouchActivityDecrement] floatValue];
        TOUCH_ACTIVITY_HOLD_TIME = [[OKPoEMMProperties objectForKey:TouchActivityHoldTime] integerValue];
        
        // Screen bounds
        sBounds = bounds;
        
        // Touches
        TOUCH_OFFSET = [[OKPoEMMProperties objectForKey:TouchOffset] floatValue];
        ctrlPts = [[NSMutableDictionary alloc] init];
        ctrlPtsTouch =[[NSMutableDictionary alloc] init];
        ctrlPtsTouchRemoved=[[NSMutableDictionary alloc] init];
        
        // Properties
        /*font = tFont;
        text = textObj;
        allTextsObjects = theTexts;
        */
        
        bgOpacity = 0.0f;
        bgCenter = OKPointMake(sBounds.size.width / 2.0f, sBounds.size.height / 2.0f, 0.0f);
        
        // Background words
        bgWords = [[NSMutableArray alloc] init];
        
        // Count scroll text words
        //scrollTextWords = [self scrollTextWordsCount:text];
        // Set the current index (next word shown on touch) to the first word
        nextWordLine1 = 0;
        nextWordLine2 = 0;
        
        // Create empty lines array
        scrollTextLines = [[NSMutableArray alloc] init];
        
        // Create array that holds max current sentences (this needs to match MAX_FINGERS in EAGLView)
        cScrollTextLines = [[NSMutableArray alloc] initWithCapacity:MAX_SENTENCES];
        // Insert null value in array
        for(int i = 0; i < MAX_SENTENCES; i++)
        {
            [cScrollTextLines insertObject:[NSNull null] atIndex:i];
        }
        
        // Create array that is used to dump "dead" sentences
        removableScrollTextLines = [[NSMutableArray alloc] init];
        
        // Create an array of words (all words)
        wordsLeft = [[NSMutableArray alloc] init];
        wordsRight = [[NSMutableArray alloc] init];
        
        // Animation time tracking
        lUpdate = [[NSDate alloc] init];
        now = [[NSDate alloc] init];
                
        funnelText = textObj;
        funnelFont = tFont;
        [self setupFunnels];
        [self setupText];
        
        
        //get parent view
        parentEaglView = aView;
        
        //setup for 2 fingers swipe right
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [swipeRight setNumberOfTouchesRequired:2];
        [aView addGestureRecognizer:swipeRight];
        [swipeRight release];
        
        //setup for 2 fingers swipe right
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeLeft setNumberOfTouchesRequired:2];
        [aView addGestureRecognizer:swipeLeft];
        [swipeLeft release];
        
        swipeDirectionRight=FALSE;   //Left=FALSE, Right=TRUE
        swipeOccured=FALSE;
        
        //init lastTouchTimes
        //touchActivity[0] = 0;
        //touchActivity[1] = 0;
        touchActivity=0;
        touchActivityEnd=0;
        touchCount=0;
        lastTouchTimes[0] = -1;
        lastTouchTimes[1] = -1;
        flickerLastUpdate=0;
        
        [self setupAudio];
        incrementSpeedLayer=1;
        
    }
    return self;
}


- (void)handleSwipeRight:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"Handle Swipe Right");
    swipeDirectionRight=TRUE;
    swipeOccured=TRUE;
    incrementSpeedLayer++;
    
}

- (void)handleSwipeLeft:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"Handle Swipe Left");
    swipeDirectionRight=FALSE;
    swipeOccured=TRUE;
    incrementSpeedLayer--;
    if(incrementSpeedLayer<=0)
        incrementSpeedLayer=0;
    
}

-(void) setupAudio {
   
    //init sound manager
    soundManager = [[SoundManager alloc] init];
    funnelSounds = [[NSMutableArray alloc] init];
    
    [NSString stringWithFormat:@"%@.%@", AUDIO_DRONE, AUDIO_FORMAT];
    
    //load sounds
    [soundManager loadSample:[NSString stringWithFormat:@"%@.%@", AUDIO_DRONE, AUDIO_FORMAT] folder:@"Sounds"];
    for(int i = 1; i <= AUDIO_NUM_SHORT_SOUNDS; i++)
    {
        [soundManager loadSample:[NSString stringWithFormat:@"%@-%d.%@", AUDIO_SHORT, i, AUDIO_FORMAT] folder:@"Sounds"];
    }
    
    //start play of blood sound on repeat
    [soundManager repeat:[NSString stringWithFormat:@"%@.%@", AUDIO_DRONE, AUDIO_FORMAT]];

}

-(int) nextFunnelSound {
    if([funnelSounds count]==0)
        [self resetFunnelSounds];
    
    int number = [[funnelSounds objectAtIndex:0] integerValue];
    [funnelSounds removeObjectAtIndex:0];
    
    return number;
}
       
-(void) resetFunnelSounds {
    [funnelSounds removeAllObjects];
    
    NSMutableArray* ordered = [[NSMutableArray alloc] init];
    //ArrayList<Integer> ordered = new ArrayList<Integer>();
    for(int i = 1; i <= AUDIO_NUM_SHORT_SOUNDS; i++)
        //ordered.add(i);
        [ordered addObject:[NSNumber numberWithInt:i]];
    
    while ([ordered count]!=0)
    {
        int next = (int) arc4random()%([ordered count]);
        [funnelSounds addObject:[ordered objectAtIndex:next]];
        [ordered removeObjectAtIndex:next];
    }
}
        
/**
 * Get the total number of words in a page of text
 * @param index index of the page
 * @return
 */
-(int) totalWordsForText:(int)index {
    int count = 0;
    
    //load current text
    NSMutableArray *someLines = [textFiles objectAtIndex:index];
    for(Line *aLine in someLines)
    {
        count +=[[aLine words]count];
    }
    return count;
}

//reupdate the funnels text only
-(void) updateFunnelText:(OKTextObject*)textObj
{
    //both left and right will contain same texts
    funnelText = textObj;
    funnelTextRight=textObj;
    [self setupFunnels];
}

//reupdate the funnels text only
-(void) updateFunnelTextLeft:(OKTextObject*)textObjLeft right:(OKTextObject*)textObjRight
{
    funnelText=textObjLeft;
    funnelTextRight=textObjRight;
    [self setupFunnels];
}

-(void) setupFunnels {
    
    //get words from the poem
    if(wordsLeft)
        [wordsLeft removeAllObjects];
    NSLog(@"Number of sentences: %d",[funnelText.sentenceObjects count]);
    for(OKSentenceObject *temp in funnelText.sentenceObjects)
    {
        NSLog(@"A Sentence: %@ lenght:%d", [temp sentence], [[temp sentence] length] );
        //do not use empty lines.
        if([[temp sentence] length] <=1 )
            continue;
        for(OKWordObject *aWord in [temp wordObjects])
        {
            NSLog(@"A word: %@", [aWord word]);
            [wordsLeft addObject:aWord];
        }
    }
    
    if(wordsRight)
        [wordsRight removeAllObjects];
    //get words from the right poem
    NSLog(@"Number of sentences right: %d",[funnelTextRight.sentenceObjects count]);
    for(OKSentenceObject *temp in funnelTextRight.sentenceObjects)
    {
        NSLog(@"A Sentence right: %@ lenght:%d", [temp sentence], [[temp sentence] length] );
        //do not use empty lines.
        if([[temp sentence] length] <=1 )
            continue;
        for(OKWordObject *aWord in [temp wordObjects])
        {
            NSLog(@"A word Right: %@", [aWord word]);
            [wordsRight addObject:aWord];
        }
    }
       
    //create the funnel
    if(funnels)
        [funnels release];
    
    funnels = [[NSMutableArray alloc] init];
    Funnel *aFunnel = [[Funnel alloc] initFunnelWithWords:wordsLeft x:(sBounds.size.width/4) y:-FUNNEL_FONT_SIZE font:funnelFont fontScale:FUNNEL_FONT_SCALING renderingBounds:sBounds];
    [aFunnel setColorRange:FUNNEL_COLOR_RANGE[0] e:FUNNEL_COLOR_RANGE[1]];
    [aFunnel setSpeed:FUNNEL_SPEED];
    [funnels addObject:aFunnel];
    
    //Funnel *aFunnel2 = [[Funnel alloc] initFunnelWithWords:wordsRight x:(sBounds.size.width/4)*3 y:-FUNNEL_FONT_SIZE font:funnelFont fontScale:FUNNEL_FONT_SCALING renderingBounds:sBounds];
    Funnel *aFunnel2 = [[Funnel alloc] initFunnelWithWords:wordsRight x:(sBounds.size.width/4)*3 y:-FUNNEL_FONT_SIZE font:funnelFont fontScale:FUNNEL_FONT_SCALING renderingBounds:sBounds];
    [aFunnel2 setColorRange:FUNNEL_COLOR_RANGE[0] e:FUNNEL_COLOR_RANGE[1]];
    [aFunnel2 setSpeed:FUNNEL_SPEED];
    [funnels addObject:aFunnel2];
    
}

//
//  Setup the background texts.
//
-(void) setupText {
    layers = [[NSMutableArray alloc] init];
    
    //load the 3 texts (letter-3.txt, letter-2.txt, letter-1.txt)
    for(int i=0; i<3; i++)
    {
        //Read the text from file and create the OKTextObject
        /////////////////////////
        NSString* path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"letter-%d", 3-i] ofType:@"txt"];
        NSMutableString* content = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        // Clean text replace em dash (charID 8212) with - (charID 45)
        unichar emdash = 8212;
        [content replaceOccurrencesOfString:[NSString stringWithFormat:@"%C", emdash] withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
        
        NSString *fontName;
        if(i<2)
            fontName = SCROLL_FONTS[i];
        else
            fontName = SCROLL_FONTS[1];
        
        NSLog(@"Font name Scroll i=%d = %@", i, fontName);
        
        OKTessFont *letterFont = [[OKTessFont alloc] initWithControlFile:fontName scale:1.0 filter:GL_LINEAR];
        [letterFont setColourFilterRed:0 green:0 blue:0 alpha:0];
        
        NSLog(@"Letter font= %@", letterFont);
        
        OKTextObject *letterText = [[OKTextObject alloc] initWithText:content withTessFont:letterFont andCanvasSize:sBounds.size];
        
        //calculate the total height for the lines of the text
        //////////////////////////////////////////////////////
        float totalHeight=0;
        int totalValidSentences=0;
        NSLog(@"Number of sentences: %d",[letterText.sentenceObjects count]);
        for(OKSentenceObject *temp in letterText.sentenceObjects)
        {
            NSLog(@"temp : %@", [temp sentence]);
            //make sure the line is not empty
            if([temp getWitdh]!=0){
                float aScale = sBounds.size.width/[temp getWitdh];
                totalHeight = totalHeight + (aScale * [temp getHeight]);
                totalValidSentences++;
            }
        }
        //evaluate line spacing
        //float lineSpacing = (sBounds.size.height - totalHeight)/(totalValidSentences+1);
        float lineSpacing = 10;
        
        // Create the TextLayer object
        TextLayer *layer = [[TextLayer alloc] initTextLayerWithBounds:sBounds width:(sBounds.size.width-SCROLL_HORIZONTAL_MARGINS[i]*2) h:(sBounds.size.height-SCROLL_VERTICAL_MARGINS[i]*2)];
        
        // Font based on png image
        NSString *fontFilePath = (NSString*)[OKTextManager fontPathForFile:[OKPoEMMProperties objectForKey:FontFile] ofType:nil ];
        NSString *fontImagePath = (NSString*)[OKTextManager fontPathForFile:[OKPoEMMProperties objectForKey:FontFile] ofType:@"png" ];
        
        
        NSLog(@"FontFilePath: %@, FontImagePath: %@", fontFilePath, fontImagePath);
         #warning SM-FONT
     /* CGSize displaySize;
        GLfloat scale = [[OKPoEMMProperties objectForKey:@"FontScale"] floatValue]/100; //since it's % value on PoEMMaker
        NSLog(@"Scale is: %f", scale);
        //scale = 3;
      if(currentFont) {
            currentFont = nil;
            [currentFont release];
        }
        currentFont = [[Font alloc] initWithFontImageNamed:fontImagePath controlFile:fontFilePath scale:scale filter:GL_LINEAR];
        [currentFont setColourFilterRed:SCROLL_COLORS[0]
                                  green:SCROLL_COLORS[1]
                                   blue:SCROLL_COLORS[0]
                                  alpha:1];
*/
        
        /*
        //Create the lines object and add to TextLayer object
        int countLine=1;
        float positionY = sBounds.size.height;
        for(OKSentenceObject *temp in letterText.sentenceObjects)
        {
            NSLog(@"Setup the lines:%@ width=%f", [temp sentence], [temp getWitdh]);
            //make sure the line is not empty
            if([temp getWitdh]!=0){
                //find the best size to fit the screen
                float lineScale = (sBounds.size.width - SCROLL_HORIZONTAL_MARGINS[i]*2)/[temp getWitdh];
                
                 Font *newFont= [[Font alloc] initWithFontImageNamed:fontImagePath controlFile:fontFilePath scale:lineScale filter:GL_LINEAR];
                [newFont setColourFilterRed:SCROLL_COLORS[0]
                                          green:SCROLL_COLORS[1]
                                           blue:SCROLL_COLORS[0]
                                          alpha:1];
                
                #warning SM-FONT
                //Line *aLine = [[Line alloc] initWithScale:lineScale font:letterFont source:temp.wordObjects start:0 renderingBounds:sBounds positionY:positionY];
                Line *aLine = [[Line alloc] initWithScaleImageFontbased:lineScale font:letterFont imageFont:newFont source:temp.wordObjects start:0 renderingBounds:sBounds positionY:positionY];
                
                [aLine setHeight:[temp getHeight]*lineScale];
                positionY = positionY - [temp getHeight]*lineScale - lineSpacing;
                //positionY = 100;
                NSLog(@"CountLine: %d positiony: %f", countLine, positionY);
                [aLine setPosX:0 y:positionY z:0];
                [layer addLine:aLine];
                [aLine release];
                //[newFont release];
                countLine++;
            }
        }
        */
        
        
       // Font *newFont;
       // newFont= [[Font alloc] initWithFontImageNamed:fontImagePath controlFile:fontFilePath scale:1 filter:GL_LINEAR];

        int countLine=1;
        float positionY = sBounds.size.height;
        for(OKSentenceObject *temp in letterText.sentenceObjects)
        {
            NSLog(@"Setup the lines:%@ width=%f", [temp sentence], [temp getWitdh]);
            //make sure the line is not empty
            if([temp getWitdh]!=0){
                //find the best size to fit the screen
                float lineScale = (sBounds.size.width - SCROLL_HORIZONTAL_MARGINS[i]*2)/[temp getWitdh];
                
                Font *newFont;
               
                if(lineScale<1){
                    NSLog(@"linescale1=%f", lineScale);
                    newFont= [[Font alloc] initWithFontImageNamed:fontImagePath controlFile:fontFilePath scale:lineScale filter:GL_LINEAR];

                }
                else{
                    NSLog(@"linescale2=%f", lineScale);
                    //lineScale = lineScale * (36/128);
                    newFont= [[Font alloc] initWithFontImageNamed:fontImagePath controlFile:fontFilePath scale:lineScale filter:GL_LINEAR];
 
                }
                 
                
         
                #warning SM-FONT
                //Line *aLine = [[Line alloc] initWithScale:lineScale font:letterFont source:temp.wordObjects start:0 renderingBounds:sBounds positionY:positionY];
                
                Line *aLine = [[Line alloc] initWithScaleImageFontbased:lineScale font:letterFont imageFont:newFont source:temp.wordObjects start:0 renderingBounds:sBounds positionY:positionY];
                [aLine setHeight:[temp getHeight]*lineScale];
                positionY = positionY - [temp getHeight]*lineScale - lineSpacing;
                //positionY = 100;
                NSLog(@"CountLine: %d positiony: %f", countLine, positionY);
                [aLine setPosX:0 y:positionY z:0];
                [layer addLine:aLine];
                [aLine release];
                //[newFont release];
                countLine++;
            }
        }

        
        
        
        NSLog(@"Number of lines = %d", countLine);
        [layers addObject:layer];
        [layer release];
        
    }
    NSLog(@"Layer0 line count:%d",[[layers objectAtIndex:0] lines].count);
    NSLog(@"Layer1 line count:%d",[[layers objectAtIndex:1] lines].count);
    
}



//
//  Get current ms time
//
- (long long) getMillis{
    
    //long long nowMillis = (long long)([[NSDate date] timeIntervalSince1970])*1000;
    
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



- (Line*) createLine:(int)start {
    Line *newLine = [[Line alloc] initWithFont:font source:wordsLeft start:start renderingBounds:sBounds];
    
    //return [[Line alloc] initWithFont:font source:words start:start renderingBounds:sBounds];
}


#pragma mark - DRAW

- (void) draw
{
    
    //Millis since last draw
    DT = (long)([now timeIntervalSinceDate:lUpdate] * 1000);
    [lUpdate release];
    
    //Enable Blending
    glEnable(GL_BLEND);
    
    // Update
    [self update:DT];
    [self updateActivity];
    [self updateFunnels];
    [self updateLayers];
    
    [self drawBackground];
    [self drawLayer:0];
    [self drawFunnel:0];
    [self drawLayer:1];
    [self drawFunnel:1];
    [self drawLayer:2];

    //check if it's time to change the text (and change if it is)
    long long nowTime = [self getMillis];
       
    //Disable Blending
    glDisable(GL_BLEND);
    
    //Keep track of time    
    lUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:[now timeIntervalSince1970]];
    
    [now release];
    now = [[NSDate alloc] init];
    frameCount++;
    
   }


-(void) updateActivity
{
    NSLog(@"touch activity=%f", touchActivity);
    //check touches and increase activity meter for each touch
    if(touchActivityEnd>[self getMillis])
     {
         if([ctrlPtsTouch count]==0 && touchActivity<0.5)
         {
             touchActivity += TOUCH_ACTIVITY_INCREMENT;
         }
         else if([ctrlPtsTouch count]>1 && touchActivity<1)
         {
             touchActivity += TOUCH_ACTIVITY_INCREMENT;
         }
             
         if(touchActivity > 1.0)
             touchActivity=1.0;
     }
     else if(touchActivity>0)
     {
         touchActivity -=TOUCH_ACTIVITY_DECREMENT;
         if (touchActivity<0)
             touchActivity=0;
     }
    
    //NSLog(@"TouchActivity=%f", touchActivity);
    
}


/*
-(void) updateFunnelTouch{
    for(Funnel *f in funnels) {
        BOOL found = false;
        
        //go through all the touch
        for(id key in ctrlPtsTouch)
        {
            id idTouch = [ctrlPtsTouch objectForKey:key];
            Touch *aTouch = (Touch*)idTouch;
            if(aTouch){
                if(aTouch.touchID == f.touch){
                    //NSLog(@"Touch found");
                    found=true;
                    break;
                }
            }
        }
        if(!found){
            f.touch = -1;
        }
    }
    
    //for each touch, check if we need to create a funnel
    //or update the target position of a funnel
    for(id key in ctrlPtsTouch)
    {
        id idTouch = [ctrlPtsTouch objectForKey:key];
        Touch *t = (Touch*)idTouch;
        if(t){
            BOOL found = false;
            for(Funnel *f in funnels) {
                if(f.touch == t.touchID){
                    [f setTarget:t.x y:t.y];
                    found = true;
                }
            }
            
            if(!found){
                
                Funnel *funnel;
                if(t.x < sBounds.size.width/2)
                    funnel = [funnels objectAtIndex:0];
                else
                    funnel = [funnels objectAtIndex:1];
                
                if(funnel.touch == -1){
                    [funnel setTarget:t.x y:t.y];
                    funnel.touch = t.touchID;
                    FunnelString *last = [funnel last];
                    
                    if (last==nil || ![last isInside:OKPointMake(t.x, t.y, 0)]){
                        NSLog(@"Create a word");
                        [funnel next];
                        int nextSnd = [self nextFunnelSound];
                        [soundManager play:[NSString stringWithFormat:@"%@-%d.%@", AUDIO_SHORT, nextSnd, AUDIO_FORMAT] volume:0.5];
                    }
                }
                
            }
        }
    }

}
*/


-(void) updateFunnels {
    //check if the touches associated with the funnels still exists
    
    
    for(Funnel *f in funnels) {
        BOOL found = false;
        
        //go through all the touch
        
        for(id key in ctrlPtsTouch)
        {
            id idTouch = [ctrlPtsTouch objectForKey:key];
            Touch *aTouch = (Touch*)idTouch;
            if(aTouch){
                if(aTouch.touchID == f.touch){
                    //NSLog(@"Touch found");
                    found=true;
                    break;
                }
            }
        }
        
        if(!found){
            f.touch = -1;
        }
    }
    
    //for each touch, check if we need to create a funnel
    //or update the target position of a funnel
    bool clearCtrlPtsTouchRemoved=false;
    for(id key in ctrlPtsTouchRemoved)
    {
        id idTouch = [ctrlPtsTouchRemoved objectForKey:key];
        Touch *t = (Touch*)idTouch;
        if(t){
            BOOL found = false;
            for(Funnel *f in funnels) {
                if(f.touch == t.touchID){
                    [f setTarget:t.x y:t.y];
                    found = true;
                }
            }
            
            if(!found){
                
                Funnel *funnel;
                if(t.x < sBounds.size.width/2)
                    funnel = [funnels objectAtIndex:0];
                else
                    funnel = [funnels objectAtIndex:1];
                
                if(funnel.touch == -1){
                    [funnel setTarget:t.x y:t.y];
                    funnel.touch = t.touchID;
                    FunnelString *last = [funnel last];
                    
                    if (last==nil || ![last isInside:OKPointMake(t.x, t.y, 0)]){
                        NSLog(@"Create a word");
                        [funnel next];
                        int nextSnd = [self nextFunnelSound];
                        [soundManager play:[NSString stringWithFormat:@"%@-%d.%@", AUDIO_SHORT, nextSnd, AUDIO_FORMAT] volume:0.5];
                        clearCtrlPtsTouchRemoved=true;
                    }
                }
                 
            }
        }
    }
    
    if(clearCtrlPtsTouchRemoved)
        [ctrlPtsTouchRemoved removeAllObjects];
    
    //update funnels
    for(Funnel *f in funnels)
        [f update:DT];
   
}


-(void) drawFunnel:(int)index
{
    Funnel *f = [funnels objectAtIndex:index];
    if(f)
       [f draw];
}


-(void) updateLayers
{
    int i=0;
    
    bool updateFlicker=false;
    if(flickerLastUpdate+50<[self getMillis])
    {
        updateFlicker=true;
        flickerLastUpdate = [self getMillis];
    }
    
    for(TextLayer *layer in layers) {
        //float s = SCROLL_SPEEDS[i];
        //scroll layers

        //layer.y -= SCROLL_SPEEDS[i];
     
        layer.y -= SCROLL_SPEEDS[i]*incrementSpeedLayer;
        //make letters flicker
        //NSLog(@"Activity = %f", activity);
        float touch;
        
        if(SCROLL_FLICKER_LAYERS[i])
        {
            if(updateFlicker)
            {
                [layer flicker:SCROLL_FLICKER_SPEED time:SCROLL_FLICKER_TIME activity:touchActivity*SCROLL_FLICKER_ACTIVITY_MULTIPLIER];
            }
        }
        
        i++;
    }
}


-(void) drawLayer:(int)index
{
    //pushMatrix();
    glPushMatrix();
    glTranslatef(SCROLL_HORIZONTAL_MARGINS[index], SCROLL_VERTICAL_MARGINS[index], 0);
 
    glColor4f((float)(SCROLL_COLORS[index]>>16 & 0xFF)/255, (float)(SCROLL_COLORS[index]>>8 & 0xFF)/255, (float)(SCROLL_COLORS[index] & 0xFF)/255, (float)(SCROLL_COLORS[index]>>24 & 0xFF)/255);
  
    TextLayer *layer = [layers objectAtIndex:index];
    [layer draw];
    glPopMatrix();
    
}


-(void) drawBackground
{
   //clear background
    glColor4f(GROUND_COLOR[0], GROUND_COLOR[1],GROUND_COLOR[2],GROUND_COLOR[3]);
    GLfloat vertices2[] = { 0, (float)sBounds.size.height,
        (float)sBounds.size.width, (float)sBounds.size.height,
        (float)sBounds.size.width, 0,
        0, 0 };
    glPushMatrix();
    glVertexPointer(2, GL_FLOAT, 0, vertices2);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glPopMatrix();

    //draw sky
    float horizon = sBounds.size.height/2;
    float sky_split = 0;
    
    float cell_height = LIGHTNING_CELL_HEIGHT + (int)(([OKNoise noiseX:(float)([self getMillis]/10000)]-0.5f)*2*LIGHTNING_CELL_MARGIN);
    
    //NSLog(@"cell_height = %f", cell_height);
    float num_rows;
    num_rows = [OKNoise noiseX:(float)([self getMillis]*LIGHTNING_ROWS_SPEED/10000)];
    //NSLog(@"num_rows = %f", num_rows);
    num_rows = [self map:num_rows istart:0.05f istop:0.35f ostart:0 ostop:1];
    num_rows = [self constrain:num_rows low:0 high:1];
    num_rows *= sBounds.size.height/cell_height;

    float cell_width = sBounds.size.width/(float)LIGHTNING_COLUMNS;
    float lightning_height = cell_height * num_rows;
    
    [OKNoise noiseDetail:4 falloff:0.5f];
    //float addHorizon =([OKNoise noiseX:([self getMillis]*HORIZON_SPEED)]-0.5f)*2*HORIZON_MARGIN;
    float addHorizon =([OKNoise noiseX:([self getMillis]*HORIZON_SPEED)]-0.5f)*sBounds.size.height/4;
    horizon += addHorizon;
    sky_split = [OKNoise noiseX:([self getMillis]/10000.0f)]*sBounds.size.width;
    
    glColor4f(SKY_COLOR[0], SKY_COLOR[1], SKY_COLOR[2], SKY_COLOR[3]);
    
     GLfloat vertices[] = {0, (float)sBounds.size.height,
        (float)sBounds.size.width, (float)sBounds.size.height,
        (float)sBounds.size.width, (float)horizon,
        0, (float)horizon };
    glPushMatrix();
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glPopMatrix();
    
    GLfloat vertices3[] = {sky_split, horizon,
        sky_split, horizon-cell_height,
        (float)sBounds.size.width, horizon-cell_height,
        (float)sBounds.size.width, horizon };
    glPushMatrix();
    glVertexPointer(2, GL_FLOAT, 0, vertices3);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glPopMatrix();


    //time offset
    float to = [self getMillis]*LIGHTNING_HORIZONTAL_SPEED;
    
    //horizon += ([OKNoise noiseX:(float)([self getMillis])]-0.5f)*2*HORIZON_MARGIN;
    //horizon += ([OKNoise noiseX:(float)([self getMillis])]-0.5f)*sBounds.size.height/4;
    horizon = sBounds.size.height/2;
	
    float massMult = [OKNoise noiseX:(float)([self getMillis]/(10000.0f/LIGHTNING_MASS_SPEED))];

    //get color for lightning
    glColor4f((float)(LIGHTNING_COLOR>>16 & 0xFF)/255, (float)(LIGHTNING_COLOR>>8 & 0xFF)/255, (float)(LIGHTNING_COLOR & 0xFF)/255 , (float)(LIGHTNING_COLOR>>24 & 0xFF)/255);

    
    //draw lighting
    for(int i = 0; i < LIGHTNING_COLUMNS; i++) {
        for(int j = 0; j < (int)num_rows; j++) {
            
            float c;
            if(i>=LIGHTNING_COLUMNS/2)
                c = i - to;
            else
                c = i + to;
            
            float colorVal;
            NSScanner *scanner = [NSScanner scannerWithString:@"0x00FFFFFF"];
            [scanner scanHexFloat:&colorVal];
            
            float noiseValue;
            noiseValue = [OKNoise noiseX:c*LIGHTNING_HORIZONTAL_NOISE y:j*LIGHTNING_VERTICAL_NOISE-[self getMillis]*LIGHTNING_VERTICAL_SPEED];
            
            /*
            if(noiseValue < LIGHTNING_MASS * massMult - [self activity] * LIGHTNING_TOUCH_EFFECT)
                glColor4f((float)(LIGHTNING_COLOR>>16 & 0xFF)/255, (float)(LIGHTNING_COLOR>>8 & 0xFF)/255, (float)(LIGHTNING_COLOR & 0xFF)/255 , (float)(LIGHTNING_COLOR>>24 & 0xFF)/255);
            else
                continue;
             */
            if(noiseValue < LIGHTNING_MASS * massMult - touchActivity * LIGHTNING_TOUCH_EFFECT)
            {
                GLfloat verticesLighting[] = { i*cell_width, horizon - lightning_height/2 + j*cell_height,
                    i*cell_width, horizon - lightning_height/2 + j*cell_height + cell_height,
                    i*cell_width + cell_width, horizon - lightning_height/2 + j*cell_height + cell_height,
                    i*cell_width + cell_width, horizon - lightning_height/2 + j*cell_height };
                
                glPushMatrix();
                //glTranslatef(i*cell_width, j*cell_height, 0);
                glVertexPointer(2, GL_FLOAT, 0, verticesLighting);
                glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                glPopMatrix();
            }
            
        }
    }
    
}

-(float) map:(float)value istart:(float)istart istop:(float)istop ostart:(float)ostart ostop:(float)ostop
{
    return ((float)(ostart + (ostop - ostart) * ((value - istart) / (istop - istart))));
}

-(float) constrain:(float)value low:(float)low high:(float)high
{
    if(value>high)
        value=high;
    if(value<low)
        value=low;
    return value;
}


- (void) update:(long)dt
{
    
    // Update control points
    for(NSString *aKey in ctrlPts)
    {
        KineticObject *ko = [ctrlPts objectForKey:aKey];
        [ko update:dt];
    }
    
    //update audio
    [soundManager update];
    
    // Update text
    //[self updateText:dt];
    
}


#pragma mark - Touches

- (void) setCtrlPts:(int)aID atPosition:(CGPoint)aPosition
{
    
    swipeOccured=FALSE;
    
    NSLog(@"New Touch");
    lastTouch = [self getMillis];
    
    //find the touch
    Touch *aTouch = [ctrlPtsTouch objectForKey:[NSString stringWithFormat:@"%i", aID]];

    touchActivityEnd = [self getMillis] + (long long)TOUCH_ACTIVITY_HOLD_TIME;
    
    //NSLog(@"self= %lld, TouchActivityEnd= %lld", [self getMillis], touchActivityEnd);

    //if the touch is found, update the pos with touch offset
    if(aTouch){
        [aTouch set:aPosition.x y:(aPosition.y+TOUCH_OFFSET)];
    }
    //else, create a new one in the dict, with Touch offset.
    else{
        aTouch = [[Touch alloc] initWithTouch:aID x:(float)aPosition.x y:(float)(aPosition.y+TOUCH_OFFSET) start:lastTouch];
        
        //NSLog(@"Adding touch in ctrlpts : %@, x:%f y:%f", newTouch, [newTouch getX], [newTouch getY]);
        [ctrlPtsTouch setObject:aTouch forKey:[NSString stringWithFormat:@"%i", aID]];
        [aTouch release];
    }
     
}

- (void) removeCtrlPts:(int)aID atPosition:(CGPoint)aPosition
{
    //execute only if there are ctrlPtsTouch in array
    if([ctrlPtsTouch count] == 0) return;
    
    //remove the touch
    //Touch t = touches.remove(new Integer(id));
    Touch *t = [ctrlPtsTouch objectForKey:[NSString stringWithFormat:@"%i", aID]];
    [ctrlPtsTouch removeObjectForKey:[NSString stringWithFormat:@"%i", aID]];
    
     //if no swipe occured in meantime, add the touch to ctrlPtsTouchRemoved... needed to finally create a new funnel
    if(!swipeOccured){
        Touch *aTouch = [[Touch alloc] initWithTouch:aID x:(float)aPosition.x y:(float)(aPosition.y+TOUCH_OFFSET) start:lastTouch];
        [ctrlPtsTouchRemoved setObject:aTouch forKey:[NSString stringWithFormat:@"%i", aID]];
        [aTouch release];
    }
}


- (void) touchesBegan:(int)aID atPosition:(CGPoint)aPosition
{        
    // Set Control Point
    [self setCtrlPts:aID atPosition:aPosition];
}

- (void) touchesMoved:(int)aID atPosition:(CGPoint)aPosition
{
    // Set Control Point
    [self setCtrlPts:aID atPosition:aPosition];
}

- (void) touchesEnded:(int)aID atPosition:(CGPoint)aPosition
{
    
    // Remove Control Point
    [self removeCtrlPts:aID atPosition:aPosition];
}

- (void) touchesCancelled:(int)aID atPosition:(CGPoint)aPosition
{
    // Remove Control Point
    [self removeCtrlPts:aID atPosition:aPosition];
}

//
// Count number of sounds to hear per text
//
-(int) numSoundsForText:(int) index {
    
    if (index < 5)
        return 1;
    else if (index < 6){
        /*
        if([self countSnakesBiting]<2)
            return 1;
        else
            return 2;
         */
    }
    else
        return 2;
}


- (void) dealloc
{    
    [ctrlPts release];
    [bgWords release];
    [scrollTextLines release];
    [removableScrollTextLines release];
    [wordsLeft release];
    [lUpdate release];
    [now release];
    
    [super dealloc];
}

@end
