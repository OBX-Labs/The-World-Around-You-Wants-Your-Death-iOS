//
//  CharDef.m
//  BuzzAldrin
//
//  Created by Christian Gratton on 10-12-02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CharDef.h"


@implementation CharDef
@synthesize image, charID, x, y, width, height, xOffset, yOffset, xAdvance, scale;

- (id)initCharDefWithFontImage:(Image*)fontImage scale:(float)fontScale{
	self = [super init];
	if (self != nil) {
		// Reference the image file which contains the spritemap for the characters
		image = fontImage;
		// Set the scale for this character
		scale = fontScale;
        
        visible=true;
	}
	return self;
}


- (NSString *)description {
	// Log what we have created
	return [NSString stringWithFormat:@"CharDef = id:%d x:%d y:%d width:%d height:%d xoffset:%d yoffset:%d xadvance:%d", 
			charID, 
			x, 
			y, 
			width, 
			height, 
			xOffset, 
			yOffset, 
			xAdvance];
}


- (void)dealloc {
	[super dealloc];
}

@end
