extends Node2D

var cfg: ConfigLoader
var fps: int
var duration: float
var arena_size: int
var black_start: float
var elapsed: float = 0.0

@onready var black_screen: Sprite2D = %BlackScreen
@onready var arena: Arena = %Arena


func _ready() -> void:
	cfg = ConfigLoader.new()
	cfg.load_external_config()

	fps = int(cfg.get_value("fps", "60"))
	duration = float(cfg.get_value("duration_seconds", "10"))
	arena_size = int(cfg.get_value("arena_size", "800"))
	arena.set_arena_size(arena_size)

	var raw_black_start: String = cfg.get_value("black_screen_start", "")
	if raw_black_start == "":
		black_start = duration - 2.0
	else:
		black_start = float(raw_black_start)

	_spawn_balls()

	var recorder := FrameRecorder.new()
	add_child(recorder)
	recorder.start_recording(fps, duration)

	# Écran noir
	black_screen.texture = generate_black_texture()
	scale_sprite_to_viewport(black_screen)


func generate_black_texture() -> Texture2D:
	var size: int = 64
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	return ImageTexture.create_from_image(img)


func scale_sprite_to_viewport(sprite: Sprite2D) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var tex_size: Vector2 = sprite.texture.get_size()
	var scale_x: float = viewport_size.x / tex_size.x
	var scale_y: float = viewport_size.y / tex_size.y
	sprite.scale = Vector2(scale_x, scale_y)


func _spawn_balls() -> void:
	var balls_node: Node = $Balls

	for child in balls_node.get_children():
		child.queue_free()

	var ball_count: int = int(cfg.get_value("ball_count", "1"))
	var radius: float = float(cfg.get_value("ball_radius", "20.0"))

	var color_raw: String = String(cfg.get_value("ball_colors", "#ffffff"))
	var color_list: Array[String] = _to_string_array(color_raw.split(","))

	var pos_raw: String = String(cfg.get_value("ball_positions", "100,100"))
	var pos_entries: Array[String] = _to_string_array(pos_raw.split(";"))

	var dir_raw: String = String(cfg.get_value("ball_directions", "1,0"))
	var dir_entries: Array[String] = _to_string_array(dir_raw.split(";"))

	var speed_raw: String = String(cfg.get_value("ball_speeds", "100"))
	var speed_entries: Array[String] = _to_string_array(speed_raw.split(","))

	var ball_scene: PackedScene = load("res://Ball.tscn")

	for i in range(ball_count):
		var ball: Node2D = ball_scene.instantiate()

		var color_idx := i % color_list.size()
		ball.call("setup_color", color_list[color_idx])
		ball.set("radius", radius)

		var pos_tokens := _to_string_array(pos_entries[i % pos_entries.size()].split(","))
		ball.global_position = Vector2(float(pos_tokens[0]), float(pos_tokens[1]))

		var dir_tokens := _to_string_array(dir_entries[i % dir_entries.size()].split(","))
		var dir_vec := Vector2(float(dir_tokens[0]), float(dir_tokens[1]))

		var speed_value := float(speed_entries[i % speed_entries.size()])
		ball.call("setup_motion", dir_vec, speed_value)

		balls_node.add_child(ball)


func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= black_start:
		black_screen.show()

func _to_string_array(psa: PackedStringArray) -> Array[String]:
	var arr: Array[String] = []
	for s in psa:
		arr.append(String(s))
	return arr
