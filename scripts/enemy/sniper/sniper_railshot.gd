extends Spatial

func init(from:Vector3,to:Vector3):
	
	look_at_from_position(from,to,Vector3.UP)
	var length = (to-from).length()
	scale.z += length
