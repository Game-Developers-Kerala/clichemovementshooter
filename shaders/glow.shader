shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D gradient;
uniform float opacity = 1.0;
uniform vec4 color1 :hint_color = vec4(1.0,0.0,0.0,1.0);
uniform vec4 color2 :hint_color = vec4(0.0,1.0,0.0,1.0);
uniform vec4 color3 :hint_color = vec4(0.0,0.0,1.0,1.0);
uniform float anim_size = 0.1;
uniform float anim_speed = 3.0;

void vertex(){
	VERTEX = (vec4(VERTEX,0.0)*MODELVIEW_MATRIX).xyz;
	VERTEX *= 1.0+sin(TIME*anim_speed)*anim_size;
}

void fragment(){
	vec3 grad = texture(gradient,UV).rgb;
	ALBEDO = (color1+color2*grad.g+color3*grad.b).rgb;
	float alpha_calc = max(color1.a*grad.r*grad.r,max(color2.a*grad.g*grad.g,color3.a*grad.b*grad.b));
	ALPHA = alpha_calc*opacity;
	
}