extends Area2D

@export var fuerza_disparo = 1200.0 # Aumenté un poco la fuerza
@export var velocidad_rotacion = 2.0
@export var gravedad_prediccion = 980.0 

var player = null 
var puede_capturar = true # Variable nueva para el cooldown

@onready var pivot = $Pivot
@onready var punta = $Pivot/Punta
@onready var linea = $Line2D

func _ready():
	body_entered.connect(_on_body_entered)
	linea.visible = false 

func _process(delta):
	if player != null:
		var giro = Input.get_axis("ui_left", "ui_right")
		pivot.rotation += giro * velocidad_rotacion * delta
		pivot.rotation = clamp(pivot.rotation, deg_to_rad(-90), deg_to_rad(90))
		
		actualizar_trayectoria()
		
		if Input.is_action_just_pressed("ui_accept"): 
			disparar()

func _on_body_entered(body):
	# SOLUCIÓN 1: Solo capturar si el cañón está "frío" (puede_capturar)
	if body.name == "Player" and player == null and puede_capturar: 
		player = body
		player.enter_cannon(global_position)
		linea.visible = true

func disparar():
	if player:
		var direccion = Vector2.RIGHT.rotated(pivot.rotation)
		var impulso = direccion * fuerza_disparo
		
		# Lanzamos al jugador
		player.launch_from_cannon(impulso)
		# Lo movemos visualmente a la punta para que no choque al salir
		player.global_position = punta.global_position 
		
		player = null
		linea.visible = false
		
		# --- SOLUCIÓN DEL BUCLE ---
		puede_capturar = false # Desactivamos la captura
		# Esperamos 0.5 segundos antes de poder capturar de nuevo
		await get_tree().create_timer(0.5).timeout 
		puede_capturar = true
		# --------------------------

func actualizar_trayectoria():
	# (El código de la línea se queda igual que antes)
	linea.clear_points()
	var pos_inicio = punta.global_position
	var vel_inicio = Vector2.RIGHT.rotated(pivot.rotation) * fuerza_disparo
	
	for i in range(30):
		var t = i * 0.05
		var pos_x = pos_inicio.x + vel_inicio.x * t
		var pos_y = pos_inicio.y + vel_inicio.y * t + 0.5 * gravedad_prediccion * t * t
		linea.add_point(to_local(Vector2(pos_x, pos_y)))
