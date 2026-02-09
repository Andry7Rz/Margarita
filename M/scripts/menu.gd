extends Control

# Este nodo se conecta automáticamente al AudioStreamPlayer que agregaste
@onready var musica_menu = $AudioStreamPlayer

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

# --- BOTONES DEL MENÚ ---

func _on_jugar_pressed() -> void:
	# Al cambiar de escena, la música del menú se detendrá sola
	get_tree().change_scene_to_file("res://Scenes/Pueblo.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/lobby.tscn")

func _on_opciones_pressed() -> void:
	# Aquí podrías abrir un panel de ajustes más adelante
	pass 

func _on_salir_pressed() -> void:
	get_tree().quit()
