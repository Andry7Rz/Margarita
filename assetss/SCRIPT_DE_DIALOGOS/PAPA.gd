extends Area2D

# Esta línea permite que elijas la escena desde el Inspector haciendo clic
@export_file("*.tscn") var escena_destino: String

func _on_body_entered(body: Node2D) -> void:
	# Esto nos dirá en consola TODO lo que pase por el área
	print("ENTIDAD DETECTADA: ", body.name)
	
	# Intentamos detectar al jugador de tres formas diferentes para estar seguros
	if body.is_in_group("jugador") or body is CharacterBody2D or "Player" in body.name:
		print("¡JUGADOR CONFIRMADO! Iniciando cambio de escena...")
		
		if escena_destino != "":
			get_tree().change_scene_to_file(escena_destino)
		else:
			print("ERROR: No arrastraste la escena del menú al Inspector del Area2D")
