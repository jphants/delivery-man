extends Node3D

@onready var area_3d: Area3D = $Area3D
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var cloth_sound: AudioStreamPlayer3D = $ClothSound

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@export var target_team: Team

# Diccionario para mapear equipos a colores
var team_colors := {
	Team.NONE: Color(1, 1, 1),
	Team.TEAM1: Color(0, 0, 1), # azul
	Team.TEAM2: Color(0, 1, 0), # verde
	Team.TEAM3: Color(1, 0, 0)  # rojo
}

func _ready() -> void:
	_update_light_color()

# Función que actualiza el color de la luz según el team
func _update_light_color() -> void:
	if target_team in team_colors:
		omni_light_3d.light_color = team_colors[target_team]

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("get_team"):
		
		var body_team = body.get_team()  # obtenemos el team actual del body
		if body_team != target_team:
			cloth_sound.play()
			print(body.name, "matches target team", target_team)
			body.set_team(target_team)
		else:
			print(body.name, "does not match target team", target_team)
		
