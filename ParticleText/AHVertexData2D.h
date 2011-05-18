//
//  AHVertexData2D.h
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

#ifndef AH_VERTEX_DATA_2D_H_
#define AH_VERTEX_DATA_2D_H_

/*
	The purpose of this struct is to provide a uniform, interleaved format 
	for sending vertex data to OpenGL|ES. It assumes vertices are in 2D, and 
	that each vertex has a unique pair of texture coordinates and an RGBA color.
*/

typedef struct
{
	CGFloat xy[2];
	CGFloat st[2];
	CGFloat rgba[4];
} AHVertexData2D;

#endif // inclusion guard