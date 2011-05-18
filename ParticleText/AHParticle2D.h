//
//  AHParticle2D.h
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
#import "AHLinearGradient.h"
#import "AHVertexData2D.h"

@interface AHParticle2D : NSObject {
}

@property(nonatomic, assign) CGPoint position, velocity;
@property(nonatomic, assign) CGFloat size;
@property(nonatomic, retain) AHLinearGradient *colorGradient;
@property(nonatomic, assign) NSTimeInterval lifespan, age;

// Initializes particle with various state
- (id)initWithPosition:(CGPoint)initialPosition 
			  velocity:(CGPoint)initialVelocity 
		 colorGradient:(AHLinearGradient *)gradient 
			  lifespan:(NSTimeInterval)life
				  size:(CGFloat)size;

// Apply a directed force (such as gravity or attraction) for a time span.
// Since particles are assumed to be massless, desired acceleration is used.
- (void)applyAcceleration:(CGPoint)a forDuration:(NSTimeInterval)duration;

// Cause the particle to age by the specified duration. Returns NO when 
// the particle dies of old age.
- (BOOL)ageByDuration:(NSTimeInterval)duration;

// Write the vertices of the particle into a packed array of vertices
- (void)extractVertexData:(AHVertexData2D *)vertexData;

@end
