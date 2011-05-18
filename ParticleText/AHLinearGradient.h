//
//  AHLinearGradient.h
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

#import <Foundation/Foundation.h>

/*
	The purpose of AHLinearGradient is to provide a simple interface for a linear 
	gradient, similar to the Mac OS X-only NSGradient. It provides facilities for 
	creating piecewise-linear color gradients with multiple color stops at 
	arbitrary locations and evaluating the interpolated value of the gradient 
	at arbitrary locations.

	AHLinearGradient chooses to assume that all colors are defined in RGB space, 
	but all interpolation is performed in HSV space because of its aesthetic 
	characteristics under interpolation.

	AHLinearGradient provides no facilities for drawing but may be used in 
	conjunction with Core Graphics shading callbacks to fill or stroke paths.
*/
 
@interface AHLinearGradient : NSObject {
	NSArray *colors;
	CGFloat *locations;
}

// Initializes a newly allocated gradient object with the specified colors and 
// color locations.
// If multiple color stops correspond to the same location after clamping, 
// behavior is undefined.
// 
// Designated initializer.
- (id)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locations;

// Initializes a newly allocated gradient object with an pair of endpoint colors.
- (id)initWithStartingColor:(UIColor *)startColor endingColor:(UIColor *)endColor;

// Initializes a newly allocated gradient object with an array of colors.
// If more than two colors are provided, they are spaced at even intervals
- (id)initWithColors:(NSArray *)colors;

// Returns the number of color stops associated with the receiver.
- (NSUInteger)numberOfColorStops;

// Returns information about the color stop at the specified index in the 
// receiver's color array.
- (void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSUInteger)index;

// Returns the color of the gradient at the specified relative location.
// If location is outside of [0,1], the returned color will be clamped to the 
// nearest endpoint.
- (UIColor *)interpolatedColorAtLocation:(CGFloat)location;

@end
