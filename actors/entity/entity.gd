extends CharacterBody3D
class_name Entity

@export var navigation_agent: NavigationAgent3D
@onready var state_machine: StateMachine = $StateMachine
@onready var vision: EntityVision = $Senses/Vision
@onready var perception: EntityPerception = $Senses/Perception

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var patrol_index: int = -1
var patrol_speed: float = 2.0
var patrol_checkpoints: Array[Marker3D]

var investigate_speed: float = 3.0

var chase_speed: float = 4.0

var search_speed: float = 1.0

var player: CharacterBody3D = null
var can_see_player: bool = false
var base_vision_range: float = 20
var last_seen_player_position: Vector3 = Vector3.ZERO

var chase_trigger_duration: float = 1
var chase_timer: float = 0.0


func _ready() -> void:
	vision.entity = self
	perception.entity = self

	perception.confidence_crossed_chase.connect(_on_confidence_chase)
	perception.suspicion_crossed_investigate.connect(_on_suspicion_investigate)


func _on_confidence_chase(pos: Vector3) -> void:
	state_machine.handle_event(&"player_spotted", { "pos": pos })


func _on_suspicion_investigate(pos: Vector3) -> void:
	state_machine.handle_event(&"suspicious", { "pos": pos })


func set_player_ref(p: Player):
	player = p


func _physics_process(delta: float) -> void:
	state_machine.physics_process(delta)


func activate():
	state_machine.start()


func set_checkpoints(new_checkpoints: Array[Marker3D]) -> void:
	patrol_checkpoints = new_checkpoints


func go_to(pos: Vector3) -> void:
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
