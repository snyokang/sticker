class_name Sticker
extends Sprite2D

@export var sticky: float = 20.0
@export var elasticity: float = 100.0

var is_dragging: bool
var pivot: Vector2
var target: Vector2
var curr: Vector2
var grip: Vector2


func _process(delta: float) -> void:
	if is_zero_approx(curr.distance_squared_to(target)):
		return
	
	var approach := 1.0 - exp((-sticky if is_dragging else -elasticity) * delta)
	curr = lerp(curr, target, approach)
	_set_parameters((grip - curr).normalized(), curr)


func _input(event: InputEvent) -> void:
	
	var mouse_pos := get_local_mouse_position()
	
	if event is InputEventMouseMotion:
		if not is_dragging:
			return
		target = mouse_pos.lerp(grip, 0.5)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if get_rect().has_point(mouse_pos):
					start_drag(mouse_pos)
			elif is_dragging:
				end_drag()


func start_drag(mouse_pos: Vector2) -> void:
	if is_zero_approx(mouse_pos.length_squared()):
		mouse_pos = Vector2.DOWN
	
	pivot = mouse_pos * 1.1
	while is_pixel_opaque(pivot):
		pivot += mouse_pos.normalized()
	
	target = mouse_pos.lerp(pivot, 0.4)
	grip = mouse_pos.lerp(pivot, 0.8)
	curr = target.lerp(grip, 0.9)
	
	_set_parameters((grip - curr).normalized(), curr)
	
	is_dragging = true


func end_drag() -> void:
	var norm := pivot - grip
	var dot_max: float = 0.0
	
	for dir: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		var dot := norm.dot(dir)
		print(dot)
		if dot > dot_max:
			target = pivot + 4 * dir
			grip = target + 1 * dir
			dot_max = dot
	
	is_dragging = false


func _set_parameters(n: Vector2, p: Vector2) -> void:
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter(&"n", n)
	shader_material.set_shader_parameter(&"p0", p)
