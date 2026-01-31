extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_body_entered(body: Node2D) -> void:
	# Si lo que entra tiene la función "enter_water", la activamos
	if body.has_method("enter_water"):
		body.enter_water()

func _on_body_exited(body: Node2D) -> void:
	# Si sale, le avisamos que ya no hay agua
	if body.has_method("exit_water"):
		body.exit_water()
