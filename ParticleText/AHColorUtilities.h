//
//  AHColorUtilities.h
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

#ifndef AH_COLOR_UTILITIES_H_
#define AH_COLOR_UTILITIES_H_

// The conversion functions below are implementations of the formulas described
// here: http://en.wikipedia.org/wiki/HSL_and_HSV

// Converts an RGB color to HSV. All components are on [0,1].
void HSVFromRGB(float r, float g, float b, float *h, float *s, float *v);

// Converts an HSV color to RGB. All components are on [0,1].
void RGBFromHSV(float h, float s, float v, float *r, float *g, float *b);

// Interpolates between two HSVA colors by the specified interpolant.  
// All components are on [0,1].
void InterpolateHSVA(float p,
					 float h1, float s1, float v1, float a1, 
					 float h2, float s2, float v2, float a2, 
					 float *h, float *s, float *v, float *a);

#endif // inclusion guard