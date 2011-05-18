//
//  AHParticleSystem2D.m
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

#import "AHParticleSystem2D.h"

@implementation AHParticleSystem2D

@synthesize minimumEmissionAngle, maximumEmissionAngle;
@synthesize minimumSpeed, maximumSpeed;
@synthesize minimumLifespan, maximumLifespan;
@synthesize minimumSize, maximumSize;
@synthesize spawnRate, maximumParticleCount;
@synthesize colorGradient;
@synthesize delegate;

- (id)initWithMinimumEmissionAngle:(CGFloat)minAngle 
			  maximumEmissionAngle:(CGFloat)maxAngle 
					  minimumSpeed:(CGFloat)minSpeed 
					  maximumSpeed:(CGFloat)maxSpeed
				   minimumLifespan:(CGFloat)minLifespan 
				   maximumLifespan:(CGFloat)maxLifespan
					   minimumSize:(CGFloat)minSize
					   maximumSize:(CGFloat)maxSize
					 colorGradient:(AHLinearGradient *)gradient
						 spawnRate:(CGFloat)particleSpawnRate 
			  maximumParticleCount:(NSUInteger)maxParticles 
{
	if((self = [super init]))
	{
		minimumEmissionAngle = minAngle;
		maximumEmissionAngle = maxAngle;
		minimumSpeed = minSpeed;
		maximumSpeed = maxSpeed;
		minimumLifespan = minLifespan;
		maximumLifespan = maxLifespan;
		minimumSize = minSize;
		maximumSize = maxSize;
		spawnRate = particleSpawnRate;
		maximumParticleCount = maxParticles;
		
		colorGradient = [gradient retain];
		
		livePool = [[NSMutableArray alloc] initWithCapacity:maximumParticleCount];
		deadPool = [[NSMutableArray alloc] initWithCapacity:maximumParticleCount];
		
		for(size_t i = 0; i < maxParticles; ++i)
		{
			AHParticle2D *particle = [[AHParticle2D alloc] initWithPosition:CGPointZero 
																   velocity:CGPointZero 
															  colorGradient:nil 
																   lifespan:0 
																	   size:0];
			[deadPool addObject:particle];
			[particle release];
		}
	}
	return self;
}

- (void)advanceSystemByTimeInterval:(NSTimeInterval)timeStep {

	particlesPendingSpawn += timeStep * spawnRate;
	while(particlesPendingSpawn >= 1)
	{
		if([deadPool count] == 0) break;
		
		CGFloat lifespan = ((maximumLifespan - minimumLifespan) * (random() / (CGFloat)RAND_MAX)) + minimumLifespan;
		CGFloat size = ((maximumSize - minimumSize) * (random() / (CGFloat)RAND_MAX)) + minimumSize;
		CGFloat angle = ((maximumEmissionAngle - minimumEmissionAngle) * (random() / (CGFloat)RAND_MAX)) + minimumEmissionAngle;
		CGFloat speed = ((maximumSpeed - minimumSpeed) * (random() / (CGFloat)RAND_MAX)) + minimumSpeed;
		CGFloat velox = cosf(angle) * speed;
		CGFloat veloy = sinf(angle) * speed;
		
		AHParticle2D *particle = [deadPool lastObject];
		
		CGPoint spawnPoint = CGPointMake(0, 0);
		if([self.delegate respondsToSelector:@selector(spawnPointForNextParticle)])
		{
			spawnPoint = [delegate spawnPointForNextParticle];
		}
		
		[particle setAge:0];
		[particle setPosition:spawnPoint];
		[particle setVelocity:CGPointMake(velox, veloy)];
		[particle setLifespan:lifespan];
		[particle setSize:size];
		[particle setColorGradient:colorGradient];

		[livePool addObject:particle];
		[deadPool removeLastObject];
		
		--particlesPendingSpawn;
	}
	
	NSMutableArray *deceasedParticles = [NSMutableArray array];
	for(AHParticle2D *particle in livePool)
	{
		BOOL dead = ![particle ageByDuration:timeStep];
		if(dead)
		{
			[deceasedParticles addObject:particle];
		}
	}
	
	[deadPool addObjectsFromArray:deceasedParticles];
	[livePool removeObjectsInArray:deceasedParticles];
}

- (void)randomizeAllParticleVelocities {
	for(AHParticle2D *particle in livePool)
	{
		CGFloat angle = ((maximumEmissionAngle - minimumEmissionAngle) * (random() / (CGFloat)RAND_MAX)) + minimumEmissionAngle;
		CGFloat speed = ((maximumSpeed - minimumSpeed) * (random() / (CGFloat)RAND_MAX)) + minimumSpeed;
		CGFloat velox = cosf(angle) * speed;
		CGFloat veloy = sinf(angle) * speed;
		[particle setVelocity:CGPointMake(velox, veloy)];
	}
}

- (void)extractParticleVertexData:(AHVertexData2D *)vertexData {
	for(AHParticle2D *particle in livePool)
	{
		[particle extractVertexData:vertexData];
		vertexData += 4;
	}
}

- (NSUInteger)liveParticleCount {
	return [livePool count];
}

- (void)dealloc {
	[livePool release], livePool = nil;
	[deadPool release], deadPool = nil;
	[colorGradient release], colorGradient = nil;
	
	[super dealloc];
}

@end
