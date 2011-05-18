//
//  CoreTextViewController.h
//  ParticleText
//
//	Copyright (c) 2011, Auerhaus Development, LLC
//
//	This program is free software. It comes without any warranty, to
//	the extent permitted by applicable law. You can redistribute it
//	and/or modify it under the terms of the Do What The Fuck You Want
//	To Public License, Version 2, as published by Sam Hocevar. See
//	http://sam.zoy.org/wtfpl/COPYING for more details.
//

#import <UIKit/UIKit.h>

@interface CoreTextViewController : UIViewController {
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *fontSizeSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *textAlignmentSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *columnCountSegmentedControl;

- (IBAction)fontSizeDidChange:(UISegmentedControl *)sender;
- (IBAction)textAlignmentDidChange:(UISegmentedControl *)sender;
- (IBAction)columnCountDidChange:(UISegmentedControl *)sender;

@end
