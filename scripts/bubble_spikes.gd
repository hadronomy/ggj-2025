extends Area2D

@onready var timer = $Timer

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is CharacterBody2D:
		print("body entered")
		body.queue_free()
		timer.start()

func _on_timer_timeout():
	print("revive")
	get_tree().reload_current_scene()

