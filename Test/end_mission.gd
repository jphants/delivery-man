extends Node3D

# Path editable desde el editor para asignar la señal
@export var sign_path: NodePath
@onready var sign: Node3D = get_node_or_null(sign_path)  # obtiene el nodo seguro
@onready var ringtone: AudioStreamPlayer3D = get_node_or_null("Ringtone")  # seguro si falta
const OUTRO = preload("uid://d38ufhm50tk8j")

@export var mission_id: String = "first_steps"

var player_inside := false
var completed := false

func _ready() -> void:
	# Inicializar sign invisible
	if sign:
		sign.visible = false
	else:
		push_warning("Sign node no está asignado o el path es inválido!")
		
	# Comprobar que ringtone exista
	if not ringtone:
		push_warning("Ringtone node no está asignado o el path es inválido!")

func _process(delta: float) -> void:
	# Interactuar para completar misión
	if player_inside and not completed and mission_id in GameManager.tasks \
	and Input.is_action_just_pressed("interact"):
		complete_mission()

func complete_mission() -> void:
	GameManager.complete_task(mission_id)
	completed = true
	if sign:
		sign.visible = false
	if ringtone and ringtone.playing:
		ringtone.stop()  # Detener al completar la misión
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Intro/outro.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and mission_id in GameManager.tasks and not completed:
		player_inside = true
		if sign:
			sign.visible = true
		if ringtone and not ringtone.playing:
			ringtone.play()  # Suena en loop si el AudioStream tiene Loop activado

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if sign:
			sign.visible = false
		if ringtone and ringtone.playing:
			ringtone.stop()  # Detener al salir
