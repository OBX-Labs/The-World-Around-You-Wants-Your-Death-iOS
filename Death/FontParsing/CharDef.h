//
//  CharDef.h
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Image.h"

@interface CharDef : NSObject {
	// ID of the character
	int charID;
	// X location on the spritesheet
	int x;
	// Y location on the spritesheet
	int y;
	// Width of the character image
	int width;
	// Height of the character image
	int height;
	// The X amount the image should be offset when drawing the image
	int xOffset;
	// The Y amount the image should be offset when drawing the image
	int yOffset;
	// The amount to move the current position after drawing the character
	int xAdvance;
	// The image containing the character
	Image *image;
	// Scale to be used when rendering the character
	float scale;
    
    BOOL visible;
}

@property(nonatomic, retain)Image *image;
@property(nonatomic)int charID;
@property(nonatomic)int x;
@property(nonatomic)int y;
@property(nonatomic)int width;
@property(nonatomic)int height;
@property(nonatomic)int xOffset;
@property(nonatomic)int yOffset;
@property(nonatomic)int xAdvance;
@property(nonatomic)float scale;
@property (nonatomic) BOOL visible;

- (id)initCharDefWithFontImage:(Image*)image scale:(float)fontScale;

@end
