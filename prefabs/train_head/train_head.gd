class_name TrainHead
extends Node3D

signal moved_to_cell(cell: Vector3)
signal game_over

@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var whistle_player: AudioStreamPlayer = %WhistlePlayer

var followers: Array[TrainCarFollower] = []

var direction := Vector3.ZERO
var desired_direction := Vector3.ZERO
var moving := false
var elapsed := 0.0

var current_cell := Vector3.ZERO
var next_cell := Vector3.ZERO

func _ready():
	Game.train_head = self
	reset()

func reset() -> void:
	current_cell = Game.world_to_cell(Vector3.ZERO)
	position = Game.cell_to_world(current_cell)
	moving = false
	elapsed = 0.0
	direction = Vector3.ZERO
	desired_direction = Vector3.ZERO
	followers.clear()

func _process(delta):
	read_input()

	if moving:
		perform_move(delta)
	else:
		begin_move()
	
	var target_angle = atan2(direction.x, direction.z)
	mesh_instance_3d.rotation.y = target_angle

func read_input():
	var input_dir := Vector3.ZERO

	if Input.is_action_just_pressed("ui_up"):
		input_dir = Vector3(-1, 0, 0)
	elif Input.is_action_just_pressed("ui_down"):
		input_dir = Vector3(1, 0, 0)
	elif Input.is_action_just_pressed("ui_left"):
		input_dir = Vector3(0, 0, 1)
	elif Input.is_action_just_pressed("ui_right"):
		input_dir = Vector3(0, 0, -1)

	if input_dir == -direction: return

	if input_dir != Vector3.ZERO:
		desired_direction = input_dir

func begin_move():
	if desired_direction != Vector3.ZERO:
		direction = desired_direction

	if direction == Vector3.ZERO:
		return

	next_cell = current_cell + direction
	elapsed = 0.0
	moving = true
	
	if not audio_stream_player.playing:
		audio_stream_player.play()

func perform_move(delta):
	elapsed += delta
	var t = clamp(elapsed / Game.MOVE_TIME, 0.0, 1.0)

	position = Game.cell_to_world(current_cell).lerp(
		Game.cell_to_world(next_cell), t
	)

	if t >= 1.0:
		finish_move()

func finish_move():
	moving = false
	current_cell = next_cell
	emit_signal("moved_to_cell", current_cell)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("train_car_follower"):
		var train_car_follower: TrainCarFollower = area.get_parent()
		if not train_car_follower.attached:
			if len(followers) == 0:
				train_car_follower.set_leader(self)
			else:
				var f: TrainCarFollower = followers[len(followers) - 1]
				train_car_follower.set_leader(f)
			whistle_player.play()
			train_car_follower.attached = true
			followers.push_back(train_car_follower)
			
			Game.spawn_new_follower()
		else:
			# ignore the first follower
			if len(followers) > 0:
				if train_car_follower == followers[0]: return
			
			# END GAME
			game_over.emit()

func stop() -> void:
	audio_stream_player.stop()
	set_process(false)
	for f in followers:
		f.set_process(false)
	
func start() -> void:
	set_process(true)
