extends Node

signal next_slide_requested

var intro_animation_state: int = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func next_slide() -> void:
	intro_animation_state += 1
	emit_signal("next_slide_requested", intro_animation_state)
