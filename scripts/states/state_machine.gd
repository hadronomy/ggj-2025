@tool
extends Node
class_name StateMachine

## Emitted when state changes. Parameters: (previous_state: State, new_state: State)
signal state_changed(previous_state: State, new_state: State)

## Enable to see state machine debug information
@export var debug_mode := true:
	set(value):
		debug_mode = value
		update_configuration_warnings()

@export var initial_state: State:
	set(value):
		initial_state = value
		update_configuration_warnings()

var current_state: State
var states: Dictionary = {}

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not initial_state:
		warnings.append("Initial state must be set")
	
	var state_nodes = get_states()
	if state_nodes.is_empty():
		warnings.append("StateMachine needs child State nodes")
	else:
		var names = {}
		for state in state_nodes:
			var lower_name = state.name.to_lower()
			if names.has(lower_name):
				warnings.append("Duplicate state name (case-insensitive): %s" % state.name)
			names[lower_name] = true
	
	return warnings

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	states = _register_states()
	
	if initial_state:
		current_state = initial_state
		current_state.Enter()
		if debug_mode:
			print_rich("[color=green][StateMachine] Initial state: %s[/color]" % current_state.name)
	else:
		push_error("StateMachine missing initial state!")

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not current_state:
		return
	current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or not current_state:
		return
	current_state.Physics_Update(delta)

func _register_states() -> Dictionary:
	var registered_states = {}
	for state in get_states():
		var state_key = state.name.to_lower()
		if debug_mode:
			print_rich("[color=cyan][StateMachine] Registered state: %s (key: %s)[/color]" % [state.name, state_key])
		
		if registered_states.has(state_key):
			push_error("Duplicate state key: %s" % state_key)
			continue
			
		registered_states[state_key] = state
		state.Transitioned.connect(on_child_transition)
		if state.has_method("set_state_machine"):
			state.set_state_machine(self)
	return registered_states

func get_states() -> Array[State]:
	var found_states: Array[State] = []
	for child in get_children():
		if child is State:
			found_states.append(child)
	return found_states

func on_child_transition(old_state: State, new_state_name: StringName) -> void:
	if debug_mode:
		print_rich("[StateMachine] Received transition request from [%s] to [%s]" % [old_state.name, new_state_name])
	
	if old_state != current_state:
		push_error("Invalid transition request from non-active state: %s" % old_state.name)
		return
	
	var target_key = new_state_name.to_lower()
	var new_state = states.get(target_key)
	
	if not new_state:
		push_error("State '%s' does not exist! (searched as: %s)" % [new_state_name, target_key])
		return
	
	_transition_to(new_state)

func _transition_to(new_state: State) -> void:
	if not new_state or new_state == current_state:
		return
	
	if debug_mode:
		print_rich("[color=yellow][StateMachine] Transitioning from %s to %s[/color]" % [current_state.name, new_state.name])
	
	var previous_state = current_state
	if previous_state:
		previous_state.Exit()
	
	current_state = new_state
	current_state.Enter()
	
	state_changed.emit(previous_state, current_state)

func get_current_state_name() -> StringName:
	return current_state.name if current_state else &""

func transition_to(state_name: StringName) -> void:
	var target_key = state_name.to_lower()
	var target_state = states.get(target_key)
	if target_state:
		_transition_to(target_state)
	else:
		push_error("Attempted to transition to non-existent state: %s (searched as: %s)" % [state_name, target_key])

func reset() -> void:
	if initial_state:
		_transition_to(initial_state)
