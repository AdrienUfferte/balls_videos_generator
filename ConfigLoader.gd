extends Node
class_name ConfigLoader

var config: Dictionary = {}


func load_external_config() -> void:
	var path: String = "res://export/config.txt"
	if not FileAccess.file_exists(path):
		path = "config.txt"
	if not FileAccess.file_exists(path):
		OS.alert("ERROR: config.txt not found next to executable.")
		get_tree().quit()
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		OS.alert("ERROR: Cannot open config.txt.")
		get_tree().quit()
		return

	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()

		if line == "" or line.begins_with("#"):
			continue

		var tokens: PackedStringArray = line.split("=")

		if tokens.size() == 2:
			var key: String = tokens[0].strip_edges()
			var value: String = tokens[1].strip_edges()

			# Important : we ALWAYS store strings
			config[key] = value


func get_value(key: String, default_value: String) -> String:
	if config.has(key):
		# Always return a string
		return String(config[key])
	return default_value
