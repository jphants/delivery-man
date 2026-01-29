extends CharacterBody3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

var mesh_base_position: Vector3
var bob_time := 0.0

@export var step_delay := 0.2 # segundos antes de sonar
var step_delay_timer := 0.

@onready var step_sound_player: AudioStreamPlayer3D = $StepSoundPlayer

#TEAM MESHES

@onready var russian_skin: Node3D = $MeshInstance3D/RussianSkin
@onready var italian_skin: Node3D = $MeshInstance3D/ItalianSkin
@onready var japanese_skin: Node3D = $MeshInstance3D/JapaneseSkin
@onready var old_skin: Node3D = $MeshInstance3D/OldSkin
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var label_3d: Label3D = $Label3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

const MESH_Y_OFFSET := +PI / 2

const TURN_SPEED := 10.0

const SPEED := 5.0
const JUMP_VELOCITY := 2.5
const DIVE_VELOCITY := 3.5
const ROTATION_STEP := 90.0
const ROTATION_TIME := 0.25 # segundos
const MAX_HEALTH := 100

var health := 100
var target_rotation_y := 0.0
var rotation_tween: Tween

@export var team: Team = Team.TEAM2
signal health_changed(current: int)

signal reset_game  # Signal que se emitirá al morir

func die():
	print("You are die")
	emit_signal("reset_game")  # Emitimos el signal

func _hide_all_skins() -> void:
	old_skin.visible = false
	russian_skin.visible = false
	italian_skin.visible = false
	japanese_skin.visible = false


func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)

	print(health)
	emit_signal("health_changed", health)

	if health <= 0:
		die()

func set_team(new_team: Team) -> void:
	team = new_team
	cpu_particles_3d.emitting = true
	_hide_all_skins()

	match team:
		Team.TEAM1:
			russian_skin.visible = true
		Team.TEAM2:
			italian_skin.visible = true
		Team.TEAM3:
			japanese_skin.visible = true
		_:
			pass


func rotate_camera(degrees: float) -> void:
	if rotation_tween and rotation_tween.is_running():
		return

	target_rotation_y += deg_to_rad(degrees)

	# Evita tweens superpuestos
	if rotation_tween and rotation_tween.is_running():
		rotation_tween.kill()

	rotation_tween = create_tween()
	rotation_tween.set_trans(Tween.TRANS_SINE)
	rotation_tween.set_ease(Tween.EASE_IN_OUT)

	rotation_tween.tween_property(
		camera_pivot,
		"rotation:y",
		target_rotation_y,
		ROTATION_TIME
	)

	rotation_tween.finished.connect(func():
		camera_3d.look_at(global_position, Vector3.UP)
	)

func get_team() -> Team:
	return team

func _ready():
	target_rotation_y = camera_pivot.rotation.y
	camera_3d.look_at(global_position, Vector3.UP)
	mesh_base_position = mesh.position


func _physics_process(delta: float) -> void:
	label_3d.text = str(get_team())

	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y += JUMP_VELOCITY
	# Input de cámara
	if Input.is_action_just_pressed("camera_left"):
		rotate_camera(-ROTATION_STEP)
	elif Input.is_action_just_pressed("camera_right"):
		rotate_camera(ROTATION_STEP)

	# Movimiento relativo a la cámara
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")

	if input_dir.length() > 0:
		var basis := camera_pivot.global_transform.basis
		var forward := -basis.z
		var right := basis.x

		var move_dir := (right * input_dir.x + forward * input_dir.y).normalized()
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# 🔥 ROTAR SOLO EL MESH HACIA DONDE SE MUEVE
	var horizontal_vel := Vector3(velocity.x, 0, velocity.z)
	var is_moving := horizontal_vel.length() > 0.05 and is_on_floor()

	if horizontal_vel.length() > 0.05:
		var target_yaw := atan2(-horizontal_vel.x, -horizontal_vel.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_yaw, TURN_SPEED * delta)

	# Bobbing del mesh
	if is_moving:
		bob_time += delta * 40.0 # velocidad del temblor
		var y_offset := sin(bob_time) * 0.08
		mesh.position = mesh_base_position + Vector3(0, y_offset, 0)
	else:
		bob_time = 0.0
		mesh.position = mesh.position.lerp(mesh_base_position, 10.0 * delta)

	# 🔊 Sonido de pasos
	if is_moving:
		step_delay_timer -= delta
		if step_delay_timer <= 0.0:
			step_sound_player.play()
			step_delay_timer = step_delay
	else:
		step_delay_timer = 0.0 # Reinicia cuando no se mueve

	move_and_slide()
