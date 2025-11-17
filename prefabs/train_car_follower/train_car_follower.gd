class_name TrainCarFollower
extends Node3D

signal moved_to_cell(cell: Vector3)

var queued_cells: Array[Vector3] = []
var moving := false
var elapsed := 0.0

var current_cell := Vector3.ZERO
var next_cell := Vector3.ZERO

var attached := false

var mesh_names: Array[String] = [
	"box", "coal", "container-blue",  "container-green",  "container-red",
	"dirt", "lumber", "tank-large", "tank","wood"
	#,"flatbed", "flatbed-wood"
]
var meshes: Array[Mesh] = []

@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D

func _ready():
	for mesh_name in mesh_names:
		meshes.push_back(load("res://assets/models/train/trains_train-carriage-" +
			mesh_name + ".res"))
	mesh_instance_3d.mesh = meshes[Game.rng.randi_range(0, len(meshes) - 1)]
	position = Game.cell_to_world(current_cell)

func set_leader(leader: Node3D):
	leader.moved_to_cell.connect(_on_leader_moved)

func _on_leader_moved(cell: Vector3):
	if attached:
		queued_cells.append(cell)

func _process(delta):
	if attached:
		if not moving and queued_cells.size() > 0:
			next_cell = queued_cells.pop_front()
			start_move()

		if moving:
			perform_move(delta)

func start_move():
	elapsed = 0.0
	moving = true

func perform_move(delta):
	elapsed += delta
	var t = clamp(elapsed / Game.MOVE_TIME, 0.0, 1.0)

	position = Game.cell_to_world(current_cell).lerp(
		Game.cell_to_world(next_cell), t
	)
	
	var direction := next_cell - current_cell
	var target_angle = atan2(direction.x, direction.z)
	mesh_instance_3d.rotation.y = target_angle

	if t >= 1.0:
		finish_move()

func finish_move():
	moving = false
	current_cell = next_cell
	emit_signal("moved_to_cell", current_cell)
