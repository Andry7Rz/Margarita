extends Area2D

@onready var game_manager_punt: Node = %GameManagerPunt
@onready var sonido_pez = $SonidoPez
@onready var imagen = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	game_manager_punt.increm_pez_cont()
	
	if body is CharacterBody2D:
		# 1. DESAPARECER AL INSTANTE (Visual)
		imagen.visible = false 
		
		# 2. DESACTIVAR COLISIÓN (Para no cobrar dos veces)
		set_deferred("monitoring", false)
		sonido_pez.play()
		await sonido_pez.finished
		queue_free()
