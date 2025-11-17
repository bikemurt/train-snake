extends Node3D

const TRAIN_CAR_FOLLOWER = preload("uid://c62rf6vx73i5b")

@onready var plane: MeshInstance3D = %Plane
@onready var cell_value: Label = %CellValue
@onready var game_start_screen: ColorRect = %GameStartScreen
@onready var train_head: TrainHead = %TrainHead
@onready var followers: Node3D = %Followers
@onready var score_value: Label = %ScoreValue
@onready var high_score_value: Label = %HighScoreValue
@onready var crash_player: AudioStreamPlayer = %CrashPlayer

var game_started := false

var high_score := 0

func _ready() -> void:
	var p_mesh: PlaneMesh = plane.mesh
	p_mesh.size = Vector2(Game.MAP_SIZE, Game.MAP_SIZE)
	
	var mat: StandardMaterial3D = plane.get_surface_override_material(0)
	mat.uv1_scale = Vector3(1,1,1) * Game.MAP_SIZE / 2.0
	
	game_started = false
	train_head.set_process(false)
	train_head.game_over.connect(game_over)
	
	Game.game_over.connect(game_over)
	
	Game.followers = followers

func reset_followers() -> void:
	for c in followers.get_children(): c.free()
	Game.spawn_new_follower()

func _process(_delta: float) -> void:
	game_start_screen.visible = not game_started
	
	cell_value.text = str(train_head.current_cell)
	
	var c := train_head.current_cell
	var lower := -Game.MAP_SIZE / 2.0
	var upper := Game.MAP_SIZE / 2.0 - 1.0
	if c.x < lower or c.x > upper or c.z < lower or c.z > upper:
		game_over()
	
	if not game_started and Input.is_action_just_pressed("ui_accept"):
		crash_played = false
		reset_followers()
		train_head.reset()
		train_head.start()
		game_started = true
	
	score_value.text = str(len(train_head.followers))
	high_score_value.text = str(high_score)

var crash_played := false
func game_over() -> void:
	if not crash_played:
		crash_player.play()
		crash_played = true
	train_head.stop()
	game_started = false
	var score := len(train_head.followers)
	if score > high_score:
		high_score = score


func _on_quit_pressed() -> void:
	get_tree().quit()
