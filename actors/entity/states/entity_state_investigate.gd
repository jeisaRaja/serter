extends State
class_name EntityStateInvestigate

var look_timer = 0.0


func enter(data: Dictionary) -> void:
	var e = owner_node as Entity
	if data.get("pos"):
		e.go_to(data["pos"])


func physics_process(delta: float) -> void:
	var e = owner_node as Entity
	e.move_along_path(e.investigate_speed, delta)

	if e.navigation_agent.is_navigation_finished():
		look_timer += delta
		if look_timer > 2.0:
			transition_requested.emit("search", { })
