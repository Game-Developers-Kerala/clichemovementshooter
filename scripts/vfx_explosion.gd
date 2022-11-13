extends MeshInstance

onready var mat = get_active_material(0)

var exp_fac = 0.0
export(float) var SIZE_START = 0.5
export(float) var SIZE_DIFF = 2.0
export(float) var EXPLOSION_SPEED = 10

func _ready():
	pass

func _process(delta):
	exp_fac = lerp(exp_fac,1,delta*EXPLOSION_SPEED)
	mat.set_shader_param("opacity",1-exp_fac)
	var exp_size = SIZE_START+exp_fac*SIZE_DIFF
	scale = Vector3.ONE*exp_size
	if exp_fac > 0.98:
		queue_free()
