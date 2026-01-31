extends Area2D

# En Godot 4 se usa @export seguido de la definición de la variable
@export var Escena: String

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# En Godot 4, 'change_scene' cambió a 'change_scene_to_file'
		get_tree().change_scene_to_file("res://Scenes/Pueblo.tscn")
		
		
#get_tree().change_scene_to_file("res://Scenes/" + Escena + ".tscn")
