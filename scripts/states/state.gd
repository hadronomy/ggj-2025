@tool
extends Node
class_name State

## Emitted when requesting a state transition (State: source, StringName: target)
signal Transitioned(state: State, new_state_name: StringName)

@export var player: CharacterBody2D:
	set(v):
		player = v
		update_configuration_warnings()

## Enable to see state transition debug prints
@export var debug_transitions := false

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not player:
		warnings.append("Player must be assigned")
	if name == "State":
		warnings.append("State should be renamed to reflect its purpose (e.g., 'Idle', 'Run')")
	
	var parent = get_parent()
	if not parent is StateMachine:
		warnings.append("States must be direct children of a StateMachine node")
	
	return warnings

## Called when entering the state
func Enter() -> void:
	if debug_transitions:
		print_rich("[color=green]ENTER[/color] ", name)
	if Engine.is_editor_hint():
		return

## Called when exiting the state
func Exit() -> void:
	if debug_transitions:
		print_rich("[color=red]EXIT[/color] ", name)
	if Engine.is_editor_hint():
		return

## Called every process frame
func Update(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

## Called every physics frame
func Physics_Update(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	player.move_and_slide()

## Safe transition method with parent verification
func transition_to(target_state: StringName) -> void:
	if Engine.is_editor_hint():
		return
	
	if debug_transitions:
		print_rich("[color=yellow]%s → %s[/color]" % [name, target_state])
	
	# Verify we have a valid StateMachine parent
	var parent = get_parent()
	if not parent is StateMachine:
		push_error("State %s is not in a StateMachine!" % name)
		return
	
	Transitioned.emit(self, target_state)
