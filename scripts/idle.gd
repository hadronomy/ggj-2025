extends State
class_name Idle

@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

const SPEED = 150.0

func Enter():
	animated_sprite.play("idle")

func Physics_Update(delta):
	if not player.is_on_floor():
		Transitioned.emit(self, "fall")
		
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		Transitioned.emit(self, "jump")
		
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		Transitioned.emit(self, "run")
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		
	player.move_and_slide()
	
