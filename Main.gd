extends Node2D

var cfg: ConfigLoader
var fps: int
var duration: float
var arena_size: int
var black_start: float
var black_duration: float

var elapsed: float = 0.0


func _ready() -> void:
	cfg = ConfigLoader.new()
	cfg.load_external_config()

	fps = int(cfg.get_value("fps", "60"))
	duration = float(cfg.get_value("duration_seconds", "10"))
	arena_size = int(cfg.get_value("arena_size", "800"))

	var raw_black_start: String = cfg.get_value("black_screen_start", "")
	if raw_black_start == "":
		black_start = duration - 2.0
	else:
		black_start = float(raw_black_start)

	black_duration = float(cfg.get_value("black_screen_duration", "1.0"))

	_spawn_balls()

	var recorder := FrameRecorder.new()
	add_child(recorder)
	recorder.start_recording(fps, duration)


func _spawn_balls() -> void:
	var balls_node: Node = $Balls

	# Correctement vider le conteneur
	for child in balls_node.get_children():
		child.queue_free()

	var ball_count: int = int(cfg.get_value("ball_count", "1"))
	var radius: float = float(cfg.get_value("ball_radius", "20.0"))

	# Colors
	var color_raw: String = String(cfg.get_value("ball_colors", "#ffffff"))
	var color_psa: PackedStringArray = color_raw.split(",")
	var color_list: Array[String] = _to_string_array(color_psa)

	# Positions
	var pos_raw: String = String(cfg.get_value("ball_positions", "100,100"))
	var pos_psa: PackedStringArray = pos_raw.split(";")
	var pos_entries: Array[String] = _to_string_array(pos_psa)

	# Directions
	var dir_raw: String = String(cfg.get_value("ball_directions", "1,0"))
	var dir_psa: PackedStringArray = dir_raw.split(";")
	var dir_entries: Array[String] = _to_string_array(dir_psa)

	# Speeds
	var speed_raw: String = String(cfg.get_value("ball_speeds", "100"))
	var speed_psa: PackedStringArray = speed_raw.split(",")
	var speed_entries: Array[String] = _to_string_array(speed_psa)

	var ball_scene: PackedScene = load("res://Ball.tscn")

	for i in range(ball_count):
		var ball: Node2D = ball_scene.instantiate()

		# Couleur
		var color_idx: int = i % color_list.size()
		ball.call("setup_color", color_list[color_idx])

		# Radius
		ball.set("radius", radius)

		# Position
		var pos_token_psa: PackedStringArray = pos_entries[i % pos_entries.size()].split(",")
		var pos_tokens: Array[String] = _to_string_array(pos_token_psa)

		var pos_vec: Vector2 = Vector2(
			float(pos_tokens[0]),
			float(pos_tokens[1])
		)
		ball.global_position = pos_vec

		# Direction
		var dir_token_psa: PackedStringArray = dir_entries[i % dir_entries.size()].split(",")
		var dir_tokens: Array[String] = _to_string_array(dir_token_psa)

		var dir_vec: Vector2 = Vector2(
			float(dir_tokens[0]),
			float(dir_tokens[1])
		)

		# Speed
		var speed_value: float = float(speed_entries[i % speed_entries.size()])

		ball.call("setup_motion", dir_vec, speed_value)

		balls_node.add_child(ball)



func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= black_start:
		$BlackScreen.visible = true

	if elapsed >= black_start + black_duration:
		$BlackScreen/QuestionMark.visible = true



func _to_string_array(psa: PackedStringArray) -> Array[String]:
	var arr: Array[String] = []
	for s in psa:
		arr.append(String(s))
	return arr
