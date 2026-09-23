extends State
class_name EntityStateChase

const LOSE_SIGHT_GRACE: float = 4.0
const CATCH_DISTANCE: float = 1.2

var player_last_known_pos: Vector3
var player_last_known_velocity: Vector3
var lose_sight_timer: float


func enter(data: Dictionary) -> void:
	var e = owner_node as Entity
	# player_last_known_pos = data["pos"]
	# lose_sight_timer = 0.0
	# e.go_to(player_last_known_pos)


func physics_process(delta: float) -> void:
	var e := owner_node as Entity
	if not e.player:
		transition_requested.emit("patrol", { })
	else:
		chase_player()
		e.move_along_path(e.chase_speed, delta)


func chase_player():
	var e := owner_node as Entity
	if e.player:
		e.go_to(e.player.global_position)
