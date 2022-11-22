extends Node

var anim_player : AnimationPlayer
var anim_idx := 0
var timer :Timer

func _ready():
	var arr = cmn.get_all_children(self)
	for child in arr:
		if child is AnimationPlayer:
			anim_player = child
			print("got anim player:",anim_player.name)
			break
	timer= Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout",self,"_on_anim_finished")
	timer.start(2.0)
	
	
func _on_anim_finished():
	anim_player.play("idle")
	yield(get_tree().create_timer(1.0),"timeout")
	var list = anim_player.get_animation_list()
	anim_player.play(list[anim_idx])
	timer.start(anim_player.get_animation(list[anim_idx]).length)
	anim_idx = (anim_idx+1)%list.size()
