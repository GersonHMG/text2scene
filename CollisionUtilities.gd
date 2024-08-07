class_name CollisionUtilities extends Node


# Return a list of corners of a rectangle shape
func get_vertices(collision : CollisionShape):
	var box_shape : BoxShape = collision.shape
	var size : Vector3 = box_shape.extents
	var pos : Vector3 = collision.global_translation
	var points : Array = []
	var iteration = [Vector2(-1,-1),Vector2(1,-1), Vector2(1,1), Vector2(-1,1)]
	
	var rot_deg = abs(rad2deg(collision.global_rotation.y))
	if( int(rot_deg) == 90 || int(rot_deg) == 270):
		size = Vector3(size.z, 0, size.x)
	
	for i in iteration:
		var point : Vector2 = Vector2(i.x*size.x, i.y*size.z)
		point += Vector2(pos.x, pos.z)
		points.append(point)
	return points

func are_boxes_colliding(col_a : CollisionShape, col_b : CollisionShape):
	var rect_a = get_vertices(col_a)
	var rect_b = get_vertices(col_b)
	var a_1 = rect_a[0]
	var a_2 = rect_a[2]
	var b_1 = rect_b[0]
	var b_2 = rect_b[2]
	if (a_1.x < b_2.x and a_2.x > b_1.x 
	and a_1.y < b_2.y and a_2.y > b_1.y):
		return true
	return false

func is_outside_room(room : Array, coll : CollisionShape):
	var rect = get_vertices(coll)
	var room_x1 = room[0]
	var room_x2 = room[1]
	var coll_x1 = rect[0]
	var coll_x2 = rect[2]
	
	if (room_x1.x <= coll_x1.x and room_x1.y <= coll_x1.y and
	 room_x2.x >= coll_x2.x and room_x2.y >= coll_x2.y):
		return false
	return true
