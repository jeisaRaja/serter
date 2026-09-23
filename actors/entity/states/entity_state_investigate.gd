class_name EntityStateInvestigate
extends State

const LOOK_DURATION: float = 2.0

var look_timer: float = 0.0
var target_strength: float = 0.0


func enter(data: Dictionary = { }) -> void:
	var e := owner_node as Entity
	e.go_to(data.get("pos", e.global_position))
	target_strength = data.get("strength", 1.0)
	look_timer = 0.0


func physics_process(delta: float) -> void:
	var e := owner_node as Entity
	e.move_along_path(e.investigate_speed, delta)

	if e.navigation_agent.is_navigation_finished():
		look_timer += delta
		if look_timer > LOOK_DURATION:
			transition_requested.emit(&"search", { "last_pos": e.global_position })


func handle_event(event: StringName, data: Dictionary = { }) -> void:
	var e := owner_node as Entity
	match event:
		&"player_spotted":
			transition_requested.emit(&"chase", data)
		&"noise_heard":
			var strength: float = data.get("strength", 0.0)
			if strength > target_strength:
				e.go_to(data.pos)
				target_strength = strength
				look_timer = 0.0
