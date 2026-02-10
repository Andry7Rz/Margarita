extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
# Esta función se activa sola cuando algo toca el área
	# Preguntamos: "¿Eres tú el jugador?"
	if body.is_in_group("jugador"):
		# Si es el jugador, buscamos su función de recibir daño
		if body.has_method("recibir_daño"):
			body.recibir_daño()
			print("¡El jugador ha tocado el pincho!")
