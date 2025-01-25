@tool
extends State
class_name Fall

@export_category("Movement Parameters")
@export var air_speed: float = 150.0
@export var air_resistance: float = 400.0

@export_category("Node References")
@export var animated_sprite: AnimatedSprite2D
@export var coyote_timer: CoyoteTimer

@export_category("Visuals")
@export var fall_animation: StringName = &"fall"

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if not animated_sprite:
		warnings.append("AnimatedSprite must be assigned")
	if not coyote_timer:
		warnings.append("CoyoteTimer must be assigned")
	if animated_sprite and not animated_sprite.sprite_frames.has_animation(fall_animation):
		warnings.append("Missing '%s' animation" % fall_animation)
	return warnings

func Enter():
	super()
	if animated_sprite:
		animated_sprite.play(fall_animation)

func Physics_Update(delta: float):
	super(delta)
	if Engine.is_editor_hint() or not is_instance_valid(player):
		return
	
	apply_gravity(delta)
	handle_movement(delta)
	handle_sprite_flipping()
	check_landing()

func apply_gravity(delta: float):
	if player.has_method("get_gravity"):
		var gravity_vector = player.get_gravity()
		player.velocity += gravity_vector * delta
	else:
		player.velocity.y += 980 * delta

func handle_movement(delta: float):
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * air_speed if direction else move_toward(player.velocity.x, 0, air_resistance * delta)

func handle_sprite_flipping():
	if not animated_sprite:
		return
	
	if player.velocity.x != 0:
		animated_sprite.flip_h = player.velocity.x < 0

func check_landing():
	if player.is_on_floor() and player.velocity.y >= 0:
		coyote_timer.stop()
		transition_to_next_state()

func transition_to_next_state():
	var input_dir = Input.get_axis("move_left", "move_right")
	transition_to(&"run" if abs(input_dir) > 0.1 else &"idle")
