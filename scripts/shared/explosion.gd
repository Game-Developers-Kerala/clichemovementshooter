extends Area

export(bool) var caused_by_player = false
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
export(bool) var explode_on_ready = false # if on, will go off immediately on spawn.
export(NodePath) var explosion_vfx

var receivers := []

func _ready():
	if explode_on_ready:
		explode()

func explode():
	if hurt_npc or push_npc:
		set_collision_mask_bit(cmn.colliders.enemy_hurtbox,true)
	if hurt_player or push_player:
		set_collision_mask_bit(cmn.colliders.player,true)
	translate(Vector3.ZERO)
	force_update_transform()
	scale = Vector3.ONE*blast_radius
	$Timer.start(blast_duration)
	if explosion_vfx:
		var xpl_vfx = get_node(explosion_vfx)
		remove_child(xpl_vfx)
		get_tree().current_scene.add_child(xpl_vfx)
		xpl_vfx.global_translation = global_translation
		xpl_vfx.explode()

func _on_Timer_timeout():
	queue_free()


func _on_Explosion_area_entered(area):
	if area.get_collision_layer_bit(cmn.colliders.enemy_hurtbox):
		for node in receivers:
			if area.hit_receiver == node:
				return
		var npc = area.hit_receiver
		receivers.push_front(npc)
		var atk_dict :Dictionary= {}
		var force_vec :Vector3 = npc.global_translation+npc.CENTER_OF_MASS-global_translation
		var dist = min(force_vec.length(),blast_radius)
		var falloff = 1.0 - (dist/float(blast_radius))
		if hurt_npc:
			atk_dict["dmg"] = min_damage + dmg_diff*falloff
		if push_npc:
			atk_dict["push_dir"] = force_vec.normalized()
			atk_dict["force"] = push_force * falloff
			atk_dict["origin"] = global_translation
		npc.get_hit(atk_dict)

func _on_Explosion_body_entered(body):
	if body.get_collision_layer_bit(cmn.colliders.player):
		var atk_dict :Dictionary= {}
		var force_vec :Vector3 = body.global_translation+body.CENTER_OF_MASS-global_translation
		var dist = min(force_vec.length(),blast_radius)
		var falloff = 1.0 - (dist/float(blast_radius))
		if hurt_player:
			atk_dict["dmg"] = min_damage + dmg_diff*falloff
		if push_player:
			atk_dict["push_dir"] = force_vec.normalized()
			atk_dict["force"] = push_force * falloff
			atk_dict["origin"] = global_translation
			atk_dict["caused_by_player"] = caused_by_player
		body.get_hit(atk_dict)
