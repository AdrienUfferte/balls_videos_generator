extends Node
class_name FrameRecorder

var fps: int = 60
var duration: float = 5.0
var total_frames: int = 0
var current_frame: int = 0
var capturing: bool = false
var accumulator: float = 0.0


func start_recording(p_fps: int, p_seconds: float) -> void:
	fps = p_fps
	duration = p_seconds
	total_frames = int(fps * duration)
	current_frame = 0
	accumulator = 0.0
	capturing = false

	Engine.time_scale = 0.0
	# Ici : NE PLUS ajouter le node — il doit déjà être dans la scène
	# add_child() se fait depuis Main.gd


func _process(delta: float) -> void:
	if not capturing:
		capturing = true

	var step: float = 1.0 / fps
	accumulator += delta

	if accumulator >= step:
		accumulator -= step
		_capture()


func _capture() -> void:
	var img: Image = get_viewport().get_texture().get_data()
	img.flip_y()
	img.save_png("user://frame_%05d.png" % current_frame)

	current_frame += 1

	if current_frame >= total_frames:
		Engine.time_scale = 1.0
		get_tree().quit()
