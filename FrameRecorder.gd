extends Node
class_name FrameRecorder

var fps: int = 60
var duration: float = 5.0
var total_frames: int = 0
var current_frame: int = 0
var accumulator: float = 0.0


func start_recording(p_fps: int, p_seconds: float) -> void:
	fps = p_fps
	duration = p_seconds
	total_frames = int(fps * duration)
	current_frame = 0
	accumulator = 0.0


func _process(delta: float) -> void:
	accumulator += delta
	var step: float = 1.0 / fps

	while accumulator >= step and current_frame < total_frames:
		accumulator -= step
		_capture()

	if current_frame >= total_frames:
		get_tree().quit()


func _capture() -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("user://frame_%05d.png" % current_frame)
	current_frame += 1
