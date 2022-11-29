shader_type spatial;
render_mode unshaded,depth_draw_always,cull_back;

uniform sampler2D albedo_tex;
uniform vec4 albedo_color :hint_color = vec4(1.0);
uniform float opacity = 1.0;
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);


void vertex(){
	UV = UV*uv_scale +uv_offset;
}

void fragment(){
	vec4 alb_sampled = texture(albedo_tex,UV);
	ALBEDO = alb_sampled.rgb * albedo_color.rgb;
	ALPHA = alb_sampled.a * albedo_color.a * opacity;
}