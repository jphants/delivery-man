extends Area3D
class_name Bullet   # 👈 ESTO ES CLAVE

@export var speed: float = 30.0
@export var lifetime: float = 3.0

var direction: Vector3 = Vector3.ZERO
var shooter: Node3D = null


func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body == shooter:
		return
	queue_free()
