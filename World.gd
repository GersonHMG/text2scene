extends Spatial


## Room data
const x_min = 0
const x_max = 4
const z_min = 0
const z_max = 4

var OBJECTS = []


func get_random_floor_point() -> Vector3:
	var rand_x = rand_range(x_min, x_max)
	var rand_z = rand_range(z_min, z_max)
	return Vector3(rand_x, 0, rand_z)


func try_spawn(scene_name) -> Spatial:
	var scene : Spatial = load(scene_name).instance()
	add_child(scene)
	var rand_angle = [0,PI/2,PI/2*2,PI/2*3][randi()%3]
	scene.global_rotation.y = rand_angle
	for i in range(0,50):
		if i%3 == 0:
			move_to_random_corner(scene)
		else:
			var rand_pos = get_random_floor_point()
			scene.global_translation = rand_pos
		#Check for collision
		if (!obj_is_valid_pos(scene)):
			OBJECTS.append(scene)
			#scene.global_translation = Vector3(x_max,0, z_max)
			return scene
	scene.queue_free()
	return scene


func obj_is_valid_pos(obj) -> bool:
	var check : CollisionUtilities = CollisionUtilities.new()
	var obj_coll = obj.get_node("CollisionShape")
	for i in OBJECTS:
		if check.are_boxes_colliding(i.get_node("CollisionShape"), obj_coll):
			return true
	var room_limits = [Vector2(x_min, z_min),Vector2(x_max,z_max)]
	if check.is_outside_room(room_limits, obj_coll):
		return true
	return false

func move_to_random_wall(obj : Spatial):
	var wall : Array = get_random_wall()
	var check : CollisionUtilities = CollisionUtilities.new()
	var vertices = check.get_vertices(obj.get_node("CollisionShape"))
	
	# Check the dir of the wall
	var wall_type = wall[2]
	var obj_segment = [vertices[0], vertices[1]]
	if wall_type == 0:
		pass
	elif wall_type == 1:
		obj_segment = [vertices[1],vertices[2]]
	elif wall_type == 2:
		obj_segment = [vertices[3],vertices[2]]
	elif wall_type == 3:
		obj_segment = [vertices[0],vertices[3]]
	
	var o_segment_d = obj_segment[0].distance_to(obj_segment[1])
	# Object is always less than wall
	var place_segment = wall[0].distance_to(wall[1]) - o_segment_d
	var dir_vec = (wall[1] - wall[0]).normalized()
	
	var rand_n = rand_range(0, place_segment) 
	var rand_point = dir_vec*rand_n
	
	rand_point += wall[0]
	var obj_pos = Vector2(obj.global_translation.x, obj.global_translation.z) - obj_segment[0]
	obj_pos += rand_point
	obj.global_translation = Vector3(obj_pos.x,0,obj_pos.y)


func move_to_random_corner(obj : Spatial):
	var corner : Array = get_random_corner()
	var check : CollisionUtilities = CollisionUtilities.new()
	var vertices = check.get_vertices(obj.get_node("CollisionShape"))
	
	# Check the dir of the wall
	var corner_type = corner[1]
	var obj_vertex = vertices[0]
	if corner_type == 0:
		pass
	elif corner_type == 1:
		obj_vertex = vertices[1]
	elif corner_type == 2:
		obj_vertex = vertices[2]
	elif corner_type == 3:
		obj_vertex = vertices[3]
	
	
	var obj_pos = Vector2(obj.global_translation.x, obj.global_translation.z) - obj_vertex
	obj_pos += corner[0]
	obj.global_translation = Vector3(obj_pos.x,0,obj_pos.y)


# Returns a segment that represent a wall
func get_random_wall():
	var walls = [
		[Vector2(0,0), Vector2(4,0), 0],
		[Vector2(4,0), Vector2(4,4), 1],
		[Vector2(0,4), Vector2(4,4), 2],
		[Vector2(0,0), Vector2(0,4), 3]
	]
	return walls[randi()%walls.size()]

func get_random_corner():
	var corners = [
		[Vector2(0,0), 0],
		[Vector2(4,0), 1],
		[Vector2(4,4), 2],
		[Vector2(0,4), 3]
	]
	return corners[randi()%corners.size()]


func _ready():
	randomize()
	for i in range(0,30):
		var obj = try_spawn("res://objects/bed/Bed.tscn")
		
