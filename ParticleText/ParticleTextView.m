//
//  ParticleTextView.m
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

#import "ParticleTextView.h"
#import "AHParticle2D.h"
#import <CoreText/CoreText.h>

enum 
{
	kVertexAttributePosition,
	kVertexAttributeColor,
	kVertexAttributeTexCoords,
};

@interface ParticleTextView ()
- (BOOL)createContext;
- (BOOL)createFramebuffer;
- (BOOL)loadTextures;
- (BOOL)loadShaders;
- (void)generateGlyphOutlines;
@end

@implementation ParticleTextView

BOOL CheckForExtension(NSString *searchName)
{
	// TODO: cache this
	
	// Cast as if this were ASCII-7. I've never seen an accent mark in an OpenGL extension name.
	const char *extensionsCString = (const char *)glGetString(GL_EXTENSIONS);
    NSString *extensionsString = [NSString stringWithCString:extensionsCString encoding: NSASCIIStringEncoding];
    NSArray *extensionsNames = [extensionsString componentsSeparatedByString:@" "];
    return [extensionsNames containsObject: searchName];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self createContext];
		[self createFramebuffer];
		[self loadTextures];
		[self loadShaders];
		
		[self generateGlyphOutlines];
		
		UIColor *whiteYellow = [UIColor colorWithRed:1.0 green:1.0 blue:0.95 alpha:0.2];
		UIColor *yellow = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.8];
		UIColor *orange = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:0.5];
		UIColor *darkRed = [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:0.3];
		UIColor *ashGray = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.2];
		UIColor *black = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.1];
		CGFloat stopLocations[] = { 0.0, 0.2, 0.4, 0.8, 0.9, 1.0 };
		gradient = [[AHLinearGradient alloc] initWithColors:[NSArray arrayWithObjects:
															 whiteYellow, 
															 yellow, 
															 orange, 
															 darkRed, 
															 ashGray, 
															 black, 
															 nil] 
												atLocations:stopLocations];
		
		particleSystem = [[AHParticleSystem2D alloc] initWithMinimumEmissionAngle:M_PI / 3
															 maximumEmissionAngle:(2 * M_PI) / 3
																	 minimumSpeed:1.0
																	 maximumSpeed:2.0
																  minimumLifespan:4.0
																  maximumLifespan:5.0
																	  minimumSize:8.0
																	  maximumSize:10.0
																	colorGradient:gradient
																		spawnRate:200
															 maximumParticleCount:1000];
		[particleSystem setDelegate:self];
		
		[particleSystem advanceSystemByTimeInterval:1.0]; // Accelerated aging.
	}
    return self;
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
	[self setNeedsDisplay];
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)createContext
{
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	[EAGLContext setCurrentContext:context];
	
	return (context != nil);
}

- (BOOL)createFramebuffer
{
	//CGSize size = [self bounds].size;
	
	eaglLayer = (CAEAGLLayer*)self.layer;
	
	[self setContentScaleFactor:[[UIScreen mainScreen] scale]];
	
	[eaglLayer setOpaque:YES];
	[eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
									  kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									  nil]];
	
	glGenFramebuffers(1, &framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &bufferWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &bufferHeight);
	
	NSLog(@"Backing layer has size %dx%d", bufferWidth, bufferHeight);
	
	glGenRenderbuffers(1, &depthRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, bufferWidth, bufferHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
	
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if(status != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Failed to make complete framebuffer object %x", status);
	}
	
	return (status == GL_FRAMEBUFFER_COMPLETE);
}

- (BOOL)beginDrawLoop
{
	CADisplayLink *displayLink = [self.window.screen displayLinkWithTarget:self selector:@selector(drawFrame)];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[displayLink setFrameInterval:3]; // Display every nth frame
	return (displayLink != nil);
}

