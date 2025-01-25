@tool
extends State
class_name Fall

@export_category("Movement Parameters")
## Horizontal air control (matches Jump state exactly)
@export_range(0.0, 1.0) var air_control: float = 0.8
## Maximum horizontal air speed (matches Jump state)
@export var air_speed: float = 120.0
## Gravity parameters (sync with Jump state)
@export var gravity: Vector2 = Vector2(0, 980)
@export var use_player_gravity: bool = true

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
	if use_player_gravity and not player.has_method("get_gravity"):
		warnings.append("Player needs get_gravity() method when using player gravity")
	return warnings

func Enter():
	super()
	if animated_sprite:
		animated_sprite.play(fall_animation)
	
	# Clamp existing horizontal velocity to match Jump state limits
	player.velocity.x = clamp(player.velocity.x, -air_speed, air_speed)

func Physics_Update(delta: float):
	super(delta)
	if Engine.is_editor_hint() or not is_instance_valid(player):
		return
	
	apply_gravity(delta)
	handle_air_control(delta)
	player.move_and_slide()
	handle_sprite_flipping()
	check_landing()

func apply_gravity(delta: float):
	var actual_gravity = gravity
	if use_player_gravity and player.has_method("get_gravity"):
		actual_gravity = player.get_gravity()
	player.velocity += actual_gravity * delta

# Exact duplicate of Jump state's air control
func handle_air_control(delta: float):
	var direction = Input.get_axis("move_left", "move_right")
	var target_speed = direction * air_speed
	var acceleration = air_speed * 10 * delta * air_control
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		target_speed, 
		acceleration
	)
	
	# Strict speed limit enforcement
	player.velocity.x = clamp(player.velocity.x, -air_speed, air_speed)

	
func handle_sprite_flipping():
	if not animated_sprite:
		return
	
	if player.velocity.x != 0:
		animated_sprite.flip_h = player.velocity.x < 0

func check_landing():
	if player.is_on_floor():
		coyote_timer.stop()
		transition_to_next_state()

func transition_to_next_state():
	var input_dir = Input.get_axis("move_left", "move_right")
	var velocity_dir = sign(player.velocity.x)
	
	# Identical transition logic to Jump state
	if abs(input_dir) > 0.1 and (sign(input_dir) == velocity_dir or velocity_dir == 0):
		transition_to(&"run")
	else:
		transition_to(&"idle")
