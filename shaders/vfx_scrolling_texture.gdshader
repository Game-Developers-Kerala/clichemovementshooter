shader_type spatial;
render_mode unshaded;
uniform vec2 speed = vec2(1.0,1.0);
uniform sampler2D albedo_tex;
uniform vec4 albedo_color :hint_color = vec4(1.0);

void fragment(){
	ALBEDO = texture(albedo_tex,UV+fract(TIME*speed)).rgb*albedo_color.rgb;
}