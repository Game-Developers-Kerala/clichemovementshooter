#enemy controller script
#Arch shooter
extends BaseEnemy

enum states{

	CHASE,
	BOW_AIM,
	BOW_RELEASE,
	ATTACK,
	DAMAGE,
	DEATH

}

var dist

export(float) var max_shoot_range = 25
export(float) var max_aim_range = 50

onready var label = $BodyRotationHelper/Label3D as Label3D
onready var ARC = preload("res://scenes/enemy/arc_shooter/arc.tscn")
onready var cut_grapple = preload("res://scenes/enemy/arc_shooter/grapple_cut_projectile.tscn") 

func _ready() -> void:
	
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)


func _process(delta: float) -> void:
	
	nav_agent.set_target_location(player.global_transform.origin)
	if weapon.get_collider() == player:
		dist = (weapon.get_collision_point() - global_translation).length()
	
	match get_state():
		
		states.CHASE :
			
			if weapon.get_collider() == player:
				set_state(states.BOW_AIM)
		
		states.BOW_AIM:
			
			if dist < max_shoot_range:
				set_state(states.BOW_RELEASE)
			else:
				set_state(states.CHASE)
		
		states.BOW_RELEASE:
			
			if weapon.get_collider() != player:
				set_state(states.CHASE)
				
		states.DEATH:
			pass
				
func _physics_process(delta: float) -> void:
	
	_aim_at_player()
	
	match get_state():
		
		states.CHASE:
			
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
		
		states.BOW_AIM:
			pass
		
		states.BOW_RELEASE:
			
			if $ShootCooldown.is_stopped():
				if player.grappling:
					_predicted_shoot()
				else:
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
		states.DEATH:
			pass
			

#signals
func _shoot():
	
		var inst = ARC.instance()
		get_tree().current_scene.add_child(inst)
		inst.look_at_from_position(global_translation,player.global_translation,Vector3.UP)
		$ShootCooldown.start()
		set_state(states.BOW_AIM)


func _predicted_shoot():
	
	var inst = cut_grapple.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(global_translation,_predict_player_movement(),Vector3.UP)
	$ShootCooldown.start()
	set_state(states.BOW_AIM)


#return a value from already predicted player pos
func _predict_player_movement() -> Vector3:
	return player.predict_future_pos[8]


func _on_ShootTimer_timeout() -> void:
	print("times up")
	set_state(states.BOW_RELEASE)
