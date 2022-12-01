extends Label

func _ready():
	game.connect("announcement",self,"show_text")
	set_process(false)
	hide()

func show_text(in_text:String="",in_duration:float=1.0):
	if !in_text:
		$Timer.stop()
		set_process(false)
		hide()
		return
	text = in_text
	modulate.a = 1.0
	set_process(false)
	show()
	if !in_duration:
		return
	$Timer.start(in_duration)

func _process(delta):
	modulate.a = max(modulate.a-delta,0.0)
	if !modulate.a:
		set_process(false)
		hide()


func _on_Timer_timeout():
	set_process(true)
