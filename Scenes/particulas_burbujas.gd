extends Node2D

func _ready() -> void:
	# Buscamos al hijo que sea de partículas
	var particles = get_child(0) # Toma el primer hijo que encuentre
	
	if particles and (particles is CPUParticles2D or particles is GPUParticles2D):
		particles.one_shot = true
		particles.emitting = true
		
		# Si es CPU, usamos la señal de fin para borrar la escena
		if particles is CPUParticles2D:
			particles.finished.connect(queue_free)
		else:
			# Si es GPU, esperamos su tiempo de vida
			await get_tree().create_timer(particles.lifetime).timeout
			queue_free()
	else:
		print("ERROR: El primer hijo no es un nodo de partículas o no existe.")
		queue_free()
