extends State
class_name Jump

@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

const JUMP_VELOCITY = -300.0

func Enter():
	player.velocity.y = JUMP_VELOCITY
	animated_sprite.play("jump")
	Transitioned.emit(self, "fall")

func Physics_Update(delta):
	player.velocity += player.get_gravity() * delta
	
	if player.velocity.y > 0:
		Transitioned.emit(self, "fall")
		
	player.move_and_slide()
