extends Node

const TRAIN_CAR_FOLLOWER = preload("uid://c62rf6vx73i5b")

const MOVE_TIME := 0.25
const GRID_SIZE := Vector3(1.0, 0.0, 1.0)
const MAP_SIZE := 10
const FOLLOWERS := 6

signal game_over

var rng := RandomNumberGenerator.new()

var train_head: TrainHead
var followers: Node3D

func _ready() -> void:
	rng.randomize()

func world_to_cell(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / GRID_SIZE.x),
		pos.y,
		round(pos.z / GRID_SIZE.z)
	)

func cell_to_world(cell: Vector3) -> Vector3:
	return Vector3(
		cell.x * GRID_SIZE.x,
		cell.y,
		cell.z * GRID_SIZE.z
	)

func spawn_new_follower():
	var occupied := {}
	occupied[Vector3i(train_head.current_cell)] = true

	for follower in followers.get_children():
		occupied[Vector3i(follower.current_cell)] = true

	# Build potential spawn zone
	var candidates: Array[Vector3i] = []
	var h := roundi(MAP_SIZE / 2.0)
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var cell := Vector3i(x - h, 0, y - h)
			if cell not in occupied:
				candidates.push_back(cell)
	if len(candidates) == 0:
		# no more left, game over?
		game_over.emit()
	else:
		var chosen: Vector3i = candidates.pick_random()
		_spawn_follower_at(chosen)
	
func _spawn_follower_at(cell: Vector3i):
	var follower := TRAIN_CAR_FOLLOWER.instantiate()
	follower.current_cell = Vector3(cell)
	followers.add_child(follower)
