extends Node2D

func _ready() -> void:
	# Buscamos CUALQUIER tipo de partículas (CPU o GPU)
	var particles = null
	
	for child in get_children():
		if child is CPUParticles2D or child is GPUParticles2D:
			particles = child
			break
	
	if particles:
		# Configuramos para que no fallen las señales
		particles.one_shot = true
		particles.emitting = true
		
		# Si el nodo es CPUParticles2D, conectamos la señal de borrado
		if particles is CPUParticles2D:
			particles.finished.connect(queue_free)
		else:
			# Si es GPU, esperamos el tiempo de vida y borramos
			await get_tree().create_timer(particles.lifetime).timeout
			queue_free()
	else:
		# Si sigues viendo este mensaje, es que la escena está VACÍA
		print("DEBUG: La escena BurbujasDash no tiene hijos. ¡Revisa el árbol de nodos!")
		queue_free()
