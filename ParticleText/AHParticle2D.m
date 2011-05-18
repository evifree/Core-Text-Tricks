//
//  AHParticle2D.m
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

#import "AHParticle2D.h"

@implementation AHParticle2D

@synthesize position, velocity;
@synthesize size;
@synthesize colorGradient;
@synthesize lifespan, age;

// Initializes particle with various state
- (id)initWithPosition:(CGPoint)initialPosition 
			  velocity:(CGPoint)initialVelocity 
		 colorGradient:(AHLinearGradient *)gradient 
			  lifespan:(NSTimeInterval)life
				  size:(CGFloat)aSize
{
	if((self = [super init]))
	{
		position = initialPosition;
		velocity = initialVelocity;
		lifespan = life;
		age = 0.0;
		size = aSize;
		colorGradient = [gradient retain];
	}
	
	return self;
}

- (void)dealloc {
	[colorGradient release], colorGradient = nil;
	
	[super dealloc];
}

- (void)applyAcceleration:(CGPoint)a forDuration:(NSTimeInterval)duration {
	CGFloat vx = velocity.x + a.x * duration;
	CGFloat vy = velocity.y + a.y * duration;
	
	velocity = CGPointMake(vx, vy);
}

- (BOOL)ageByDuration:(NSTimeInterval)duration {
	age += duration;
	
	position = CGPointMake(position.x + (velocity.x * duration), position.y + (velocity.y * duration));
	
	return (age < lifespan);
}

/*
		  1     4
	(0,1) +--<--+ (1,1)
	      |\    |
		  | \   |
	      v  \  ^
	      |   \ |
	      |    \|
	(0,0) +-->--+ (1,0)
		  2     3
 
	Particles are drawn as a triangle strip comprising two triangles.
	The bottom triangle is drawn first (1,2,3; 1,3,4).
	OpenGL uses the convention of lower-left origin.
*/

- (void)extractVertexData:(AHVertexData2D *)vertexData {
	
	CGFloat elapsedLife = age / lifespan;
	UIColor *color = [colorGradient interpolatedColorAtLocation:elapsedLife];
	const CGFloat *rgba = CGColorGetComponents([color CGColor]);
	
	CGFloat halfSize = size * 0.5;
	
	vertexData[0].xy[0] = position.x - halfSize;
	vertexData[0].xy[1] = position.y - halfSize;
	vertexData[0].st[0] = 0.0;
	vertexData[0].st[1] = 0.0;
	vertexData[0].rgba[0] = rgba[0];
	vertexData[0].rgba[1] = rgba[1];
	vertexData[0].rgba[2] = rgba[2];
	vertexData[0].rgba[3] = rgba[3];
	
	vertexData[1].xy[0] = position.x - halfSize;
	vertexData[1].xy[1] = position.y + halfSize;
	vertexData[1].st[0] = 0.0;
	vertexData[1].st[1] = 1.0;
	vertexData[1].rgba[0] = rgba[0];
	vertexData[1].rgba[1] = rgba[1];
	vertexData[1].rgba[2] = rgba[2];
	vertexData[1].rgba[3] = rgba[3];

	vertexData[2].xy[0] = position.x + halfSize;
	vertexData[2].xy[1] = position.y - halfSize;
	vertexData[2].st[0] = 1.0;
	vertexData[2].st[1] = 0.0;
	vertexData[2].rgba[0] = rgba[0];
	vertexData[2].rgba[1] = rgba[1];
	vertexData[2].rgba[2] = rgba[2];
	vertexData[2].rgba[3] = rgba[3];

	vertexData[3].xy[0] = position.x + halfSize;
	vertexData[3].xy[1] = position.y + halfSize;
	vertexData[3].st[0] = 1.0;
	vertexData[3].st[1] = 1.0;
	vertexData[3].rgba[0] = rgba[0];
	vertexData[3].rgba[1] = rgba[1];
	vertexData[3].rgba[2] = rgba[2];
	vertexData[3].rgba[3] = rgba[3];
}


@end
