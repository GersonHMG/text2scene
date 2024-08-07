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
	
	for i in range(0,50):
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
	var w_segment_d = wall[0].distance_to(wall[1])
	
	var start_point = randi() % (wall[1].x - wall[0].x) + wall[0].x


# Returns a segment that represent a wall
func get_random_wall():
	return [Vector2(0,0), Vector2(4,0), 0]

func _ready():
	randomize()
	for i in range(0,30):
		try_spawn("res://objects/bed/Bed.tscn")
