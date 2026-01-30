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
@onready var gato_low: Node3D = $ModelSkins/gato_low
@onready var model_skins: Node3D = $ModelSkins

@export var team: Team

# 🎯 Target actual (player)
var target: Node3D = null

# 🎨 Colores por equipo
var team_colors := {
	Team.NONE: Color(1, 1, 1),
	Team.TEAM1: Color(0, 0, 1), # azul
	Team.TEAM2: Color(0, 1, 0), # verde
	Team.TEAM3: Color(1, 0, 0)  # rojo
}

# 🌊 Flotado y rotación
@export var float_height := 0.25
@export var float_speed := 2.0
@export var rotation_speed := 1.5  # radianes/segundo

var float_time := 0.0
var base_model_position: Vector3

func _ready() -> void:
	_update_light_color()

	# Guardamos la posición base del modelo
	base_model_position = model_skins.position

	# Para que no floten sincronizados
	float_time = randf() * TAU

	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# Flotado tipo item
	float_time += delta * float_speed
	model_skins.position.y = base_model_position.y + sin(float_time) * float_height

	# Rotación sobre su propio eje (Y)
	model_skins.rotate_y(rotation_speed * delta)

	if target and Input.is_action_just_pressed("interact"):
		interact_with_target()

func _update_light_color() -> void:
	if team in team_colors:
		omni_light_3d.light_color = team_colors[team]

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_body_exited(body: Node3D) -> void:
	if body == target:
		target = null

func interact_with_target() -> void:
	if target.has_method("take_damage"):
		target.take_damage(-10)
		print("💥 Daño aplicado al player (-10)")
	else:
		print("⚠️ El target no tiene take_damage()")

	audio_stream_player_3d.play()
	area_3d.queue_free()
	model_skins.visible = false
	await audio_stream_player_3d.finished
	queue_free()
