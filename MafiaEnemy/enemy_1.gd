extends CharacterBody3D

@onready var exclamation_sign: Node3D = $blockbench_export
@onready var raycast: RayCast3D = $RayCast3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var aim_line: CSGCylinder3D = $Aiming

const bullet_scene = preload("uid://dsuxhbxij7r3s")

@export var shoot_cooldown := 0.2
@export_range(0.0, 1.0) var accuracy := 0.75
@export var max_spread_deg := 10.0
@export var eye_height := 0
@export var detection_area: Area3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@export var team: Team = Team.TEAM1

var target: Node3D = null
var can_shoot := true

@onready var russian_skin: Node3D = $MeshInstance3D/RussianSkin
@onready var italian_skin: Node3D = $MeshInstance3D/ItalianSkin
@onready var japanese_skin: Node3D = $MeshInstance3D/JapaneseSkin

@onready var spotted_sound: AudioStreamPlayer3D = $SpottedSound
@onready var step_sound: AudioStreamPlayer3D = $StepSound
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound
# ======================
# Variables para sonidos de pasos
# ======================
@export var step_delay := 0.5  # tiempo entre pasos en segundos
var step_timer := 0.0
var is_moving := false

var previous_target: Node3D = null  # Para saber si cambió el target

# ======================
#  API
# ======================
func get_team() -> Team:
	return team

func update_aim_line(show: bool) -> void:
	if not aim_line:
		return

	if show and target:
		var start := raycast.global_position
		var end := target.global_position + Vector3.UP * eye_height

		var dir := end - start
		var length := dir.length()
		if length < 0.01:
			return

		aim_line.visible = true
		aim_line.height = length

		# Punto medio
		var mid := start + dir * 0.5

		# Construir basis donde Y apunta al target
		var up := dir.normalized()
		var right := up.cross(Vector3.FORWARD)
		if right.length() < 0.01:
			right = up.cross(Vector3.RIGHT)
		right = right.normalized()
		var forward := right.cross(up).normalized()

		var basis := Basis(right, up, forward)

		aim_line.global_transform = Transform3D(basis, mid)
	else:
		aim_line.visible = false


func _hide_all_skins() -> void:
	russian_skin.visible = false
	italian_skin.visible = false
	japanese_skin.visible = false


# ======================
#  LIFECYCLE
# ======================
func _ready() -> void:
	_hide_all_skins()
	exclamation_sign.visible = false
	raycast.exclude_parent = true
	raycast.enabled = true
	randomize()

	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	else:
		push_warning("Enemy sin detection_area asignada")
	
	match team:
		Team.TEAM1:
			russian_skin.visible = true
		Team.TEAM2:
			italian_skin.visible = true
		Team.TEAM3:
			japanese_skin.visible = true
		_:
			pass

func _on_detection_body_entered(body: Node3D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		target = body

func _on_detection_body_exited(body: Node3D) -> void:
	if body == target:
		target = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# ======================
	# Movimiento y pasos
	# ======================
	is_moving = velocity.length() > 0.1  # considera que se mueve si velocidad > 0.1
	is_moving = false
	if is_moving:
		step_timer -= delta
		if step_timer <= 0:
			if step_sound:
				step_sound.play()
			step_timer = step_delay
	else:
		step_timer = 0

	# ======================
	# Detección y disparo
	# ======================
	var sees_target := can_see_target()
	var can_aim := sees_target and target != null


	exclamation_sign.visible = sees_target
	update_aim_line(can_aim)


	# Sonar spotted_sound solo al adquirir target nuevo
	if sees_target:
		if target != previous_target:
			if spotted_sound:
				spotted_sound.play()
			previous_target = target

		try_shoot()
	else:
		previous_target = null  # Reset cuando pierde target

	move_and_slide()


func try_shoot() -> void:
	if not can_shoot or not bullet_scene or not target:
		return

	can_shoot = false

	var bullet: Bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = raycast.global_position

	var base_dir := (target.global_position - raycast.global_position).normalized()
	var final_dir := apply_accuracy(base_dir)
	base_dir.y = 0
	base_dir = base_dir.normalized()
	var target_yaw := atan2(-base_dir.x, -base_dir.z)
	mesh_instance_3d.rotation.y = target_yaw

	bullet.direction = final_dir
	bullet.shooter = self

	# Reproducir sonido de disparo
	if shoot_sound:
		shoot_sound.play()

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func apply_accuracy(direction: Vector3) -> Vector3:
	# Si acierta
	if randf() <= accuracy:
		return direction

	# Fallo: desviación aleatoria
	var spread_rad := deg_to_rad(max_spread_deg)

	var yaw := randf_range(-spread_rad, spread_rad)
	var pitch := randf_range(-spread_rad, spread_rad)

	var basis := Basis()
	basis = basis.rotated(Vector3.UP, yaw)
	basis = basis.rotated(Vector3.RIGHT, pitch)

	return (basis * direction).normalized()

func can_see_target() -> bool:
	if not target:
		return false

	var origin := global_position + Vector3.UP * eye_height
	var target_pos := target.global_position + Vector3.UP * eye_height

	raycast.global_position = origin
	raycast.target_position = raycast.to_local(target_pos)
	raycast.force_raycast_update()

	if not raycast.is_colliding():
		return true

	var collider := raycast.get_collider()

	if collider == target:
		return true

	if collider.is_ancestor_of(target):
		return true

	return false
