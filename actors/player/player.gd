extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.5

@onready var head: Node3D = $Head


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	handle_movement(delta)


func handle_movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	var yaw = event.relative.x * MOUSE_SENSITIVITY
	var pitch = event.relative.y * MOUSE_SENSITIVITY
	rotate_y(deg_to_rad(-yaw))
	head.rotate_x(deg_to_rad(-pitch))
	head.rotation.x = clampf(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
