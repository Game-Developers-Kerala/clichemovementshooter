shader_type spatial;

uniform vec4 albedo :hint_color = vec4(1.0);
uniform vec4 emission_color :hint_color = vec4(1.0);
uniform sampler2D albedo_tex;
uniform sampler2D RSM_tex;
uniform sampler2D emission_tex;
uniform float emission = 0.0;
uniform float roughness = 1.0;
uniform float specular = 0.0;
uniform float metallic = 0.0;
uniform float occlusion = 0.0;


void fragment(){
	vec3 RSM = texture(RSM_tex,UV).rgb;
	vec4 alb_sampled = texture(albedo_tex,UV);
	ALBEDO = albedo.rgb * alb_sampled.rgb;
	ROUGHNESS = roughness*RSM.r;
	SPECULAR = specular*RSM.g;
	METALLIC = metallic*RSM.b;
	EMISSION = emission * texture(emission_tex,UV).rgb * emission_color.rgb;
	//ALPHA = albedo.a*alb_sampled.a;
}