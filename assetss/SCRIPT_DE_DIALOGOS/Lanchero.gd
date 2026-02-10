extends Area2D

@export var exclamation_mark : CanvasItem 


const TUTORIAL_PAPA = preload("uid://byvsf0ms4x5f8")



var is_player_close = false
var is_dialogo_active = false

func _ready():
	# Conexión de señales del DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogo_started)
	DialogueManager.dialogue_ended.connect(_on_dialogo_ended)
	
	
	if not exclamation_mark:
		exclamation_mark = get_node_or_null("ExclamationMark")
	
	if exclamation_mark:
		exclamation_mark.visible = false
		

func _process(_delta):
	# Cambiamos "abajo" por tu nueva acción "interactuar" (la tecla Z)
	if is_player_close and Input.is_action_just_pressed("interactuar") and not is_dialogo_active:
		DialogueManager.show_dialogue_balloon(TUTORIAL_PAPA)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") or body is CharacterBody2D:
		is_player_close = true
		if exclamation_mark:
			exclamation_mark.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador") or body is CharacterBody2D:
		is_player_close = false
		if exclamation_mark:
			exclamation_mark.visible = false

# --- ESTA PARTE BLOQUEA AL JUGADOR ---
func _on_dialogo_started(_resource):
	is_dialogo_active = true
	if exclamation_mark:
		exclamation_mark.visible = false
	
	# Buscamos al jugador y le decimos que se detenga
	var player = get_tree().get_first_node_in_group("jugador")
	if player and player.has_method("set_hablando"):
		player.set_hablando(true)

func _on_dialogo_ended(_resource):
	is_dialogo_active = false
	
	# Buscamos al jugador y le devolvemos el movimiento
	var player = get_tree().get_first_node_in_group("jugador")
	if player and player.has_method("set_hablando"):
		player.set_hablando(false)
		
	if is_player_close and exclamation_mark:
		exclamation_mark.visible = true
