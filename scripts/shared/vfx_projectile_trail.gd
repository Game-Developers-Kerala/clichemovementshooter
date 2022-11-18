extends Spatial

export var texture : Texture
export(Color) var modulate = Color.white
export(int) var puff_count = 32
export(int) var front_fade = 2
export(float) var interval = 0.05
export(float) var size_factor = 1.0
var puffs := []
var diff :float = 0.125

enum states {NONE,STARTING,RUNNING,STOPPING}
var state = 0

func _ready():
	diff = 1.0/float(puff_count)


func _on_Blink_timeout():
	match state:
		states.NONE:
			pass
		states.STARTING:
			if puffs.size()-1<puff_count:
				spawn_sprite(puffs.size())
			if puffs.size() == puff_count:
				state = states.RUNNING
#				print("trail running")
		states.RUNNING:
			var nextpos = global_translation
			for puff in puffs:
				var temp = puff.global_translation
				puff.global_translation = nextpos
				puff.rotate_object_local(Vector3.FORWARD,OS.get_ticks_msec()%10)
				nextpos = temp
		states.STOPPING:
			var frontpuff = puffs.pop_front()
			var nextpos = frontpuff.global_translation
			frontpuff.queue_free()
			if !puffs:
				queue_free()
				return
			for puff in puffs:
				var temp = puff.global_translation
				puff.global_translation = nextpos
				puff.rotate_object_local(Vector3.FORWARD,OS.get_ticks_msec()%10)
				nextpos = temp

func spawn_sprite(idx:int):
	var spr = Sprite3D.new()
	spr.texture = texture
	spr.modulate = modulate
	spr.opacity = (idx+1)*diff
	spr.scale = Vector3.ONE*size_factor*spr.opacity
	if idx+1>puff_count-front_fade:
		spr.opacity = (puff_count-idx)*(1.0/float(front_fade+1))
	spr.billboard = SpatialMaterial.BILLBOARD_ENABLED
	get_tree().current_scene.add_child(spr)
	spr.global_translation = global_translation
	spr.rotate_object_local(Vector3.FORWARD,idx)
	puffs.push_front(spr)

func start():
#	print("trail starting")
	$Blink.start(interval)
	state = states.STARTING
	_on_Blink_timeout()


func stop():
	if !puffs:
		queue_free()
		return
	state = states.STOPPING


