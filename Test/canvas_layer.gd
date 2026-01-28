extends CanvasLayer
@onready var health_label: Label = $Control/Health

@onready var label: Label = $Control/Label
@export var show_time := 3.0

func _ready() -> void:
	label.visible = false

	GameManager.task_added.connect(_on_task_added)
	GameManager.task_completed.connect(_on_task_completed)

	# Conectarse al player
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health) # valor inicial

func _on_health_changed(current_health: int) -> void:
	health_label.text = "❤️ Vida: %d" % current_health


func _on_task_added(task_id: String) -> void:
	show_message("🆕 Nueva misión:\n" + task_id)

func _on_task_completed(task_id: String) -> void:
	show_message("✅ Misión completada:\n" + task_id)

func show_message(text: String) -> void:
	label.text = text
	label.visible = true
	await get_tree().create_timer(show_time).timeout
	label.visible = false
