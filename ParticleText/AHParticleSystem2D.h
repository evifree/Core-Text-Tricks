//
//  AHParticleSystem2D.h
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
#import "AHParticle2D.h"

@protocol AHParticleSystem2DDelegate <NSObject>
- (CGPoint)spawnPointForNextParticle;
@end

@interface AHParticleSystem2D : NSObject {
	NSMutableArray *deadPool, *livePool;
	CGFloat particlesPendingSpawn;
}

@property(nonatomic, assign) CGFloat minimumEmissionAngle, maximumEmissionAngle;
@property(nonatomic, assign) CGFloat minimumSpeed, maximumSpeed;
@property(nonatomic, assign) CGFloat minimumLifespan, maximumLifespan;
@property(nonatomic, assign) CGFloat minimumSize, maximumSize;
@property(nonatomic, assign) CGFloat spawnRate;
@property(nonatomic, assign) NSUInteger maximumParticleCount;
@property(nonatomic, retain) AHLinearGradient *colorGradient;
@property(nonatomic, assign) id<AHParticleSystem2DDelegate> delegate;

- (id)initWithMinimumEmissionAngle:(CGFloat)minAngle 
			  maximumEmissionAngle:(CGFloat)maxAngle 
					  minimumSpeed:(CGFloat)minSpeed 
					  maximumSpeed:(CGFloat)maxSpeed
				   minimumLifespan:(CGFloat)minLifespan 
				   maximumLifespan:(CGFloat)minLifespan 
					   minimumSize:(CGFloat)minSize
					   maximumSize:(CGFloat)maximumSize
					 colorGradient:(AHLinearGradient *)gradient
						 spawnRate:(CGFloat)particleSpawnRate 
			  maximumParticleCount:(NSUInteger)maxParticles;

- (void)advanceSystemByTimeInterval:(NSTimeInterval)timeStep;

- (void)randomizeAllParticleVelocities;

- (void)extractParticleVertexData:(AHVertexData2D *)vertexData;

- (NSUInteger)liveParticleCount;

@end
