extends CharacterBody3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

# ======================
# VARIABLES GENERALES
# ======================

var mesh_base_position: Vector3
var bob_time := 0.0
var last_sin := 0.0

@export var step_delay := 0.2
var step_delay_timer := 0.0

@export var health_drain_per_second := 1
var health_timer := 0.0

# ======================
# MOVIMIENTO (MOMENTUM)
# ======================

const SPEED := 5.0
const ACCELERATION := 18.0
const FRICTION := 10.0
const JUMP_VELOCITY := 1.5

# ======================
# ROTACIÓN / CÁMARA
# ======================

const TURN_SPEED := 10.0
const ROTATION_STEP := 90.0
const ROTATION_TIME := 0.25

var target_rotation_y := 0.0
var rotation_tween: Tween

# ======================
# VIDA / TEAM
# ======================

const MAX_HEALTH := 100
var health := 100

@export var team: Team = Team.TEAM2
signal health_changed(current: int)
signal reset_game

# ======================
# NODOS
# ======================

@onready var step_sound_player: AudioStreamPlayer3D = $StepSoundPlayer

@onready var russian_skin: Node3D = $MeshInstance3D/RussianSkin
@onready var italian_skin: Node3D = $MeshInstance3D/ItalianSkin
@onready var japanese_skin: Node3D = $MeshInstance3D/JapaneseSkin
@onready var old_skin: Node3D = $MeshInstance3D/OldSkin

@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var dust_particles: CPUParticles3D = $MeshInstance3D/DustParticles

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var label_3d: Label3D = $Label3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

# ======================
# FUNCIONES DE TEAM
# ======================

func _hide_all_skins() -> void:
	old_skin.visible = false
	russian_skin.visible = false
	italian_skin.visible = false
	japanese_skin.visible = false

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

func get_team() -> Team:
	return team

# ======================
# VIDA
# ======================

func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)
	emit_signal("health_changed", health)

	if health <= 0:
		die()

func drain_health(amount: int) -> void:
	health -= amount
	health = max(health, 0)
	emit_signal("health_changed", health)

	if health <= 0:
		die()


func die():
	print("You are die")
	emit_signal("reset_game")

# ======================
# CÁMARA
# ======================

func rotate_camera(degrees: float) -> void:
	if rotation_tween and rotation_tween.is_running():
		return

	target_rotation_y += deg_to_rad(degrees)

	if rotation_tween:
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

# ======================
# READY
# ======================

func _ready():
	target_rotation_y = camera_pivot.rotation.y
	camera_3d.look_at(global_position, Vector3.UP)
	mesh_base_position = mesh.position

# ======================
# PHYSICS
# ======================

func _physics_process(delta: float) -> void:
	label_3d.text = str(get_team())

	# ---- Gravedad ----
	if not is_on_floor():
		velocity += get_gravity() * delta

	# ---- Salto ----
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# ---- Cámara ----
	if Input.is_action_just_pressed("camera_left"):
		rotate_camera(-ROTATION_STEP)
	elif Input.is_action_just_pressed("camera_right"):
		rotate_camera(ROTATION_STEP)

	# ---- Input movimiento ----
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")

	var basis := camera_pivot.global_transform.basis
	var forward := -basis.z
	var right := basis.x

	var desired_dir := (right * input_dir.x + forward * input_dir.y)
	desired_dir.y = 0.0

	if desired_dir.length() > 0:
		desired_dir = desired_dir.normalized()
		var desired_velocity := desired_dir * SPEED

		velocity.x = move_toward(velocity.x, desired_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, desired_velocity.z, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0.0, FRICTION * delta)

	# ---- Rotar mesh ----
	var horizontal_vel := Vector3(velocity.x, 0, velocity.z)
	var is_moving := horizontal_vel.length() > 0.05 and is_on_floor()

	if horizontal_vel.length() > 0.05:
		var target_yaw := atan2(-horizontal_vel.x, -horizontal_vel.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_yaw, TURN_SPEED * delta)

	# ---- Bobbing + polvo ----
	if is_moving:
		bob_time += delta * 40.0
		var current_sin := sin(bob_time)
		var y_offset := current_sin * 0.08

		if last_sin < 0.0 and current_sin >= 0.0:
			dust_particles.restart()

		mesh.position = mesh_base_position + Vector3(0, y_offset, 0)
		last_sin = current_sin
	else:
		bob_time = 0.0
		last_sin = 0.0
		mesh.position = mesh.position.lerp(mesh_base_position, 10.0 * delta)

	# ---- Sonido pasos ----
	if is_moving:
		step_delay_timer -= delta
		if step_delay_timer <= 0.0:
			step_sound_player.play()
			step_delay_timer = step_delay
	else:
		step_delay_timer = 0.0
	
	# ---- Drenaje de vida ----
	health_timer += delta
	if health_timer >= 1.0:
		drain_health(health_drain_per_second)
		health_timer = 0.0

	
	move_and_slide()
