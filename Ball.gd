extends Area2D
class_name Ball

@export var radius: float = 20.0
var velocity: Vector2 = Vector2.ZERO
var shape: CircleShape2D


func _ready() -> void:
	_create_sprite()
	_create_collision_shape()

func setup_color(color_hex: String) -> void:
	var col: Color = Color(color_hex)
	$Sprite2D.modulate = col

func setup_motion(direction: Vector2, speed: float) -> void:
	velocity = direction.normalized() * speed

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	_handle_wall_bounce()
	_handle_ball_collisions()

func _create_sprite() -> void:
	var texture: Texture2D = _generate_circle_texture(radius)
	$Sprite2D.texture = texture
	$Sprite2D.centered = true

func _create_collision_shape() -> void:
	shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape

func _generate_circle_texture(r: float) -> Texture2D:
	var size: int = int(r * 2)
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	for y in range(size):
		for x in range(size):
			var dx: float = x - r
			var dy: float = y - r
			if dx * dx + dy * dy <= r * r:
				img.set_pixel(x, y, Color.WHITE)
			else:
				img.set_pixel(x, y, Color.TRANSPARENT)

	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

func _handle_wall_bounce() -> void:
	var half: float = radius
	var main: Node2D = get_parent().get_parent()
	var arena_size: float = main.arena_size

	if global_position.x < half:
		global_position.x = half
		velocity.x = -velocity.x

	if global_position.x > arena_size - half:
		global_position.x = arena_size - half
		velocity.x = -velocity.x

	if global_position.y < half:
		global_position.y = half
		velocity.y = -velocity.y

	if global_position.y > arena_size - half:
		global_position.y = arena_size - half
		velocity.y = -velocity.y

func _handle_ball_collisions() -> void:
	for other in get_parent().get_children():
		if other == self:
			continue

		var other_ball: Ball = other as Ball
		if other_ball == null:
			continue

		var dist: float = global_position.distance_to(other_ball.global_position)
		var min_dist: float = radius + other_ball.radius

		if dist < min_dist:
			var normal: Vector2 = (global_position - other_ball.global_position).normalized()
			var rel: Vector2 = velocity - other_ball.velocity
			var sep: float = rel.dot(normal)

			if sep < 0.0:
				velocity = velocity - normal * sep
				other_ball.velocity = other_ball.velocity + normal * sep
