extends Area2D

# Usamos export para poder elegir la escena desde el Inspector fácilmente
@export_file("*.tscn") var escena_destino: String
func _on_body_entered(body: Node2D) -> void:
	# 1. Ignorar el mapa por completo
	if body is TileMapLayer or "TileMap" in body.name:
		return # Esto hace que el código se detenga aquí y no imprima nada
	
	# 2. Si llegó aquí, es que NO es el mapa
	print("¡ALGO QUE NO ES EL MAPA ENTRÓ!: ", body.name)
	
	if body.is_in_group("jugador") or body is CharacterBody2D:
		print("¡ES EL JUGADOR! Cambiando escena...")
		get_tree().change_scene_to_file(escena_destino)
