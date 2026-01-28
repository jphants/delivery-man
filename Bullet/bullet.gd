extends Area3D
class_name Bullet

@export var speed: float = 30.0
@export var lifetime: float = 3.0
@export var damage: int = 1

var direction: Vector3 = Vector3.ZERO
var shooter: Node3D = null

func _ready() -> void:
	# Autodestruir si no golpea nada
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	# Ignorar al que disparó
	if body == shooter:
		return

	# Si el objeto puede recibir daño
	if body.has_method("take_damage"):
		body.take_damage(damage)

	queue_free()
