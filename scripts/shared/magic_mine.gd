extends Spatial

export(float) var wait_time = 3.0

export(NodePath) var explosion
export(NodePath) var vfx_explosion
export(NodePath) var vfx_warning

var spawn_pos:Vector3
var spawn_norm:Vector3

func init(position:Vector3,surface_normal:=Vector3.UP): # orient ot normat
	spawn_pos = position
	spawn_norm = surface_normal

func _ready():
	global_translation = spawn_pos
	if abs(spawn_norm.dot(Vector3.UP)) > 0.98:
		rotation.x = PI*0.5
	else:
		look_at(spawn_pos+spawn_norm,Vector3.UP)
	$Timer.start(wait_time)

func _on_Timer_timeout():
	if vfx_warning:
		get_node(vfx_warning).queue_free()
	if explosion:
		get_node(explosion).explode()
	if vfx_explosion:
		get_node(vfx_explosion).explode()
