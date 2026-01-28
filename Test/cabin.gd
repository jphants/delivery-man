extends Node3D

@onready var area_3d: Area3D = $Area3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@export var target_team: Team


func _ready() -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	# Verifica que el body tenga team y método setter
	if body.has_method("set_team"):
		print(body.name, "Team has been set")
		body.set_team(target_team)
