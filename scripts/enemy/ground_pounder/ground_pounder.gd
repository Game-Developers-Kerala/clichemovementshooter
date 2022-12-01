#ground pounder enemy
extends BaseEnemy

enum states{
	CHASE,
	CIR_ATTACK,
	STR_ATTACK,
	MELEE,
	DEATH
}

const CENTER_OF_MASS = Vector3(0,3,0)

var anim_done = false setget set_anim_done,is_anim_done
onready var anim : AnimationPlayer = model.get_node('AnimationPlayer')
var meele_speed = 200
var shockwave = preload("res://scenes/enemy/ground_pounder/circular_wave.tscn")
var straight_wave = preload("res://scenes/enemy/ground_pounder/straight_wave.tscn")
var single_hit = preload("res://scenes/shared/single_direct_hit.tscn")

onready var attack_area : Area = $AttackArea


func _ready() -> void:
	anim.connect("animation_finished",self,"on_anim_finished")
	player = get_tree().current_scene.get_node('Player')
	set_state(states.CHASE)
	
func _process(delta: float) -> void:
	
	if get_health() < 0:
		set_state(states.DEATH)
	
	nav_agent.set_target_location(player.global_transform.origin)
	_aim_at_player()
	
	match get_state():
		
		states.CHASE:
			
			if weapon.get_collider() == player:
				if $StraightWaveCooldown.is_stopped():
					set_state(states.STR_ATTACK)
		
		states.STR_ATTACK :
			
			if weapon.get_collider() != player :
				set_state(states.CHASE)
		
		states.DEATH:
			weapon.enabled = false
			
			
func _physics_process(delta: float) -> void:
	
#STATE MANAGMENT

	match get_state():
		
		states.CHASE:
			
			velocity = _calc_velocity(chase_speed) * delta
			move_and_slide(velocity,Vector3.UP)
		
		states.STR_ATTACK:
			
			#straight wave
			if weapon.get_collider() == player and player.grappling != true:
				if $StraightWaveCooldown.is_stopped():
					if is_anim_done():
						_straight_wave()
						set_anim_done(false)
				else:
					set_state(states.CHASE)
					
		states.CIR_ATTACK:
			
			if weapon.get_collider() == player and player.grappling != true:
				if $circlewaveCooldown.is_stopped():
					if is_anim_done():
						_circular_wave()
						set_anim_done(false)
				else:
					set_state(states.CHASE)
				
		states.DEATH:
			pass

#SIGNALS
func _on_AttackArea_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.CIR_ATTACK)

func _on_AttackArea_body_exited(body: Node) -> void:
	
	if body.is_in_group("player"):
		set_state(states.CHASE)


func _straight_wave():
	
	var inst = straight_wave.instance()
	get_tree().current_scene.add_child(inst)
	inst.look_at_from_position(global_translation,player.global_translation,Vector3.UP)
	set_anim_done(false)
	$StraightWaveCooldown.start()

func _circular_wave():
	
	var inst = shockwave.instance()
	get_tree().current_scene.add_child(inst)
	inst.translate(global_translation)
	inst.force_update_transform()
	set_anim_done(false)
	$circlewaveCooldown.start()


func enter():
	
	match get_state():
		
		states.CHASE:
			pass
		states.MELEE:
			if is_anim_done() == false:
				anim.play("melee_l")
		states.CIR_ATTACK:
			if is_anim_done() == false:
				anim.play("circle_pound")
		states.STR_ATTACK:
			if is_anim_done() == false:
				anim.play("straight_pound")
		states.DEATH:
			if is_anim_done() == false:
				if !$Death.is_stopped():
					$Death.start()
					anim.play("death")


func _on_MeeleAttack_body_entered(body: Node) -> void:
	
	if body.is_in_group('player'):
		
		set_state(states.MELEE)
		if $MeleeCooldown.is_stopped() && is_anim_done():
			var inst = single_hit.instance()
			get_tree().current_scene.add_child(inst)
			inst.hit(body)
			inst.queue_free()
			$MeleeCooldown.start()


func _on_MeeleAttack_body_exited(body: Node) -> void:
	
	if body.is_in_group('player'):
		set_state(states.CHASE)


func is_anim_done()->bool:
	return anim_done
	

func set_anim_done(flag : bool)->void:
	anim_done = flag

func on_anim_finished(name : String):
	print("Animation finished" + name)
	set_anim_done(true)


func _on_Death_timeout() -> void:
	queue_free()


func _on_GroundPounder_npc_hurt() -> void:
	
		if is_anim_done() == false:
			anim.play("hit")
