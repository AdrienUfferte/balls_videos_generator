extends Node
class_name FrameRecorder

var fps: int = 60
var duration: float = 5.0
var total_frames: int = 0
var current_frame: int = 0
var accumulator: float = 0.0

var output_folder: String = ""


func start_recording(p_fps: int, p_seconds: float) -> void:
	fps = p_fps
	duration = p_seconds
	total_frames = int(fps * duration)
	current_frame = 0
	accumulator = 0.0

	print("[Recorder] Start recording")
	print("[Recorder] fps =", fps)
	print("[Recorder] duration =", duration)
	print("[Recorder] total_frames =", total_frames)

	_create_output_folder()


func _process(delta: float) -> void:
	accumulator += delta
	var step: float = 1.0 / fps

	while accumulator >= step and current_frame < total_frames:
		accumulator -= step
		_capture()

	if current_frame >= total_frames:
		print("[Recorder] Finished recording, quitting…")
		get_tree().quit()


func _capture() -> void:
	var file_path: String = "%s/frame_%05d.png" % [output_folder, current_frame]
	print("[Recorder] Capturing frame", current_frame, "→", file_path)

	var img: Image = get_viewport().get_texture().get_image()
	var err := img.save_png(file_path)

	if err != OK:
		print("[Recorder] ERROR saving frame", current_frame, "(code =", err, ")")
	else:
		print("[Recorder] OK saved")

	current_frame += 1


func _create_output_folder() -> void:
	var now: Dictionary = Time.get_datetime_dict_from_system()

	var timestamp: String = "%04d_%02d_%02d_%02d_%02d_%02d" % [
		now.year,
		now.month,
		now.day,
		now.hour,
		now.minute,
		now.second
	]

	var is_editor: bool = OS.has_feature("editor")

	if is_editor:
		output_folder = "user://%s" % timestamp
	else:
		var exec_dir: String = OS.get_executable_path().get_base_dir()
		output_folder = "%s/%s" % [exec_dir, timestamp]

	print("[Recorder] Output folder:", output_folder)

	if not DirAccess.dir_exists_absolute(output_folder):
		var ok := DirAccess.make_dir_recursive_absolute(output_folder)
		print("[Recorder] Folder creation code:", ok)
	else:
		print("[Recorder] Folder already exists")
