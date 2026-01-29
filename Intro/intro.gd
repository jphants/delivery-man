extends Control
const INTRO = preload("uid://b67j2lfcjk2q6")
const LEVEL_1 = preload("uid://cenl60q65u7y4")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.show_dialogue_balloon(INTRO)
	await DialogueManager.dialogue_ended
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("uid://cenl60q65u7y4")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
