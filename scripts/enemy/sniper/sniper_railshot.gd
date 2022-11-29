extends Spatial

var distance
	
func _process(delta):
	if $RayCast.get_collider(): 
		distance = transform.origin.distance_to($RayCast.get_collision_point())
		$Scaler.scale.z = distance /2
	else:
		$Scaler.scale.z = $RayCast.cast_to.z
