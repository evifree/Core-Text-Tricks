//
//  Shader.vsh
//  OpenGLESTest
//
//	This program is free software. It comes without any warranty, to
//	the extent permitted by applicable law. You can redistribute it
//	and/or modify it under the terms of the Do What The Fuck You Want
//	To Public License, Version 2, as published by Sam Hocevar. See
//	http://sam.zoy.org/wtfpl/COPYING for more details.
//

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoords;

uniform mat4 u_projectionMatrix;

varying vec4 v_color;
varying vec2 v_texCoords;

void main()
{
	gl_Position = u_projectionMatrix * position;

    v_color = color;
	
	v_texCoords = texCoords;
}
