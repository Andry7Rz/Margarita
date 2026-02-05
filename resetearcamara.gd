extends Area2D

func _on_body_entered(body):
	# Si el objeto que entró es el jugador y tiene la función de reset
	if body.has_method("resetear_zoom_jugador"):
		body.resetear_zoom_jugador()
