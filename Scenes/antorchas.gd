extends PointLight2D

func _process(_delta):
	# Cambia la energía aleatoriamente un poco cada frame
	energy = randf_range(1.2, 1.6)
