extends CanvasLayer

@onready var etiqueta_cant_pez: Label = $etiqueta_cant_pez

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	var game_manager_punt = get_node("%GameManagerPunt")
	game_manager_punt.cont_pez_actualizado.connect(_on_cont_pez_actualizado)

func _on_cont_pez_actualizado(cont_pez_actual: int) -> void:
	etiqueta_cant_pez.text = str(cont_pez_actual)