- (BOOL)loadTextures {
	NSString *texturePath = [[NSBundle mainBundle] pathForResource:@"smoke_particle" ofType:@"png"];
    NSData *textureData = [[NSData alloc] initWithContentsOfFile:texturePath];
    UIImage *textureImage = [[UIImage alloc] initWithData:textureData];
	
	CGImageRef imageRef = [textureImage CGImage];
    GLuint width = CGImageGetWidth(imageRef);
    GLuint height = CGImageGetHeight(imageRef);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(4 * height * width * sizeof(GLubyte));
    CGContextRef textureContext = CGBitmapContextCreate(imageData, 
												 width, 
												 height, 
												 8 * sizeof(GLubyte),
												 4 * width * sizeof(GLubyte), 
												 colorSpace, 
												 kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
	
    CGContextClearRect(textureContext, CGRectMake(0, 0, width, height) );
    CGContextTranslateCTM(textureContext, 0, 0);
    CGContextDrawImage(textureContext, CGRectMake(0, 0, width, height), imageRef);
	
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
    CGContextRelease(textureContext);
	
    free(imageData);
	
    [textureImage release];
    [textureData release];
	
	return YES;
}

- (BOOL)loadShaders {
	GLint status = 0;

	NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
	NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"];
	
	NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:NULL];
	NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:NULL];
	
	const char *vertexShader = [vertexShaderString cStringUsingEncoding:NSUTF8StringEncoding];
	const char *fragmentShader = [fragmentShaderString cStringUsingEncoding:NSUTF8StringEncoding];
	
	GLuint vertexShaderName = glCreateShader(GL_VERTEX_SHADER);
	GLuint fragmentShaderName = glCreateShader(GL_FRAGMENT_SHADER);
	
    glShaderSource(vertexShaderName, 1, &vertexShader, NULL);
    glCompileShader(vertexShaderName);
    glGetShaderiv(vertexShaderName, GL_COMPILE_STATUS, &status);
    if(status == 0)
    {
#if defined(DEBUG)
		GLint logLength;
		glGetShaderiv(vertexShaderName, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(vertexShaderName, logLength, &logLength, log);
			NSLog(@"Vertex shader compile log:\n%s", log);
			free(log);
		}
#endif

        glDeleteShader(vertexShaderName);
        return NO;
    }
	
    glShaderSource(fragmentShaderName, 1, &fragmentShader, NULL);
    glCompileShader(fragmentShaderName);
    glGetShaderiv(fragmentShaderName, GL_COMPILE_STATUS, &status);
    if(status == 0)
    {
		
#if defined(DEBUG)
		GLint logLength;
		glGetShaderiv(fragmentShaderName, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(fragmentShaderName, logLength, &logLength, log);
			NSLog(@"Fragment shader compile log:\n%s", log);
			free(log);
		}
#endif

        glDeleteShader(vertexShaderName);
        glDeleteShader(fragmentShaderName);
        return NO;
    }
	
	shaderProgram = glCreateProgram();
	glAttachShader(shaderProgram, vertexShaderName);
	glAttachShader(shaderProgram, fragmentShaderName);

    glBindAttribLocation(shaderProgram, kVertexAttributePosition, "position");
    glBindAttribLocation(shaderProgram, kVertexAttributeColor, "color");
	glBindAttribLocation(shaderProgram, kVertexAttributeTexCoords, "texCoords");
	
	glLinkProgram(shaderProgram);
	
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &status);
    if (status == 0)
	{

#if defined(DEBUG)
		GLint logLength;
		glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetProgramInfoLog(shaderProgram, logLength, &logLength, log);
			NSLog(@"Program link log:\n%s", log);
			free(log);
		}
#endif

		glDeleteShader(vertexShaderName);
		glDeleteShader(fragmentShaderName);
		glDeleteProgram(shaderProgram);
        return NO;
	}
	
	projectionMatrixUniform = glGetUniformLocation(shaderProgram, "u_projectionMatrix");
	
	glDeleteShader(vertexShaderName);
	glDeleteShader(fragmentShaderName);

	return YES;
}

- (void)generateGlyphOutlines
{
	CGPoint textOrigin = CGPointMake(-150, 0);
	NSString *string = @"Goodbye";
	UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:68];

	glyphPaths = [[NSMutableArray arrayWithCapacity:[string length]] retain];
	
	CTFontRef ctFont = CTFontCreateWithName((CFStringRef)[font fontName], [font pointSize], NULL);
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								(id)ctFont, kCTFontAttributeName,
								nil];

	NSAttributedString* attribString = [[NSAttributedString alloc] initWithString:string
																	 attributes:attributes];

	CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attribString);
	
	CFArrayRef runArray = CTLineGetGlyphRuns(line);

	for(CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); ++runIndex)
	{
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
		
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); ++runGlyphIndex)
		{
			CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
			
			CGGlyph glyph;
			CTRunGetGlyphs(run, glyphRange, &glyph);

			CGPoint position;
			CTRunGetPositions(run, glyphRange, &position);			
			
			CGPathRef path = CTFontCreatePathForGlyph(runFont, glyph, NULL);
			CGMutablePathRef transformedPath = CGPathCreateMutable();
			CGAffineTransform translation = CGAffineTransformMakeTranslation(position.x + textOrigin.x, position.y + textOrigin.y);
			CGPathAddPath(transformedPath, &translation, path);
			
			[glyphPaths addObject:(id)transformedPath];
			
			CGPathRelease(path);
			CGPathRelease(transformedPath);
		}
	}
	
	CFRelease(line);
	[attribString release];
}

