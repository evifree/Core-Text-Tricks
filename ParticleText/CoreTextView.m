//
//  CoreTextView.m
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

#import "CoreTextView.h"

@implementation CoreTextView
@synthesize text;
@synthesize columnCount;
@synthesize fontSize;
@synthesize textAlignment;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		columnCount = 2;
		fontSize = 16;
		textAlignment = kCTJustifiedTextAlignment;
		
		text = [[NSString alloc] initWithString:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis euismod vehicula eros, quis malesuada massa fringilla quis. Nullam sit amet massa vitae augue venenatis rhoncus vitae nec est. Integer cursus dolor ut lectus scelerisque hendrerit. Donec semper facilisis varius. Sed libero quam, congue vel aliquet id, fringilla vestibulum ipsum. Maecenas mauris tortor, vehicula at euismod vel, ullamcorper in est. Proin laoreet nisl nec metus egestas pulvinar. Suspendisse potenti. Integer cursus odio sed sapien ultricies quis congue elit pellentesque. Morbi eleifend, nisl ut tincidunt vestibulum, lorem libero pharetra eros, in molestie risus enim ac nibh. Donec lacus orci, lobortis vel pulvinar."];
    }
    return self;
}

- (void)layoutSubviews {
	[self setNeedsDisplay];
}

- (void)drawText:(CGContextRef)context {
	CTFontRef font = CTFontCreateWithName((CFStringRef)@"Georgia", fontSize, NULL);
	NSDictionary *attribs = [NSDictionary dictionaryWithObjectsAndKeys:(id)font, kCTFontAttributeName, nil];
	NSMutableAttributedString *attribString = [[NSMutableAttributedString alloc] initWithString:text attributes:attribs];
	CFRelease(font);

	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CTParagraphStyleSetting settings[] = { { kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment } };
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));

	CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attribString, 
								   CFRangeMake(0, [text length]), 
								   kCTParagraphStyleAttributeName, 
								   paragraphStyle);
	CFRelease(paragraphStyle);

	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attribString);

	CFIndex textRangeStart = 0;
	for(size_t i = 0; i < columnCount; ++i)
	{
		CGFloat columnWidth = self.bounds.size.width / columnCount;
		
		CGRect columnFrame = CGRectMake(i * columnWidth, 0, columnWidth, self.bounds.size.height);
		columnFrame = UIEdgeInsetsInsetRect(columnFrame, UIEdgeInsetsMake(50, 10, 10, 10));
		
		CGMutablePathRef framePath = CGPathCreateMutable();
		CGPathAddRect(framePath, &CGAffineTransformIdentity, columnFrame);
		
		CFRange textRange = CFRangeMake(textRangeStart, 0);
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, framePath, NULL);
		
		CTFrameDraw(frame, context);
		
		CFRange visibleRange = CTFrameGetVisibleStringRange(frame);
		textRangeStart += visibleRange.length;
		
		CFRelease(frame);		
		CFRelease(framePath);
		
		if(textRangeStart >= [text length]) 
			break;
	}
	
	[attribString release];
	CFRelease(framesetter);
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	[self drawText:context];
}

- (void)dealloc
{
	[text release];

    [super dealloc];
}

@end
