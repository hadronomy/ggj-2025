@tool
extends State
class_name Run

@export_category("Movement Parameters")
@export var move_speed: float = 150.0
@export_range(0.0, 1.0) var input_deadzone: float = 0.1
@export var coyote_duration: float = 0.15

@export_category("Node References")
@export var animated_sprite: AnimatedSprite2D
@export var coyote_timer: CoyoteTimer

@export_category("Visuals")
@export var run_animation: StringName = &"run"

@export_category("Debug")
@export var debug_movement: bool = false

var was_on_floor := false

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if not animated_sprite:
		warnings.append("AnimatedSprite must be assigned")
	if not coyote_timer:
		warnings.append("CoyoteTimer must be assigned")
	if animated_sprite and not animated_sprite.sprite_frames.has_animation(run_animation):
		warnings.append("Missing '%s' animation" % run_animation)
	return warnings

func Enter():
	super()
	was_on_floor = player.is_on_floor()
	coyote_timer.wait_time = coyote_duration
	
	if animated_sprite:
		animated_sprite.play(run_animation)
	
	# Reset horizontal velocity when entering state
	player.velocity.x = 0

func Physics_Update(delta: float):
	super(delta)
	
	if Input.is_action_just_pressed("jump") and can_jump():
		transition_to(&"jump")
		return
	
	handle_movement(delta)
	update_animations()
	check_transitions()

func can_jump() -> bool:
	return player.is_on_floor() or (coyote_timer and not coyote_timer.is_stopped())

func handle_movement(delta: float):
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * move_speed
	
	if debug_movement:
		print("Move Speed: ", move_speed, " | Direction: ", direction)

func update_animations():
	if not animated_sprite:
		return
	
	# Only flip sprite if actually moving
	if abs(player.velocity.x) > 0.1:
		animated_sprite.flip_h = player.velocity.x < 0

func check_transitions():
	var current_direction = Input.get_axis("move_left", "move_right")
	
	if player.is_on_floor():
		if abs(current_direction) < input_deadzone and is_zero_approx(player.velocity.x):
			transition_to(&"idle")
	else:
		if was_on_floor:
			coyote_timer.start()
		
		if coyote_timer.is_stopped():
			transition_to(&"fall")
	
	was_on_floor = player.is_on_floor()
