extends Area

var valid :=true


func _on_player_respawn_point_body_entered(body):
	valid = false


func _on_player_respawn_point_body_exited(body):
	if !get_overlapping_bodies():
		valid = true
