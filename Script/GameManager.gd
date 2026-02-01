extends Node

var monedas = 0

# Señal para avisar a la interfaz que el número cambió
signal monedas_actualizadas(total)

func ganar_moneda():
	monedas += 1
	monedas_actualizadas.emit(monedas)
	print("Monedas totales: ", monedas)
