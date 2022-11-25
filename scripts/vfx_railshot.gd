extends Spatial

onready var mat = $MeshInstance.get_active_material(0)
var time := 0.0
const HOLD_TIME = 0.1
const TOTAL_TIME = 0.85
var opacity_fac := 1.0
const UV_START := 0.063
const UV_END := 0.121
var uv_shift := UV_START
var uv_shift_fac :float

func init(from:Vector3,to:Vector3):
	look_at_from_position(from,to,Vector3.UP)
	var length = (to-from).length()
	scale.z = length
	print("railvfx length:",length)
	uv_shift_fac = (UV_END-UV_START)/float(TOTAL_TIME-HOLD_TIME)

func _process(delta):
	time += delta
	if time < 0.1:
		return
#	opacity_fac = max(0,opacity_fac-delta*2)
#	mat.set_shader_param("opacity",opacity_fac)
	uv_shift += uv_shift_fac*delta
	mat.set_shader_param("uv_offset",Vector2(0.0,uv_shift))
	if time >= TOTAL_TIME:
		queue_free()
