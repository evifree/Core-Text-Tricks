//
//  Shader.fsh
//  OpenGLESTest
//
//	This program is free software. It comes without any warranty, to
//	the extent permitted by applicable law. You can redistribute it
//	and/or modify it under the terms of the Do What The Fuck You Want
//	To Public License, Version 2, as published by Sam Hocevar. See
//	http://sam.zoy.org/wtfpl/COPYING for more details.
//

varying mediump vec4 v_color;
varying mediump vec2 v_texCoords;

uniform sampler2D u_texture;

void main()
{
	gl_FragColor = vec4(v_color.rgb, texture2D(u_texture, v_texCoords).a);
}
