@tool
extends State
class_name Jump

@export_category("Jump Parameters")
## Initial upward velocity when jumping[br][i](Negative values jump upwards)[/i]
@export var jump_velocity: float = -300.0
## Multiplier applied when releasing jump button early[br][i](0.0-1.0)[/i]
@export_range(0.0, 1.0) var jump_cut_multiplier: float = 0.5
## Horizontal air control multiplier[br][i](0.0=no control, 1.0=full control)[/i]
@export_range(0.0, 1.0) var air_control: float = 0.8
## Maximum horizontal speed while airborne
@export var air_speed: float = 120.0
## Minimum time before recognizing landing (prevents ground snaps)
@export_range(0.0, 0.5) var landing_buffer: float = 0.1
## Gravity applied during jump[br][i](Set to -1 to use player's gravity)[/i]
@export var gravity: Vector2 = Vector2(0, 980)
@export var use_player_gravity: bool = true

@export_category("Node References")
@export var animated_sprite: AnimatedSprite2D
@export var coyote_timer: CoyoteTimer

@export_category("Visuals")
## Animation name for jumping
@export var jump_animation: StringName = &"jump"

var has_jump_released := false
var jump_time := 0.0
var initial_horizontal_speed := 0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if not player:
		warnings.append("Player must be assigned")
	if not animated_sprite:
		warnings.append("AnimatedSprite must be assigned")
	if not coyote_timer:
		warnings.append("CoyoteTimer must be assigned")
	if use_player_gravity and not player.has_method("get_gravity"):
		warnings.append("Player needs get_gravity() method when using player gravity")
	if animated_sprite and not animated_sprite.sprite_frames.has_animation(jump_animation):
		warnings.append("Missing '%s' animation" % jump_animation)
	return warnings

func Enter():
	super()
	has_jump_released = false
	jump_time = 0.0
	initial_horizontal_speed = player.velocity.x
	player.velocity.y = jump_velocity
	coyote_timer.stop()
	
	# Preserve horizontal momentum
	if initial_horizontal_speed == 0:
		player.velocity.x = Input.get_axis("move_left", "move_right") * air_speed
	
	if animated_sprite:
		animated_sprite.play(jump_animation)

func Update(delta: float):
	if Engine.is_editor_hint():
		return
	
	# Variable jump height control
	if Input.is_action_just_released("ui_accept") and player.velocity.y < 0:
		player.velocity.y *= jump_cut_multiplier
		has_jump_released = true

func Physics_Update(delta: float):
	if Engine.is_editor_hint() or not is_instance_valid(player):
		return
	
	jump_time += delta
	apply_gravity(delta)
	handle_air_control(delta)
	check_transitions()
	player.move_and_slide()

func apply_gravity(delta: float):
	var actual_gravity = gravity
	if use_player_gravity and player.has_method("get_gravity"):
		actual_gravity = player.get_gravity()
	player.velocity += actual_gravity * delta

func handle_air_control(delta: float):
	var direction = Input.get_axis("move_left", "move_right")
	var target_speed = direction * air_speed
	var acceleration = air_speed * 10 * delta * air_control
	
	player.velocity.x = move_toward(
		player.velocity.x, 
		target_speed, 
		acceleration
	)

func check_transitions():
	# Skip transitions during landing buffer
	if jump_time <= landing_buffer:
		return
	
	# Landing detection
	if player.is_on_floor():
		handle_landing()
		return
	
	# Natural fall transition
	if player.velocity.y > 0:
		transition_to(&"fall")

func handle_landing():
	var input_dir = Input.get_axis("move_left", "move_right")
	var velocity_dir = sign(player.velocity.x)
	
	# Transition to run if maintaining movement
	if abs(input_dir) > 0.1 and (sign(input_dir) == velocity_dir or velocity_dir == 0):
		transition_to(&"run")
	else:
		transition_to(&"idle")
