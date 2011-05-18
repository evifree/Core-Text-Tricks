//
//  AHColorUtilities.c
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

#include "AHColorUtilities.h"
#include <math.h>

void HSVFromRGB(float r, float g, float b, float *h, float *s, float *v)
{
	float M = fmax(r, fmax(g, b));
	float m = fmin(r, fmin(g, b));
	float Ch = M - m;
	
	*v = M; // value ("brightness")
	
	float Hp = 0;
	if(Ch != 0.0)
	{
		if(M == r)
		{
			Hp = (g - b) / Ch; // Between red and green
		}
		else if(M == g)
		{
			Hp = ((b - r) / Ch) + 2; // Between green and blue
		}
		else if(M == b)
		{
			Hp  = ((r - g) / Ch) + 4; // Between blue and red
		}
	}
	
	if(Hp < 0.0) Hp += 6;
	
	*h = Hp * (1 / 6.0); // hue (in turns)
	
	if(*v == 0.0)
	{
		*s = 0.0;
	}
	else
	{
		*s = (Ch / *v); // saturation
	}
}

void RGBFromHSV(float h, float s, float v, float *r, float *g, float *b)
{
	// Chroma represents the relative intensity of the strongest color component
	float Ch = v * s;
	// floor(H') determines the sector of the hexcone this color resides in
	float Hp = h * 6.0;
	// X represents the relative intensity of the second most intense color component
	float X = Ch * (1 - fabs(fmod(Hp, 2.0) - 1));
	
	// Use hue calculation to project into the correct sector of the chromaticity hex
	float Rp = 0.0, Gp = 0.0, Bp = 0.0;
	if(Hp >= 0.0 && Hp < 1.0)
	{
		Rp = Ch; Gp = X; Bp = 0.0; // Between red and yellow
	}
	else if(Hp >= 1.0 && Hp < 2.0)
	{
		Rp = X; Gp = Ch; Bp = 0.0; // Between yellow and green
	}
	else if(Hp >= 2.0 && Hp < 3.0)
	{
		Rp = 0.0; Gp = Ch; Bp = X; // Between green and cyan
	}
	else if(Hp >= 3.0 && Hp < 4.0)
	{
		Rp = 0.0; Gp = X; Bp = Ch; // Between cyan and blue
	}
	else if(Hp >= 4.0 && Hp < 5.0)
	{
		Rp = X; Gp = 0.0; Bp = Ch; // Between blue and magenta
	}
	else if(Hp >= 5.0 && Hp < 6.0)
	{
		Rp = Ch; Gp = 0.0; Bp = X; // Between magenta and red
	}

	// Add adjustment term to normalize brightness
	float m = v - Ch;
	*r = Rp + m;
	*g = Gp + m;
	*b = Bp + m;
}

void InterpolateHSVA(float p,
					 float h1, float s1, float v1, float a1, 
					 float h2, float s2, float v2, float a2, 
					 float *h, float *s, float *v, float *a)
{
	// Compute the angular difference in turns by going clockwise and counter-clockwise
	float dCCW = (h1 > h2) ? (h1 - h2) : ((1.0 + h1) - h2);
	float dCW  = (h1 > h2) ? ((1.0 + h2) - h1) : (h2 - h1);
	
	// Interpolate the hue by taking the shortest path around the hue circle
	*h = (dCW <= dCCW) ? (h1 + (dCW * p)) : (h1 - (dCCW * p));
	
	// Compute the modulo of the hue in both directions to bring it back into range
	if (*h < 0.0) 
		*h += 1.0;	
	if (*h > 1.0)
		*h -= 1.0;
	
	// Interpolate saturation, brightness, and alpha in the usual way
	*s = ((1 - p) * s1) + (p * s2);
	*v = ((1 - p) * v1) + (p * v2);
	*a = ((1 - p) * a1) + (p * a2);
}

