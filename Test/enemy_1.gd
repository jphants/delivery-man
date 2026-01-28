extends CharacterBody3D

@onready var exclamation_sign: Node3D = $blockbench_export
@onready var raycast: RayCast3D = $RayCast3D

enum Team {
	NONE,
	TEAM1,
	TEAM2,
	TEAM3
}

@export var team: Team = Team.TEAM1

var target: Node3D = null


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


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	exclamation_sign.visible = can_see_target()

	move_and_slide()


# ======================
#  AREA DETECTION
# ======================
func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.has_method("get_team") and body.get_team() != team:
		target = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == target:
		target = null


# ======================
#  VISION (RAYCAST)
# ======================
func can_see_target() -> bool:
	if not target:
		return false

	var eye_height := 0
	var origin := global_position + Vector3.UP * eye_height
	var target_pos := target.global_position + Vector3.UP * eye_height

	raycast.global_position = origin
	raycast.target_position = raycast.to_local(target_pos)
	raycast.force_raycast_update()

	# Nada bloquea la visión
	if not raycast.is_colliding():
		return true

	var collider := raycast.get_collider()

	# Golpeó directamente al target
	if collider == target:
		return true

	# Golpeó a un collider hijo del target
	if collider.is_ancestor_of(target):
		return true

	return false
