extends State
class_name Run

@export var player: CharacterBody2D
@export var animated_sprite: AnimatedSprite2D
@export var coyote_timer: CoyoteTimer

const SPEED = 150.0
var was_on_floor := true

func Enter():
	animated_sprite.play("run")
	was_on_floor = player.is_on_floor()
	
func Physics_Update(delta: float):
	if Input.is_action_just_pressed("ui_accept") and (player.is_on_floor() || !coyote_timer.is_stopped()):
		Transitioned.emit(self, "jump")
	
	var direction := Input.get_axis("move_left", "move_right")
	var current_on_floor = player.is_on_floor()
	
	if direction:
		player.velocity.x = direction * SPEED
		animated_sprite.flip_h = player.velocity.x < 0
		
		if current_on_floor:
			animated_sprite.play("run")
		else:
			if was_on_floor:
				coyote_timer.start()
			if coyote_timer.is_stopped():
				Transitioned.emit(self, "fall")
	else:
		player.velocity.x = 0
		if current_on_floor:
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "fall")
	
	was_on_floor = current_on_floor
	player.move_and_slide()
