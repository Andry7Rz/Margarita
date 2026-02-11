extends Node

var cont_pez = 0
# Definimos la meta aquí para que sea fácil de cambiar luego
const META_PECES = 10

@onready var etiqueta_cant_pez: Label = $etiqueta_cant_pez

signal cont_pez_actualizado(cont_pez_actual:int)

func increm_pez_cont():
	cont_pez += 1
	cont_pez_actualizado.emit(cont_pez)
	print("llevas"+str(cont_pez))
	print("Mas 1 pez rescatado")
	# --- AQUÍ ESTÁ EL CAMBIO ---
	# Verificamos si ya llegamos a la meta
	if cont_pez >= META_PECES:
		finalizar_juego()

# Creamos una función nueva para manejar la victoria
func finalizar_juego():
	print("¡Felicidades! Has recolectado todos los peces.")
	
	# OPCIÓN A: Pausar el juego y mostrar mensaje en consola
	#get_tree().paused = true 
	
	# OPCIÓN B: Cambiar a una escena de "Victoria" (Descomenta y usa tu ruta)
	get_tree().change_scene_to_file("res://D/UI/screen_win.tscn")
