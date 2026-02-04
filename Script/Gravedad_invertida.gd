extends Area2D

func _ready():
	# Conectamos las señales por código o puedes hacerlo desde el panel de Nodos
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Verificamos si es el jugador buscando si tiene la función especial
	if body.has_method("change_gravity_orientation"):
		body.change_gravity_orientation(true) # Invertir gravedad

func _on_body_exited(body):
	if body.has_method("change_gravity_orientation"):
		body.change_gravity_orientation(false) # Volver a normal
