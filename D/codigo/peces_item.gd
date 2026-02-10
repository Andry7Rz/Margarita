extends Area2D

@onready var game_manager_punt: Node = %GameManagerPunt

func _on_body_entered(body: Node2D) -> void:
	game_manager_punt.increm_pez_cont()
	queue_free()
