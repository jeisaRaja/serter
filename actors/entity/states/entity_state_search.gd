extends State
class_name EntityStateSearch

var search_position: Vector3 = Vector3.ZERO


func enter(data: Dictionary) -> void:
	if data.get("target_position"):
		search_position = data["target_position"]


func physics_process(_delta: float) -> void:
	pass
