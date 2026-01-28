extends CharacterBody3D

@onready var exclamation_sign: Node3D = $blockbench_export
@onready var raycast: RayCast3D = $RayCast3D

const bullet_scene = preload("uid://dsuxhbxij7r3s")

@export var shoot_cooldown := 0.2
@export_range(0.0, 1.0) var accuracy := 0.75
@export var max_spread_deg := 10.0
@export var eye_height := 0

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@export var team: Team = Team.TEAM1

var target: Node3D = null
var can_shoot := true


# ======================
#  API
# ======================
func get_team() -> Team:
	return team


# ======================
#  LIFECYCLE
# ======================
func _ready() -> void:
	exclamation_sign.visible = false
	raycast.exclude_parent = true
	raycast.enabled = true
	randomize()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var sees_target := can_see_target()
	exclamation_sign.visible = sees_target

	if sees_target:
		try_shoot()

	move_and_slide()

func try_shoot() -> void:
	if not can_shoot or not bullet_scene or not target:
		return

	can_shoot = false

	var bullet: Bullet = bullet_scene.instantiate()

	# 1️⃣ Añadir primero al árbol
	get_tree().current_scene.add_child(bullet)

	# 2️⃣ Ahora sí: transform global válido
	bullet.global_position = raycast.global_position

	# Dirección base hacia el target
	var base_dir := (target.global_position - raycast.global_position).normalized()

	# Aplicar accuracy
	var final_dir := apply_accuracy(base_dir)

	bullet.direction = final_dir
	bullet.shooter = self

	# Cooldown
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

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		target = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == target:
		target = null
