extends Node

# Variables para controlar el tiempo
@export var tiempo_restante : float = 0.0
var esta_corriendo : bool = false

func _process(delta):
	# Si el timer está activo, restamos el tiempo que pasa (delta)
	if esta_corriendo:
		tiempo_restante -= delta
		
		# Si llega a cero, lo detenemos
		if tiempo_restante <= 0:
			tiempo_restante = 0
			esta_corriendo = false
			print("¡Se acabó el tiempo!")

# Esta función la usaremos para poner tiempo y empezar
func iniciar_timer(segundos: float):
	tiempo_restante = segundos
	esta_corriendo = true
