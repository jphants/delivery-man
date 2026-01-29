extends Control

const ENDING = preload("uid://ch8rtn10vd773")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.show_dialogue_balloon(ENDING)
	await DialogueManager.dialogue_ended
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
