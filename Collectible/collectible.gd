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
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var team: Team

var team_colors := {
	Team.NONE: Color(1, 1, 1),
	Team.TEAM1: Color(0, 0, 1), # azul
	Team.TEAM2: Color(0, 1, 0), # verde
	Team.TEAM3: Color(1, 0, 0)  # rojo
}

# 🎯 Target actual (player)
var target: Node3D = null

func _ready() -> void:
	_update_light_color()
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func _update_light_color() -> void:
	if team in team_colors:
		omni_light_3d.light_color = team_colors[team]

func _process(delta: float) -> void:
	if target and Input.is_action_just_pressed("interact"):
		interact_with_target()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		# opcional debug
		# print("Player detectado:", body.name)

func _on_body_exited(body: Node3D) -> void:
	if body == target:
		target = null
		# opcional debug
		# print("Player salió del área")

func interact_with_target() -> void:
	if target.has_method("take_damage"):
		target.take_damage(-10)
		print("💥 Daño aplicado al player (-10)")
	else:
		print("⚠️ El target no tiene take_damage()")
	audio_stream_player_3d.play()
	await audio_stream_player_3d.finished
	queue_free()
