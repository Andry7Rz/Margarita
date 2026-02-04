extends AnimatableBody2D

@export var distancia = Vector2(350, 0) # Cuánto se moverá desde su origen
@export var velocidad = 1.0           # Tiempo en segundos para completar el trayecto

var tiempo = 5.5

func _physics_process(delta: float) -> void:
	# Usamos una función seno para que el movimiento sea suave (va y vuelve)
	tiempo += delta * velocidad
	
	# Calculamos el desplazamiento usando sin() para que sea cíclico
	# sin() devuelve valores entre -1 y 1
	var offset = (sin(tiempo) + 1.0) / 2.0 # Lo convertimos a rango 0.0 a 1.0
	
	# Aplicamos la posición basándonos en el inicio (usaremos una posición relativa)
	# Nota: Si mueves la plataforma en el editor, este script la moverá desde ese punto
	position = position.move_toward(start_position + (distancia * offset), 100 * delta)

# Guardamos la posición inicial al arrancar
@onready var start_position = position
