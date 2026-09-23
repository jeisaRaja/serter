extends State
class_name EntityStatePatrol

var _wait_timer: float = 0.0
var _waiting: bool = false


func enter(_data: Dictionary) -> void:
	var e := owner_node as Entity
	_waiting = false
	_wait_timer = 0.0
	_advance_to_checkpoint(e)


func physics_process(delta: float) -> void:
	var e := owner_node as Entity
	if _waiting:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_advance_to_checkpoint(e)
		return

	e.move_along_path(e.patrol_speed, delta)
	if e.navigation_agent.is_navigation_finished():
		_waiting = true
		_wait_timer = 2.0

	if e.chase_timer >= e.chase_trigger_duration:
		transition_requested.emit("chase", { })


func _advance_to_checkpoint(e: Entity) -> void:
	_waiting = false
	if e.patrol_checkpoints.is_empty():
		return
	e.go_to(e.patrol_checkpoints.pick_random().global_position)
