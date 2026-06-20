extends Node

# Usamos Vector2i (enteros) desde el principio para que Godot no se queje
var resoluciones = [
	Vector2i(640, 360),   # Nivel 0: Diminuta (Para ver si todo escala miniatura)
	Vector2i(854, 480),   # Nivel 1: SD 480p (Monitores muy viejos)
	Vector2i(1024, 768),  # Nivel 2: Monitor Cuadrado (4:3) - ¡Ideal para probar si salen las franjas negras!
	Vector2i(1280, 720),  # Nivel 3: HD 720p 
	Vector2i(1360, 720),  # Nivel 4: TU RESOLUCIÓN BASE (De donde partimos)
	Vector2i(1366, 768),  # Nivel 5: La laptop más común del mundo
	Vector2i(1600, 900),  # Nivel 6: HD+ (Monitores de oficina medianos)
	Vector2i(1920, 1080), # Nivel 7: Full HD 1080p (Pantallas estándar modernas)
	Vector2i(2560, 1440)  # Nivel 8: 2K (Por si te ponen un monitor gaming en el stand)
]

# Empezamos en tu resolución base, que ahora es el Nivel 4 en esta lista

var indice_actual = 2 # Empezamos en tu resolución base (Nivel 2)

func _input(event):
	# Verificamos que sea la pulsación de una tecla
	if event is InputEventKey and event.pressed:
		
		# Tecla 8: Achicar
		if event.keycode == KEY_8:
			indice_actual = max(0, indice_actual - 1)
			aplicar_resolucion()
			
		# Tecla 9: Agrandar
		elif event.keycode == KEY_9:
			indice_actual = min(resoluciones.size() - 1, indice_actual + 1)
			aplicar_resolucion()

func aplicar_resolucion():
	var nueva_resolucion = resoluciones[indice_actual]
	var ventana = get_window() # Obtenemos la ventana principal directamente
	
	# 1. Aseguramos que esté en modo ventana
	ventana.mode = Window.MODE_WINDOWED
	
	# 2. Forzamos el cambio de tamaño
	ventana.size = nueva_resolucion
	
	# 3. La centramos en tu monitor
	var tamaño_pantalla = DisplayServer.screen_get_size()
	ventana.position = (tamaño_pantalla - nueva_resolucion) / 2
	
	print("¡Éxito! Resolución cambiada a: ", nueva_resolucion)
