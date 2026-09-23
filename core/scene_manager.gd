extends Node

@export var initial_level: PackedScene = preload("res://levels/floor_01/floor_01.tscn")

var current_level: Node3D = null
var level_holder: Node3D = null
var player: CharacterBody3D = null
var entity: Entity = null


func change_level(level_scene: PackedScene, spawn_marker_name: StringName) -> void:
	if current_level:
		current_level.queue_free()
		current_level = null

	var new_level := level_scene.instantiate()
	level_holder.add_child(new_level)
	current_level = new_level
