//
//  CoreTextView.h
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
#import <CoreText/CoreText.h>

@interface CoreTextView : UIView {
}

@property(nonatomic, retain) NSString *text;
@property(nonatomic, assign) NSInteger columnCount;
@property(nonatomic, assign) NSInteger fontSize;
@property(nonatomic, assign) CTTextAlignment textAlignment;

@end
