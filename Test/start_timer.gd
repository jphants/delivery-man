extends Node3D

@onready var sign: Node3D = $Sign

@export var mission_id: String = "first_steps"

var mission_taken := false
var player_inside := false


func _ready() -> void:
	sign.visible = false


func _process(delta: float) -> void:
	if player_inside \
	and not mission_taken \
	and Input.is_action_just_pressed("interact"):
		GameManager.add_task(mission_id)
		mission_taken = true
		sign.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not mission_taken:
		player_inside = true
		sign.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		sign.visible = false
