extends Node3D

@export var building_scene: PackedScene

func _ready():
	spawn(Vector3(10, 0, 5))
	spawn(Vector3(20, 0, 5))

func spawn(pos):
	var b = building_scene.instantiate()
	b.position = pos
	print("Edificio")
	add_child(b)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
