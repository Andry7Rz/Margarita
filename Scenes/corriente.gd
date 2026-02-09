extends Area2D

@export var velocidad_subida: float = 300.0 # Ajusta este número a tu gusto

func _physics_process(_delta: float) -> void:
	var cuerpos = get_overlapping_bodies()
	
	for cuerpo in cuerpos:
		if cuerpo is CharacterBody2D:
			# Forzamos a que su velocidad hacia arriba sea siempre la misma
			# Usamos un valor negativo para ir hacia arriba
			cuerpo.velocity.y = -velocidad_subida
