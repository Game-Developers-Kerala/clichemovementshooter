extends Node


signal wave_start
signal announcement
signal enemy_count_changed

var time:=0.0
var frame := 0
var curr_wave := 0
#var wave_active :bool = false

const WAVE_NEXT_WAIT_TIME = 7
const ANNOUCE_WAIT_TIME = 2
var countdownping = 5

func _process(delta):
	time += delta
	frame += 1

func _ready():
	emit_signal("announcement","")
	yield(get_tree().create_timer(0.25),"timeout")
	emit_signal("announcement","Warmup time: Press Enter to start waves",0.0)
	
func _input(event):
	if event.is_action_pressed("enter"):
		set_process_input(false)
		next_wave()

func _on_warmup_over():
	next_wave()

func next_wave():
	#announce that next wave is coming
	if curr_wave:
		emit_signal("announcement","Wave "+str(curr_wave) + " defeated", 0.0)
		pass
	else:
		emit_signal("announcement","Get ready")
	
	curr_wave +=1
	
	#before countdown there is a pause for announcement to end
	yield(get_tree().create_timer(ANNOUCE_WAIT_TIME),"timeout")

	#starting countdown pings
	countdownping = WAVE_NEXT_WAIT_TIME - ANNOUCE_WAIT_TIME
	while countdownping:
		var announcement = "Wave "+str(curr_wave)+" starting in "+str(countdownping)
		emit_signal("announcement",announcement)
		countdownping -=1
		yield(get_tree().create_timer(1.0),"timeout") #countdown wait
	
#	emit_signal("announcement","")
	emit_signal("wave_start",curr_wave)

func _on_enemy_count_changed(in_count:int):
	emit_signal("enemy_count_changed",in_count)
	if !in_count:
		next_wave()

func _on_player_death():
	emit_signal("announcement","You died")
	yield(get_tree().create_timer(ANNOUCE_WAIT_TIME),"timeout")
	get_tree().reload_current_scene()
