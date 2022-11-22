extends Spatial

onready var mat = $MeshInstance.get_active_material(0)
var time := 0.0
var opacity_fac := 1.0

func init(from:Vector3,to:Vector3):
	look_at_from_position(from,to,Vector3.UP)
	var length = (to-from).length()
	scale.z = length
	print("railvfx length:",length)



func _process(delta):
	time += delta
	if time < 0.1:
		return
	opacity_fac = max(0,opacity_fac-delta*2)
	mat.set_shader_param("opacity",opacity_fac)
	if !opacity_fac:
		queue_free()
