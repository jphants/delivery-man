extends Node3D

@onready var area_3d: Area3D = $Area3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@export var target_team: Team = Team.TEAM1


func _ready() -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	# Verifica que el body tenga team y método setter
	print(body.name)
	if body.has_method("set_team"):
		body.set_team(target_team)
