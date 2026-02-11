extends Control

# Este nodo se conecta automáticamente al AudioStreamPlayer que agregaste
@onready var musica_menu = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# 1. Configuración inicial del volumen (muy bajo)
	musica_menu.volume_db = -40 
	
	# 2. Si no activaste "Autoplay" en el inspector, lo iniciamos por código:
	if not musica_menu.playing:
		musica_menu.play()
	
	# 3. Creamos la transición suave (Fade In)
	# Sube de -40dB a 0dB (volumen normal) en 2 segundos
	var tween = create_tween()
	tween.tween_property(musica_menu, "volume_db", 0.0, 2.0).set_trans(Tween.TRANS_SINE)

func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://M/scenes/menu.tscn")
