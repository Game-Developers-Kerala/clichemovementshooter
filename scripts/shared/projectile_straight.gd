extends projectile

func ready_extend():
	$RayCast.enabled = true
	if detect_wall:
		$RayCast.set_collision_mask_bit(cmn.colliders.level,true)
	if detect_npc:
		$RayCast.set_collision_mask_bit(cmn.colliders.enemy_hurtbox,true)
	if detect_player:
		$RayCast.set_collision_mask_bit(cmn.colliders.player,true)
	pass

func phys_process_extend(delta):
	translate_object_local(Vector3.FORWARD*speed*delta) #move forwad
	if $RayCast.is_colliding(): #check if rocket is hiting something
		if direct_hit:
			if $RayCast.get_collider().get_collision_layer_bit(cmn.colliders.enemy_hurtbox):
				get_node(direct_hit).hit($RayCast.get_collider().hit_receiver)
			if $RayCast.get_collider().get_collision_layer_bit(cmn.colliders.player):
				get_node(direct_hit).hit($RayCast.get_collider())
		if explosion:
			explode(explosion)
		if explosion_vfx:
			explode(explosion_vfx)
		if trail:
			stop_trail()
		queue_free()

func _on_Timer_timeout():
	print("straight projectile timedout")
	queue_free()
