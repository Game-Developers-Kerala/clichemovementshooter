extends Area

export(bool) var hurt_npc = true
export(bool) var hurt_player = false
export(bool) var push_npc = true
export(bool) var push_player = true

export(float) var blast_radius = 2.0
export(float) var max_damage = 100.0
export(float) var min_damage = 20.0
onready var dmg_diff = max_damage - min_damage
export(float) var push_force = 30.0
export(float) var blast_duration = 0.2


var receivers := []

func _ready():
	if hurt_npc or push_npc:
		set_collision_mask_bit(cmn.colliders.enemy_hurtbox,true)
	if hurt_player or push_player:
		set_collision_mask_bit(cmn.colliders.player,true)
	translate(Vector3.ZERO)
	force_update_transform()
	scale = Vector3.ONE*blast_radius
	$Timer.start(blast_duration)


func _on_Timer_timeout():
	queue_free()


func _on_Explosion_area_entered(area):
	if area.get_collision_layer_bit(cmn.colliders.enemy_hurtbox):
		for node in receivers:
			if area.hit_receiver == node:
				return
		receivers.push_front(area.hit_receiver)
		var force_vec :Vector3 = area.hit_receiver.global_translation+Vector3.UP-global_translation
		var dist = force_vec.length()
		if hurt_npc:
			var dmg = min_damage + (dmg_diff*(1.0-clamp(dist/float(blast_radius),0,1)))
			print("enemy hurt by explosion:",dmg)
		if push_npc:
			var push_dict = {push_dir = force_vec.normalized(), force = 30.0}
			print("enemy pushed by explosion:")

func _on_Explosion_body_entered(body):
	if body.get_collision_layer_bit(cmn.colliders.player):
		if push_player:
			var push_dict = {origin = global_translation, force = push_force}
			body.get_pushed(push_dict)
			print("player pushed by explosion:",OS.get_ticks_msec())
		if hurt_player:
			print("player hurt by explosion")
