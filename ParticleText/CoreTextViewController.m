//
//  CoreTextViewController.m
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

#import "CoreTextViewController.h"
#import "CoreTextView.h"

@implementation CoreTextViewController
@synthesize fontSizeSegmentedControl;
@synthesize textAlignmentSegmentedControl;
@synthesize columnCountSegmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [fontSizeSegmentedControl release];
    [textAlignmentSegmentedControl release];
    [columnCountSegmentedControl release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setFontSizeSegmentedControl:nil];
    [self setTextAlignmentSegmentedControl:nil];
    [self setColumnCountSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)fontSizeDidChange:(UISegmentedControl *)sender {
	CoreTextView *textView = (CoreTextView *)[self view];
	NSInteger fontSize = [[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] intValue];
	[textView setFontSize:fontSize];
	[textView setNeedsDisplay];
}

- (IBAction)textAlignmentDidChange:(UISegmentedControl *)sender {
	CoreTextView *textView = (CoreTextView *)[self view];
	switch([sender selectedSegmentIndex])
	{
		case 0:
			[textView setTextAlignment:kCTLeftTextAlignment]; break;
		case 1:
			[textView setTextAlignment:kCTJustifiedTextAlignment]; break;
		case 2:
			[textView setTextAlignment:kCTRightTextAlignment]; break;
	}
	[textView setNeedsDisplay];
}

- (IBAction)columnCountDidChange:(UISegmentedControl *)sender {
	CoreTextView *textView = (CoreTextView *)[self view];
	NSInteger fontSize = [[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] intValue];
	[textView setColumnCount:fontSize];
	[textView setNeedsDisplay];
}

@end
