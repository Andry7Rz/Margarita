extends Node

var cont_pez = 0

@onready var etiqueta_cant_pez: Label = $etiqueta_cant_pez

signal cont_pez_actualizado(cont_pez_actual:int)

func increm_pez_cont():
	cont_pez += 1
	cont_pez_actualizado.emit(cont_pez)
	print("llevas"+str(cont_pez))
	print("Mas 1 pez rescatado")
