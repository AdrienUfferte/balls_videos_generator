extends Node2D
class_name Arena

@export var arena_size: float = 800.0
@export var border_thickness: float = 6.0
@export var border_color: Color = Color.WHITE


func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, Vector2(arena_size, arena_size))
		draw_rect(rect, border_color, false, border_thickness, true)


func set_arena_size(size: float) -> void:
		arena_size = size
		queue_redraw()
