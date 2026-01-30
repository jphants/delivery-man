extends Control
const INTRO = preload("uid://b67j2lfcjk2q6")
const LEVEL_1 = preload("uid://cenl60q65u7y4")

@onready var image: TextureRect = $TextureRect

@export var images: Array[String] = [
"res://Storyline/Storyline_Casino0.jpeg",
"res://Storyline/Storyline_Casino1.jpeg",
"res://Storyline/Storyline_Casino2.jpeg",
"res://Storyline/Storyline_Casino3.jpeg",
"res://Storyline/Storyline_Casino4.jpeg",
"res://Storyline/Storyline_Casino5.jpeg",
"res://Storyline/Storyline_Casino6.jpeg",
"res://Storyline/Storyline_Casino7.jpeg",
"res://Storyline/Storyline_Casino8.jpeg",
"res://Storyline/Storyline_Casino9.jpeg"
]

@export var slide_time := 2.0 # segundos

var index := 0
var timer := 0.0
	

func _process(delta):
	timer += delta
	if timer >= slide_time:
		timer = 0.0
		index = (index + 1) % images.size()
		_show_image()

func _show_image():
	image.texture = load(images[index])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_show_image()
	DialogueManager.show_dialogue_balloon(INTRO)
	await DialogueManager.dialogue_ended
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("uid://cenl60q65u7y4")
	pass # Replace with function body.
