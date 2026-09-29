extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.5

@export var crouch_speed: float = 3.0

@onready var head: Node3D = $Head
@onready var footsteps_audio: AudioStreamPlayer3D = $Audio/Footsteps
@onready var flashlight: SpotLight3D = $Head/LeftHand/Flashlight/Flashlight

var is_moving: bool = false
var is_crouching: bool = false

var footstep_distance_threshold: float = 2
var min_movement_speed: float = 0.5
var distance_now: float = 0.0
var current_speed: float = SPEED

var stand_head_position: Vector3
var crouch_head_position: Vector3

var head_tween: Tween


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	stand_head_position = head.position
	crouch_head_position = Vector3(head.position.x, 0.2, head.position.z)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		flashlight.visible = !flashlight.visible


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_footsteps_noise(delta)


func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	_handle_crouch(delta)

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * (SPEED if not is_crouching else crouch_speed)
		velocity.z = direction.z * (SPEED if not is_crouching else crouch_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if velocity.length() > 0:
		is_moving = true
	else:
		is_moving = false

	move_and_slide()


func _handle_crouch(delta):
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

		var target_pos = crouch_head_position if is_crouching else stand_head_position

		# Kill previous tween if the player toggles mid-animation
		if head_tween and head_tween.is_running():
			head_tween.kill()

		head_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		head_tween.tween_property(head, "position", target_pos, 0.2)


func _handle_footsteps_noise(delta: float) -> void:
	var velocity_xy := Vector2(velocity.x, velocity.z)
	if velocity_xy.length() == 0:
		distance_now = 0
		return

	distance_now += velocity_xy.length() * delta
	if distance_now >= footstep_distance_threshold:
		distance_now = 0.0
		Events.noise_emitted.emit(NoiseEvent.new(global_position, 1.0, NoiseEvent.Type.FOOTSTEP))
		footsteps_audio.play()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	var yaw = event.relative.x * MOUSE_SENSITIVITY
	var pitch = event.relative.y * MOUSE_SENSITIVITY
	rotate_y(deg_to_rad(-yaw))
	head.rotate_x(deg_to_rad(-pitch))
	head.rotation.x = clampf(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
