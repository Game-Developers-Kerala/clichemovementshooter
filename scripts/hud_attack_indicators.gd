extends Control

var time := 0.0

const DUR_INDIC = 0.35
const MIN_ANGLE := 45

func _ready():
	set_process(false)
	get_child(0).hide()



func new_attack(playerglobalxform:Transform,camglobalXform:Transform,atkOrigin:Vector3):
	var ppos = playerglobalxform.origin
	var pbas = playerglobalxform.basis.orthonormalized()
	var campos = camglobalXform.origin
	var cambas = camglobalXform.basis.orthonormalized()
	var dir_to_attack = campos.direction_to(atkOrigin)
	if acos(dir_to_attack.dot(-cambas.z)) < deg2rad(MIN_ANGLE):
		return
	if atkOrigin.y < campos.y+1:
		var xzplane = Plane(cambas.y,cambas.y.dot(campos))
		var atkorigin_distto_xz = xzplane.distance_to(atkOrigin)
		dir_to_attack = campos.direction_to(atkOrigin-(abs(atkorigin_distto_xz)+0.02)*cambas.y)
	var perp_to_plane = dir_to_attack.cross(-cambas.z).normalized()
	var perp_to_perp = -perp_to_plane.cross(-cambas.z).normalized()
	var angle = acos(perp_to_perp.dot(cambas.x))
	get_child(0).rotation = angle*(1-2*int(-perp_to_perp.dot(cambas.y)<0))
	get_child(0).show()
	set_process(true)

func _process(delta):
	time += delta
	if time >= DUR_INDIC:
		time = 0.0
		get_child(0).hide()
		set_process(false)