- (CGPoint)spawnPointForNextParticle
{
	NSInteger glyphIndex = (random() / (double)RAND_MAX) * [glyphPaths count];
	
	CGPathRef glyphPath = (CGPathRef)[glyphPaths objectAtIndex:glyphIndex];
	
	if(glyphPath == NULL) return CGPointMake(FLT_MAX, FLT_MAX);
	
	CGRect glyphBoundingBox = CGPathGetPathBoundingBox(glyphPath);
	
	CGPoint testPoint = CGPointMake(FLT_MAX, FLT_MAX);
	
	if(CGRectIsEmpty(glyphBoundingBox)) return CGPointMake(FLT_MAX, FLT_MAX);
	
	while(!CGPathContainsPoint(glyphPath, &CGAffineTransformIdentity, testPoint, false))
	{
		CGFloat x = ((random() / (double)RAND_MAX) * (glyphBoundingBox.size.width + 1)) + glyphBoundingBox.origin.x;
		CGFloat y = ((random() / (double)RAND_MAX) * (glyphBoundingBox.size.height + 1)) + glyphBoundingBox.origin.y;
		testPoint = CGPointMake(x, y);
	}
	
	return testPoint;
}

- (void)drawFrame
{
	if(!eaglLayer) [self createFramebuffer];
	
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	
	[particleSystem advanceSystemByTimeInterval:0.05];
	
	AHVertexData2D *vertexData = malloc(6000 * sizeof(AHVertexData2D));
	
	[particleSystem extractParticleVertexData:vertexData];

	GLfloat left = -bufferWidth / 2.0, right = bufferWidth / 2.0;
	GLfloat top = bufferHeight / 2.0, bottom = -bufferHeight / 2.0;
	GLfloat near = -1, far = 1;
	
	glViewport(0, 0, bufferWidth, bufferHeight);
	
	glClearDepthf(1.0);
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	glEnable(GL_TEXTURE_2D);

	glDisable(GL_DEPTH_TEST);
	
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CW);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
	GLfloat orthoMatrix[] = 
	{
		2/(right - left), 0, 0, - (right + left)/(right - left),
		0, 2/(top - bottom), 0, - (top + bottom)/(top - bottom),
		0, 0, (-2)/(far - near),  - (far + near)/(far - near),
		0, 0, 0, 1
	};

	glUseProgram(shaderProgram);
	
	glUniformMatrix4fv(projectionMatrixUniform, 1, GL_FALSE, orthoMatrix);

	glVertexAttribPointer(kVertexAttributePosition, 2, GL_FLOAT, GL_FALSE, sizeof(AHVertexData2D), &vertexData[0].xy);
	glEnableVertexAttribArray(kVertexAttributePosition);
	
	glVertexAttribPointer(kVertexAttributeColor, 4, GL_FLOAT, GL_FALSE, sizeof(AHVertexData2D), &vertexData[0].rgba);
	glEnableVertexAttribArray(kVertexAttributeColor);
	
	glVertexAttribPointer(kVertexAttributeTexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(AHVertexData2D), &vertexData[0].st);
	glEnableVertexAttribArray(kVertexAttributeTexCoords);
	
	NSUInteger particleCount = [particleSystem liveParticleCount];
	for(int i = 0; i < particleCount * 4; i += 4)
	{
		glDrawArrays(GL_TRIANGLE_STRIP, i, 4);
	}	
	
#if defined(DEBUG)
	GLint logLength;
    
    glValidateProgram(shaderProgram);
    glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(shaderProgram, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
#endif	

	free(vertexData);
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
