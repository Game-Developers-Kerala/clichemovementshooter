extends MeshInstance

onready var mat = get_active_material(0)

var exp_fac = 0.0
export(float) var size_start = 0.5
export(float) var size_diff = 2.0
export(float) var explosion_speed = 10
export(bool) var explode_on_ready = false # if on, will go off immediately on spawn.

func _ready():
	if !explode_on_ready:
		hide()
		set_process(false)

func _process(delta):
	exp_fac = lerp(exp_fac,1,delta*explosion_speed)
	mat.set_shader_param("opacity",1-exp_fac)
	var exp_size = size_start+exp_fac*size_diff
	scale = Vector3.ONE*exp_size
	if exp_fac > 0.98:
		queue_free()

func explode():
	show()
	set_process(true)
