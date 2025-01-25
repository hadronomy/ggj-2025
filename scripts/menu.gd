extends Control
@onready var main: VBoxContainer = $Main
@onready var options: VBoxContainer = $OptionsMenu
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.show()
	options.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Options menu back button
func _on_back_pressed() -> void:
	audio_player.play()
	main.show()
	options.hide()


func _on_options_pressed() -> void:
	audio_player.play()
	main.hide()
	options.show()


func _on_exit_pressed() -> void:
	audio_player.play()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_start_pressed() -> void:
	#var nodes = get_tree().root.get_children()
	#for node in nodes:
	#	node.queue_free()
	audio_player.play()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
