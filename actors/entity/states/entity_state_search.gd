class_name EntityStateSearch
extends State

const SEARCH_RADIUS: float = 8.0
const MAX_POINTS: int = 4
const MAX_SEARCH_TIME: float = 20.0
const REACH_DIST: float = 1.0
const LOOK_AROUND_TIME: float = 1.5

var points: Array[Vector3] = []
var index: int = 0
var start_time: float = 0.0
var _pausing: bool = false
var _pause_timer: float = 0.0


func enter(data: Dictionary = { }) -> void:
	var e := owner_node as Entity
	var origin: Vector3 = data.get("last_pos", e.global_position)
	points = _generate_points(origin)
	index = 0
	start_time = Time.get_ticks_msec() / 1000.0
	_pausing = false


func _generate_points(origin: Vector3) -> Array[Vector3]:
	var e := owner_node as Entity
	var result: Array[Vector3] = []

	result.append(origin)

	var map_rid := e.navigation_agent.get_navigation_map()
	for i in range(MAX_POINTS - 1):
		var random_point := NavigationServer3D.map_get_random_point(map_rid, 1, false)
		if random_point.distance_to(origin) <= SEARCH_RADIUS:
			result.append(random_point)

	return result


func physics_process(delta: float) -> void:
	var e := owner_node as Entity
	var now := Time.get_ticks_msec() / 1000.0

	if index >= points.size() or now - start_time > MAX_SEARCH_TIME:
		transition_requested.emit(&"patrol", { })
		return

	if _pausing:
		_pause_timer -= delta
		if _pause_timer <= 0.0:
			_pausing = false
			index += 1
		return

	var target: Vector3 = points[index]
	e.go_to(target)
	e.move_along_path(e.search_speed, delta)

	if e.global_position.distance_to(target) <= REACH_DIST:
		_pausing = true
		_pause_timer = LOOK_AROUND_TIME
		# TODO: play look-around animation here


func handle_event(event: StringName, data: Dictionary = { }) -> void:
	match event:
		&"player_spotted":
			transition_requested.emit(&"chase", data)
		&"noise_heard":
			if data.get("strength", 0.0) > 0.3:
				points = _generate_points(data.pos)
				index = 0
				_pausing = false
