extends CanvasLayer # O el tipo de nodo que sea tu raíz

@onready var timer = $ContadorTimer
@onready var etiqueta = $EtiquetaTiempo

func _ready() -> void:
	visible = true

func _process(_delta):
	# Obtenemos el tiempo restante, usamos ceil para redondear hacia arriba 
	# (así empieza en el número exacto y no en uno menos)
	var tiempo_restante = int(ceil(timer.time_left))
	
	# Lo convertimos a texto para el Label
	etiqueta.text = str(tiempo_restante)

# Esta función se conecta desde la señal del Timer
func _on_contador_timer_timeout():
	# Aquí pones la lógica para terminar el nivel
	terminar_nivel()

func terminar_nivel():
	# Cambia a la escena de "Game Over" o al siguiente nivel
	get_tree().change_scene_to_file("res://D/UI/screen_lose.tscn")
