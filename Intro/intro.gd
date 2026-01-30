extends Control

const INTRO = preload("uid://b67j2lfcjk2q6")
const LEVEL_1 = preload("uid://cenl60q65u7y4")

@onready var image: TextureRect = $TextureRect
@onready var intro_controller := $IntroController # ajusta el path si es distinto

@export var images: Array[String] = [
	"res://Storyline/Storyline_Casino0.jpeg",
	"res://Storyline/Storyline_Casino1.jpeg",
	"res://Storyline/Storyline_Casino2.jpeg",
	"res://Storyline/Storyline_Casino3.jpeg",
	"res://Storyline/Storyline_Casino4.jpeg",
	"res://Storyline/Storyline_Casino5.jpeg",
	"res://Storyline/Storyline_Casino6.jpeg",
	"res://Storyline/Storyline_Casino7.jpeg",
	"res://Storyline/Storyline_Casino9.jpeg",
	"res://Storyline/Storyline_Casino8.jpeg"
]

var index := 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		skip()

func skip():
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_packed(LEVEL_1)

func _ready() -> void:
	_show_image()

	# Conectamos la señal
	AnimationState.next_slide_requested.connect(_on_next_slide)

	DialogueManager.show_dialogue_balloon(INTRO)
	await DialogueManager.dialogue_ended

	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_packed(LEVEL_1)

func _on_next_slide(state: int) -> void:
	index = clamp(state, 0, images.size() - 1)
	_show_image()

func _show_image() -> void:
	image.texture = load(images[index])
