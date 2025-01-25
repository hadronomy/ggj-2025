extends State
class_name Fall

@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var coyote_timer: CoyoteTimer

const SPEED = 150.0

func Enter():
	animated_sprite.play("fall")

func Physics_Update(delta):
	player.velocity += player.get_gravity() * delta
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	
	if player.velocity.x < 0:
			animated_sprite.set_flip_h(true)
	else: 
		if animated_sprite.flip_h:
			animated_sprite.set_flip_h(false)
	
	var previous_on_floor = player.is_on_floor()
	if player.is_on_floor():
		Transitioned.emit(self, "idle")
	
	player.move_and_slide()
