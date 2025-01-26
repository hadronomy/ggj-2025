extends Node

@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

var current_scene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = get_tree().root.get_child(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func change_scene(path_scene):
	_defered_change_scene(path_scene)

func _defered_change_scene(path_scene):
	SceneManager.animation_player.play("fade_in")
	await SceneManager.animation_player.animation_finished

	#get_tree().root.remove_child(current_scene)
	current_scene.queue_free()
	var new_scene = load(path_scene).instantiate()
	current_scene = new_scene
	get_tree().root.add_child(new_scene)
	SceneManager.animation_player.play("fade_out")