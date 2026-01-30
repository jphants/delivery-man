extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var rain: AudioStreamPlayer = $Rain

# ======================
# CONFIGURACIÓN
# ======================

@export var normal_amount := 0.6
@export var heavy_amount := 1.3

@export var normal_volume_db := -15.0
@export var heavy_volume_db := -7.0

@export var change_interval_min := 4.0
@export var change_interval_max := 8.0

@export var transition_speed := 0.5  # qué tan suave cambia

# ======================
# ESTADO
# ======================

var target_amount := 1.0
var target_volume := -15.0
var change_timer := 0.0

func _ready() -> void:
	randomize()

	target_amount = normal_amount
	target_volume = normal_volume_db

	gpu_particles_3d.amount_ratio = normal_amount
	rain.volume_db = normal_volume_db

	rain.play()

	_reset_timer()

func _process(delta: float) -> void:
	change_timer -= delta

	if change_timer <= 0.0:
		_pick_new_rain_state()
		_reset_timer()

	# Transiciones suaves
	gpu_particles_3d.amount_ratio = lerp(
		gpu_particles_3d.amount_ratio,
		target_amount,
		transition_speed * delta
	)

	rain.volume_db = lerp(
		rain.volume_db,
		target_volume,
		transition_speed * delta
	)

# ======================
# LÓGICA
# ======================

func _pick_new_rain_state() -> void:
	var heavy := randf() < 0.35  # 35% de probabilidad de lluvia fuerte

	if heavy:
		target_amount = heavy_amount
		target_volume = heavy_volume_db
	else:
		target_amount = normal_amount
		target_volume = normal_volume_db

func _reset_timer() -> void:
	change_timer = randf_range(change_interval_min, change_interval_max)
