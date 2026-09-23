extends Node
class_name StateMachine

@export var initial_state: State
var current: State
var states: Dictionary = { }


func _ready() -> void:
	for child in get_children():
		states[child.name.to_lower()] = child
		child.owner_node = owner
		child.transition_requested.connect(_on_transition_requested)
	print(states)


func physics_process(delta: float):
	current.physics_process(delta)


func start() -> void:
	if initial_state:
		_change_state(initial_state.name.to_lower(), { })


func _on_transition_requested(state_name: StringName, data: Dictionary):
	_change_state(state_name, data)


func _change_state(state_name: StringName, data: Dictionary) -> void:
	print("changing state to %s" % state_name)
	var key := String(state_name).to_lower()
	if not states.has(key):
		push_error("No state named: %s" % state_name)
		return
	if current == states[key]:
		return
	if current:
		current.exit()
	current = states[key]
	current.enter(data)
	Events.entity_state_changed.emit(state_name)
