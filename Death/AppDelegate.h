//
//  AppDelegate.h
//  Death
//
//  Created by Serge on 2013-07-09.
//  Copyright (c) 2013 Serge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OKPoEMM;
@class EAGLView;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) OKPoEMM *poemm;
@property (nonatomic, strong) EAGLView *eaglView;

- (void) loadOKPoEMMInFrame:(CGRect)frame;

@end
