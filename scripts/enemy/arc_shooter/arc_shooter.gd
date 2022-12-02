#enemy controller script
#Arch shooter
extends BaseEnemy

enum states{

	CHASE,
	BOW_AIM,
	BOW_RELEASE,
	DAMAGE,
	DEATH

}

const CENTER_OF_MASS = Vector3(0,1,0)

onready var ARC = preload("res://scenes/enemy/arc_shooter/ArcImporved.tscn")
onready var cut_grapple = preload("res://scenes/enemy/arc_shooter/grapple_cut_projectile.tscn") 

func _ready() -> void:
	
	player = get_tree().get_nodes_in_group("player")[0]
	set_state(states.CHASE)


func _process(delta: float) -> void:
	
	_aim_at_player()
	
	
	nav_agent.set_target_location(player.global_translation)
	model.vertical_look_at(player.global_translation)
	
	match get_state():
		
		states.CHASE :
			
			if weapon.get_collider() == player:
				set_state(states.BOW_AIM)
		
		states.BOW_AIM:
			
			if weapon.get_collider() == player:
				if $BowDrawTimeout.is_stopped():
					$BowDrawTimeout.start()
		
		states.BOW_RELEASE:
			
			if weapon.get_collider() != player:
				set_state(states.CHASE)

		states.DEATH:
			
			weapon.enabled = false
				
func _physics_process(delta: float) -> void:
	
	match get_state():
		
		states.CHASE:
			
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
		
		states.BOW_AIM:
			pass
		
		states.BOW_RELEASE:
			
			if weapon.get_collider() == player:
				if $ShootCooldown.is_stopped():
						_shoot()
		states.DEATH:
			pass


func enter():
	
	match get_state():
		
		states.CHASE:
			print("anim played" + str(get_state()))
			model.get_node("AnimationPlayer").play("run")
		states.BOW_AIM:
			print("anim played" + str(get_state()))
			model.get_node("AnimationPlayer").play("shoot1_draw")
		states.BOW_RELEASE:
			print("anim played" + str(get_state()))
			model.get_node("AnimationPlayer").play("shoot1_release")
		states.DAMAGE:
			print("anim played" + str(get_state()))
			model.get_node("AnimationPlayer").play("hit")
			
		states.DEATH:
			print("anim played" + str(get_state()))
			$Death.start()
			game.emit_signal("enemy_killed")
			model.get_node("AnimationPlayer").play("dead")

#signals
func _shoot():
	
		print("shoots")
		var inst = ARC.instance()
		get_tree().current_scene.add_child(inst)
		inst.look_at_from_position(global_translation+CENTER_OF_MASS,player.global_translation+player.CENTER_OF_MASS,Vector3.UP)
		$ShootCooldown.start()
		set_state(states.BOW_AIM)


func _predicted_shoot():
	
	var inst = cut_grapple.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(global_translation+CENTER_OF_MASS,_predict_player_movement(),Vector3.UP)
	$ShootCooldown.start()
	set_state(states.BOW_AIM)


#return a value from already predicted player pos
func _predict_player_movement() -> Vector3:
	return player.predict_future_pos[3]


func _on_ShootTimer_timeout() -> void:
	print("times up")
	set_state(states.BOW_RELEASE)


func _on_BowDrawTimeout_timeout() -> void:
	set_state(states.BOW_RELEASE)


func _on_Death_timeout() -> void:
	queue_free()


func _on_ArcShooter_npc_hurt() -> void:
	if get_state() == states.DEATH:
		return
	if get_health() <= 0:
		set_state(states.DEATH)
		return
	if get_health() > 0:
		model.get_node("AnimationPlayer").play("hit")
	print("NPC hurt")
