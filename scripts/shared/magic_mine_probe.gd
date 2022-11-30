extends Spatial

const MINE = preload("res://scenes/shared/magic_mine.tscn")

var predict_arr
var predict_check_idx := 8
onready var player :Spatial= get_tree().get_nodes_in_group("player")[0]


func _ready():
	predict_arr = player.predict_future_pos

func _process(delta):
	var predicted_pos = predict_arr[predict_check_idx]
	var player_pos = player.global_translation + player.CENTER_OF_MASS
	$check_player_ray.look_at_from_position(predicted_pos+Vector3(0.1,0,0.1),player_pos,Vector3.UP)
	$check_player_ray.force_raycast_update()
	if $check_player_ray.is_colliding():
		if $check_player_ray.get_collider() == player:
			deploy_mines(predicted_pos)
			set_process(false)
	predict_check_idx -=1
	if !predict_check_idx:
#		print("not suitable prediction found")
		deploy_mines(player.global_translation)
		set_process(false)
	
func deploy_mines(position:Vector3):
	global_translation = position+Vector3.UP
	yield(get_tree(),"idle_frame")
	for ray in $mine_rays.get_children():
		if ray.is_colliding():
			var pos = ray.get_collision_point()
			var norm = ray.get_collision_normal()
			var mine = MINE.instance()
			mine.init(pos,norm)
			get_tree().current_scene.add_child(mine)
	queue_free()
