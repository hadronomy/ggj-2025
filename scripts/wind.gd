extends Area2D

@export_range(0.0, 10.0, 0.1, "or_greater") var strength_multiplier: float = 1.0:
	set(value):
		strength_multiplier = value
		update_configuration_warnings()

var affected: Array = []
var radius: float = 100.0

func _ready() -> void:
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius
	else:
		push_warning("Area2D requires a CircleShape2D for proper distance calculation. Using default radius.")

func _get_configuration_warnings() -> PackedStringArray:
	if not $CollisionShape2D or not $CollisionShape2D.shape is CircleShape2D:
		return ["This node requires a CircleShape2D collision shape for proper distance calculations"]
	return []

func _physics_process(delta: float) -> void:
	for body in affected:
		var character = body as CharacterBody2D
		if not is_instance_valid(character):
			affected.erase(body)
			continue
		
		var distance = character.global_position.distance_to(global_position)
		var distance_strength = clamp(1.0 - (distance / radius), 0.0, 1.0)
		
		# Get the Area2D's forward direction (global x-axis, accounts for rotation)
		var direction = global_transform.basis_xform(Vector2.UP)
		# Use direction directly for force in the node's facing direction
		var anti_gravity_force = direction * character.get_gravity().length() * strength_multiplier * distance_strength * delta
		
		character.velocity += anti_gravity_force

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not affected.has(body):
		affected.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and affected.has(body):
		affected.erase(body)
