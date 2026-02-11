extends Control

# Arrastra los botones a estas casillas en el Inspector
@export var boton_mundo_1: TextureButton
@export var boton_salir: TextureButton

func _ready() -> void:
	# Un pequeño respiro para que Godot termine de cargar lo visual
	await get_tree().process_frame
	
	if boton_mundo_1:
		boton_mundo_1.grab_focus()
		print("¡Botón Mundo 1 enfocado!")

# --- FUNCIONES DE LOS BOTONES ---

func _on_texture_button_mundo_1_pressed() -> void:
	print("Cargando Mundo 1...")
	get_tree().change_scene_to_file("res://Scenes/mundo_1.tscn")

func _on_texture_button_salir_pressed() -> void:
	print("Regresando al pueblo...")
	Global.volver_desde_menu = true # Le avisamos al script Global
	get_tree().change_scene_to_file("res://Scenes/Pueblo.tscn")
