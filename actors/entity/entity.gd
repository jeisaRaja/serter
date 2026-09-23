extends CharacterBody3D
class_name Entity

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_machine: StateMachine = $StateMachine
@onready var raycast: RayCast3D = $Senses/Eyes/Raycast
@onready var proximity: Area3D = $Senses/Proximity
@onready var raycast_timer: Timer = $Senses/Eyes/RaycastTimer

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var patrol_index: int = -1
var patrol_speed: float = 2.0
var patrol_checkpoints: Array[Marker3D]

var investigate_speed: float = 3.0

var chase_speed: float = 4.0

var player: CharacterBody3D = null
var can_see_player: bool = false
var base_vision_range: float = 20
var last_seen_player_position: Vector3 = Vector3.ZERO

var chase_trigger_duration: float = 1
var chase_timer: float = 0.0


func _ready() -> void:
	proximity.body_entered.connect(_on_body_entered)
	proximity.body_exited.connect(_on_body_exited)
	raycast.enabled = false


func set_player(p: CharacterBody3D):
	player = p


func _physics_process(delta: float) -> void:
	_check_line_of_sight()
	if can_see_player:
		chase_timer += delta
		last_seen_player_position = player.global_position
	else:
		chase_timer = 0

	state_machine.physics_process(delta)


func start():
	state_machine.start()


func go_to(pos: Vector3) -> void:
	# print("go to %v" % pos)
	navigation_agent.target_position = pos


func move_along_path(speed: float, delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity = velocity.move_toward(Vector3.ZERO, 20.0 * delta)
	else:
		var dir := (navigation_agent.get_next_path_position() - global_position).normalized()
		velocity = dir * speed
		if Vector2(dir.x, dir.z).length() > 0.01:
			rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 6.0 * delta)
	move_and_slide()


func _check_line_of_sight():
	if not player:
		can_see_player = false
		return

	var distance = global_position.distance_to(player.global_position)
	if distance > base_vision_range:
		can_see_player = false
		return

	# raycast.look_at(player.global_position)
	# var c = raycast.get_collider()
	# if c is Player:
	# 	can_see_player = true


func _on_body_entered(b: Node3D):
	if b is Player:
		player = b
		raycast.enabled = true


func _on_body_exited(b: Node3D):
	if b is Player:
		player = null
		raycast.enabled = false
