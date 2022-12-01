extends projectile

export(bool) var cut_grapple := false

func ready_extend():
	if detect_wall:
		$Area.set_collision_mask_bit(cmn.colliders.level,true)
	if detect_npc:
		$Area.set_collision_mask_bit(cmn.colliders.enemy_hurtbox,true)
	if detect_player:
		$Area.set_collision_mask_bit(cmn.colliders.player,true)
	if detect_custom:
		if shot_by_player:
			$Area.set_collision_mask_bit(cmn.colliders.player_custom,true)
		else:
			$Area.set_collision_mask_bit(cmn.colliders.enemy_custom,true)
	if cut_grapple:
		$Area.monitorable = true
		$Area.set_collision_layer_bit(cmn.colliders.grapple_breaker,true)

func terminate(recepient:Node=null):
	if direct_hit and is_instance_valid(recepient):
		get_node(direct_hit).hit(recepient)
	if explosion:
		explode()
	if explosion_vfx:
		explode_vfx()
	if trail:
		stop_trail()
	queue_free()
func _on_Timer_timeout():
	terminate()

func _on_Area_area_entered(area):
	$Area.disconnect("area_entered",self,"_on_Area_area_entered")
	var recepient:Node=null
	if area.get_collision_layer_bit(cmn.colliders.enemy_hurtbox):
		recepient = area.hit_receiver
	terminate(recepient)

func _on_Area_body_entered(body):
	$Area.disconnect("body_entered",self,"_on_Area_body_entered")
	var recepient:Node=null
	if body.get_collision_layer_bit(cmn.colliders.player):
		recepient = body
	terminate(recepient)
