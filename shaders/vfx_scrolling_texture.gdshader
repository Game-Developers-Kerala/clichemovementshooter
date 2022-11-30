shader_type spatial;
render_mode unshaded;
uniform vec2 speed = vec2(1.0,1.0);
uniform sampler2D albedo_tex;
uniform vec4 albedo_color :hint_color = vec4(1.0);
uniform float opacity = 1.0;

void fragment(){
	vec4 tex_sampled = texture(albedo_tex,UV+fract(TIME*speed));
	ALBEDO = tex_sampled.rgb*albedo_color.rgb;
	ALPHA = tex_sampled.a*albedo_color.a*opacity;
}