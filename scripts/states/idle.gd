@tool
extends State
class_name Idle
		
@export var animated_sprite: AnimatedSprite2D:
	set(value):
		animated_sprite = value
		update_configuration_warnings()
		

const SPEED = 150.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if not animated_sprite:
		warnings.append("AnimatedSprite must be assigned")
	if animated_sprite and not animated_sprite.sprite_frames.has_animation("idle"):
		warnings.append("Missing 'idle' animation")
	return warnings

func Enter():
	super()
	if animated_sprite:
		animated_sprite.play("idle")
	player.velocity = Vector2.ZERO

func Physics_Update(delta: float):
	if Engine.is_editor_hint() or not is_instance_valid(player):
		return
	
	handle_jump()
	handle_movement(delta)
	check_grounding()
	update_sprite_direction()
	
	super(delta)

func handle_jump():
	if Input.is_action_just_pressed("ui_accept") and can_jump():
		transition_to(&"jump")

func handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		transition_to(&"run")
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED * delta)

func check_grounding():
	if not player.is_on_floor():
		transition_to(&"fall")
	

func update_sprite_direction():
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0 and animated_sprite:
		animated_sprite.flip_h = direction < 0

func can_jump() -> bool:
	return player.is_on_floor()
