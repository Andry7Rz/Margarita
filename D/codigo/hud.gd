extends CanvasLayer

# 1. Creamos una "caja" (Array) visible en el editor para guardar tus 6 fotos.
@export var texturas_vidas: Array[Texture2D]

# 2. Referencia al nodo que muestra la imagen
@onready var contador_visual = $ContadorImagen

func _ready() -> void:
	visible = true

func actualizar_contador(cantidad_vidas):
	# PROTECCIÓN:
	# Nos aseguramos de que el número no sea menor a 0 ni mayor a 5
	# clamp(valor, minimo, maximo) hace esto automáticamente.
	var indice_seguro = clamp(cantidad_vidas, 0, 5)
	
	# Cambiamos la textura actual por la que corresponde al número de vidas
	contador_visual.texture = texturas_vidas[indice_seguro]


func _on_player_cambio_vida(nueva_cantidad: Variant) -> void:
	pass # Replace with function body.
