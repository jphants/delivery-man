extends Node3D

# Path editable desde el editor para asignar la señal
@export var sign_path: NodePath
@onready var sign: Node3D = get_node_or_null(sign_path)  # seguro si el path es incorrecto
@onready var ringtone: AudioStreamPlayer3D = $Ringtone  # asigna en editor
@export var start_mission_dialogue: DialogueResource  # Asignar en el editor

@export var mission_id: String = "first_steps"

var mission_taken := false
var player_inside := false

func _ready() -> void:
	if sign:
		sign.visible = false
	else:
		push_warning("Sign node is not assigned o path es invalid!")

	# ⚠️ NO intentar asignar loop en código
	# Loop debe activarse en el AudioStream desde el editor
	# ringtone.stream.loop = true  # ❌ esto no existe en Godot 4

func _process(delta: float) -> void:
	if player_inside and not mission_taken and Input.is_action_just_pressed("interact"):
		GameManager.add_task(mission_id)
		mission_taken = true
		if sign:
			sign.visible = false
		# Detener el ringtone al tomar la misión
		if ringtone and ringtone.playing:
			ringtone.stop()
		DialogueManager.show_dialogue_balloon(start_mission_dialogue)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not mission_taken:
		player_inside = true
		if sign:
			sign.visible = true
		if ringtone and not ringtone.playing:
			ringtone.play()  # Suena en loop automáticamente si el stream tiene Loop activado

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if sign:
			sign.visible = false
		if ringtone and ringtone.playing:
			ringtone.stop()  # Detener cuando el jugador sale
