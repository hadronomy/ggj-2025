extends State
class_name Run

@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D

const SPEED = 150.0

func Enter():
	animated_sprite.play("run")
	
func Physics_Update(delta: float):
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		Transitioned.emit(self, "jump")
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		player.velocity.x = direction * SPEED
		if player.is_on_floor():
			animated_sprite.play("run")
		else:
			Transitioned.emit(self, "fall")
		if player.velocity.x < 0:
			animated_sprite.set_flip_h(true)
		else: 
			if animated_sprite.flip_h:
				animated_sprite.set_flip_h(false)
	else:
		Transitioned.emit(self, "idle")
	
	player.move_and_slide()
