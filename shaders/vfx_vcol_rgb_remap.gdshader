shader_type spatial;
render_mode unshaded,depth_draw_always;
uniform vec4 color_r :hint_color = vec4(1.0,0.0,0.0,0.4);
uniform vec4 color_g :hint_color = vec4(0.0,1.0,0.0,0.8);
uniform vec4 color_b :hint_color = vec4(0.0,0.0,1.0,1.0);
uniform float opacity = 1.0;

void vertex(){
	vec4 temp_col = mix(color_r,color_g,COLOR.g);
	temp_col = mix(temp_col,color_b,COLOR.b);
	COLOR = temp_col;
}

void fragment(){
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a*opacity;
}