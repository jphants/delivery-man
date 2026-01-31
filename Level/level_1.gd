extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var respawn_point: Node3D = $Spawnpoint
const REMINDER = preload("uid://bl1g58nvth17b")

func _ready():
	# Conectamos el signal correctamente usando Callable
	player.connect("reset_game", Callable(self, "_on_player_reset_game"))
	DialogueManager.show_dialogue_balloon(REMINDER)
	player.take_damage(-10000)
	Engine.max_fps = 30

func _on_player_reset_game():
	player.set_health(100)
	respawn()

func respawn():
	# Movemos al jugador al respawn point
	player.global_transform.origin = respawn_point.global_transform.origin
	# Reseteamos velocidad si es CharacterBody3D
	player.velocity = Vector3.ZERO
	print("Player respawned!")
