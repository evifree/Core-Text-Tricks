//
//  ParticleTextView.h
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
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGLDrawable.h>

#import "AHParticleSystem2D.h"

@interface ParticleTextView : UIView <AHParticleSystem2DDelegate> {
	CAEAGLLayer *eaglLayer;
    EAGLContext *context;
	GLuint framebuffer, depthRenderbuffer;
	GLuint colorRenderbuffer;
	GLint bufferWidth, bufferHeight;
	GLuint shaderProgram;
	GLuint texture;
	int projectionMatrixUniform;
	
	AHLinearGradient *gradient;
	AHParticleSystem2D *particleSystem;
	
	NSMutableArray *glyphPaths;
}

- (BOOL)beginDrawLoop;

@end
