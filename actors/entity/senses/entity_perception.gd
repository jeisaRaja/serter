class_name EntityPerception
extends Node

signal confidence_crossed_chase(pos: Vector3)
signal suspicion_crossed_investigate(pos: Vector3)

const SUSPICION_DECAY: float = 8.0
const CONFIDENCE_DECAY: float = 15.0
const INVESTIGATE_THRESHOLD: float = 40.0
const CHASE_THRESHOLD_BASE: float = 70.0
const CHASE_THRESHOLD_JUMPY: float = 40.0
const JUMPY_WINDOW: float = 15.0

var entity: Entity = null

var suspicion: float = 0.0
var confidence: float = 0.0
var last_seen_pos: Vector3
var last_seen_time: float = -999.0


func _process(delta: float) -> void:
	suspicion = max(0.0, suspicion - SUSPICION_DECAY * delta)
	confidence = max(0.0, confidence - CONFIDENCE_DECAY * delta)

	if last_seen_pos == null:
		return

	var chase_threshold := _get_dynamic_chase_threshold()

	if confidence >= chase_threshold:
		confidence_crossed_chase.emit(last_seen_pos)
		confidence = 0.0
	elif suspicion >= INVESTIGATE_THRESHOLD:
		suspicion_crossed_investigate.emit(last_seen_pos)
		suspicion = 0.0


func on_noise(strength: float, pos: Vector3) -> void:
	suspicion += strength * 8.0
	confidence += strength * 1.0
	last_seen_pos = pos
	_clamp_meters()


func on_vision(strength: float, is_clear: bool, pos: Vector3) -> void:
	if strength <= 0.0:
		return
	if is_clear:
		suspicion += strength * 3.0
		confidence += strength * 10.0
	else:
		suspicion += strength * 5.0
		confidence += strength * 4.0
	last_seen_pos = pos
	last_seen_time = Time.get_ticks_msec() / 1000.0
	_clamp_meters()


func _get_dynamic_chase_threshold() -> float:
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_seen_time < JUMPY_WINDOW:
		return CHASE_THRESHOLD_JUMPY
	return CHASE_THRESHOLD_BASE


func _clamp_meters() -> void:
	suspicion = clamp(suspicion, 0.0, 100.0)
	confidence = clamp(confidence, 0.0, 100.0)
