//
//  AHLinearGradient.m
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

#import "AHLinearGradient.h"
#include "AHColorUtilities.h"

typedef struct 
{ 
	UIColor *color; 
	CGFloat location; 
} AHGradientColorStop;

int compareStops(const void *a, const void *b)
{
	AHGradientColorStop *c1 = (AHGradientColorStop *)a;
	AHGradientColorStop *c2 = (AHGradientColorStop *)b;
	
	return (c1->location < c2->location) ? NSOrderedAscending : NSOrderedDescending;
}

@implementation AHLinearGradient

- (id)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locationArray {
	if((self = [super init]))
	{
		NSAssert([colorArray count] > 1, @"Gradient must be created with at least two color stops");
		
		NSMutableArray *colorsMutable = [NSMutableArray arrayWithCapacity:[colorArray count]];
		locations = malloc([colorArray count] * sizeof(CGFloat));

		// Create temporary structs to correlate colors and stop locations, 
		// then sort stops by location so we can assume order going forward
		AHGradientColorStop *stopArray = calloc([colorArray count], sizeof(AHGradientColorStop));
		for(size_t i = 0; i < [colorArray count]; ++i) {
			stopArray[i].color = [colorArray objectAtIndex:i];
			stopArray[i].location = locationArray[i];
		}
		
		qsort(stopArray, [colorArray count], sizeof(AHGradientColorStop), compareStops);
		
		// Copy sorted stops back into parallel arrays for managing stops
		for(size_t i = 0; i < [colorArray count]; ++i) {
			[colorsMutable addObject:stopArray[i].color];
			locations[i] = stopArray[i].location;
		}
		free(stopArray);
		
		// Retain color array in ivar exposing immutable interface
		colors = [colorsMutable retain];
	}
	return self;
}

- (id)initWithStartingColor:(UIColor *)startColor endingColor:(UIColor *)endColor {
	NSAssert(startColor && endColor, @"Gradient starting and ending color cannot be nil");
	
	NSArray *colorArray = [NSArray arrayWithObjects:startColor, endColor, nil];
	CGFloat locationArray[] = { 0.0, 1.0 };
	
	if((self = [self initWithColors:colorArray atLocations:locationArray]))
	{
	}
	return self;
}

- (id)initWithColors:(NSArray *)colorArray {
	NSAssert([colorArray count] > 1, @"Gradient must be created with at least two colors");
	
	// Initialize array of stop locations with the same count as the color array
	CGFloat *locationArray = malloc([colorArray count] * sizeof(CGFloat));
	locationArray[0] = 0.0;
	locationArray[[colorArray count] - 1] = 1.0;
	
	// Evenly distribute the color stops across the interpolation range
	CGFloat step = 1.0 / ([colorArray count] - 1);
	CGFloat location = step;
	for (size_t i = 1; i < ([colorArray count] - 1); ++i) {
		locationArray[i] = location;
		location += step;
	}
	
	if((self = [self initWithColors:colorArray atLocations:locationArray]))
	{
	}
	
	free(locationArray);
	
	return self;
}

- (void)dealloc {
	[colors release], colors = nil;
	free(locations); locations = NULL;
	
	[super dealloc];
}

- (NSUInteger)numberOfColorStops {
	return [colors count];
}

- (void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSUInteger)index {
	// Ensure the requested color stop is in range
	if(index < [self numberOfColorStops])
	{
		if(color) *color = [colors objectAtIndex:index];
		if(location) *location = locations[index];
	}
	else
	{
		// Color stops that are out of range are undefined
		if(color) *color = nil;
		if(location) *location = 0.0;
	}
}

- (UIColor *)interpolatedColorAtLocation:(CGFloat)location {
	// Clamp
	if(location < 0.0) location = 0.0;
	if(location > 1.0) location = 1.0;
	
	// Ensure we only use one color stop if we're at one of the endpoints
	if(location <= locations[0]) {
		return [colors objectAtIndex:0];
	}
	
	if(location >= locations[[colors count] - 1]) {
		return [colors objectAtIndex:([colors count] - 1)];
	}
	
	// Determine the indexes of the color stops the current location falls between
	size_t upperStop = 1;
	for(; upperStop < [colors count]; ++upperStop)
	{
		if(locations[upperStop] > location) break;
	}
	
	UIColor *startColor = [colors objectAtIndex:(upperStop - 1)];
	UIColor *endColor = [colors objectAtIndex:upperStop];
	
	// Extract RGBA components from colors
	const CGFloat *startComponents = CGColorGetComponents([startColor CGColor]);
	const CGFloat *endComponents = CGColorGetComponents([endColor CGColor]);
	
	NSAssert(CGColorSpaceGetModel(CGColorGetColorSpace([startColor CGColor])) == 
			 kCGColorSpaceModelRGB, @"Gradient colors must be in an RGB color space");
	NSAssert(CGColorSpaceGetModel(CGColorGetColorSpace([endColor CGColor])) == 
			 kCGColorSpaceModelRGB, @"Gradient colors must be in an RGB color space");
	
	// Convert stop colors from RGB color space to HSV
	CGFloat hsva1[4];
	HSVFromRGB(startComponents[0], startComponents[1], startComponents[2], 
			   &hsva1[0], &hsva1[1], &hsva1[2]);
	hsva1[3] = startComponents[3];

	CGFloat hsva2[4];
	HSVFromRGB(endComponents[0], endComponents[1], endComponents[2], 
			   &hsva2[0], &hsva2[1], &hsva2[2]);
	hsva2[3] = endComponents[3];
	
	// Transform location on gradient into interpolant between the relevant stops
	CGFloat startLocation = locations[upperStop - 1];
	CGFloat endLocation = locations[upperStop];
	CGFloat interpolant = (location - startLocation) / (endLocation - startLocation);

	// Perform interpolation in HSV space
	CGFloat h = 0, s = 0, v = 0, a = 0, r = 0, g = 0, b = 0;
	InterpolateHSVA(interpolant,
					hsva1[0], hsva1[1], hsva1[2], hsva1[3], 
					hsva2[0], hsva2[1], hsva2[2], hsva2[3], 
					&h, &s, &v, &a);
	
	// Convert resultant color back from HSV to RGB
	RGBFromHSV(h, s, v, &r, &g, &b);
	
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
