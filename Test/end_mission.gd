extends Node3D

@onready var sign: Node3D = $Sign

@export var mission_id: String = "first_steps"

var player_inside := false
var completed := false


func _ready() -> void:
	sign.visible = false


func _process(delta: float) -> void:
	if player_inside \
	and not completed \
	and mission_id in GameManager.tasks \
	and Input.is_action_just_pressed("interact"):
		complete_mission()


func complete_mission() -> void:
	GameManager.complete_task(mission_id)
	completed = true
	sign.visible = false
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") \
	and mission_id in GameManager.tasks \
	and not completed:
		player_inside = true
		sign.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		sign.visible = false
