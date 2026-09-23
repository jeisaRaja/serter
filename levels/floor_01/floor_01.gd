extends Node3D

@onready var entity := $Entity

var patrol_checkpoints: Array[Marker3D]


func _ready() -> void:
	_load_all_checkpoints()
	entity.patrol_checkpoints = patrol_checkpoints.duplicate()
	entity.start()


func _load_all_checkpoints():
	for marker in get_node("Checkpoints").get_children():
		if marker is Marker3D:
			patrol_checkpoints.append(marker)
