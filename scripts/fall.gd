extends State
class_name Fall

@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

const SPEED = 150.0

func Enter():
	animated_sprite.play("fall")

func Physics_Update(delta):
	player.velocity += player.get_gravity() * delta
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		player.velocity.x = direction * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	
	if player.velocity.x < 0:
			animated_sprite.set_flip_h(true)
	else: 
		if animated_sprite.flip_h:
			animated_sprite.set_flip_h(false)
	
	if player.is_on_floor():
		Transitioned.emit(self, "idle")

	player.move_and_slide()
