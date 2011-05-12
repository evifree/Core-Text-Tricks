//
//  ParticleTextAppDelegate.h
//  ParticleText
//
//  Created by Warren Moore on 5/11/11.
//  Copyright 2011 Auerhaus Development, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParticleTextViewController;

@interface ParticleTextAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ParticleTextViewController *viewController;

@end
