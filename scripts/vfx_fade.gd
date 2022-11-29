extends MeshInstance

export(float) var opacity = 1.0 # the maximum opacity of the effect.

export(bool) var single_use = true # will delete the instance after it fades out.
export(bool) var show_on_ready :=true # will appear on instanitation, if false use show_fx() when needed.
export(bool) var fade_on_fx_start = true # will start the fade as soon as it appears, if false use fade_fx() to fade.
export(float) var hold_time := 0.1 # if fade on fx start is true, how long will it stay before starting the fade.
export(float) var fade_time := 0.5 # time from fading start till completely faded out.

var fade_rate :float
var curr_opacity :float= 1.0
onready var mat = get_active_material(0)

func _ready():
	fade_rate = 1.0/float(fade_time)
	if !show_on_ready:
		hide_fx()
		return
	show_fx()
	

func fade_fx():
	set_process(true)

func show_fx():
	curr_opacity = opacity
	mat.set_shader_param("opacity",curr_opacity)
	show()
	if !fade_on_fx_start:
		return
	if hold_time:
		yield(get_tree().create_timer(hold_time),"timeout")
	fade_fx()

func hide_fx():
	set_process(false)
	hide()

func _process(delta):
	curr_opacity = max(curr_opacity-fade_rate*delta,0.0)
	mat.set_shader_param("opacity",curr_opacity)
	if !curr_opacity:
		if single_use:
			queue_free()
			return
		hide_fx()
