extends CharacterBody3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var label_3d: Label3D = $Label3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const ROTATION_STEP := 90.0
const ROTATION_TIME := 0.25 # segundos
const MAX_HEALTH := 100

var health := 100
var target_rotation_y := 0.0
var rotation_tween: Tween

@export var team: Team = Team.TEAM2
signal health_changed(current: int)

func die():
	print("You are die")

func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)

	print(health)
	emit_signal("health_changed", health)

	if health <= 0:
		die()

func set_team(new_team: Team) -> void:
	team = new_team

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

func _physics_process(delta: float) -> void:
	label_3d.text = str(get_team())
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

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

	move_and_slide()
