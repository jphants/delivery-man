extends StaticBody3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@onready var area_3d: Area3D = $Area3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var blockbench_export: Node3D = $blockbench_export

@export var team: Team

var team_colors := {
	Team.NONE: Color(1, 1, 1),
	Team.TEAM1: Color(0, 0, 1), # azul
	Team.TEAM2: Color(0, 1, 0), # verde
	Team.TEAM3: Color(1, 0, 0)  # rojo
}

var player_inside := false

func _ready() -> void:
	_update_light_color()
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func _update_light_color() -> void:
	if team in team_colors:
		omni_light_3d.light_color = team_colors[team]

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		placeholder_interact()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false

func placeholder_interact() -> void:
	self.visible = false
	print("Interact placeholder ejecutado 🚧")
