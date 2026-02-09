extends Area2D

@export var fuerza_disparo = 1420.0
@export var velocidad_rotacion = 2.0
@export var gravedad_prediccion = 980.0 

var player = null 
var jugador_en_rango = null # Para saber quién está cerca sin capturarlo aún
var puede_capturar = true

@onready var pivot = $Pivot
@onready var punta = $Pivot/Punta
@onready var linea = $Line2D

func _ready():
	# Conectamos entrada y salida
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited) # Nueva señal necesaria
	linea.visible = false 

func _process(delta):
	# REVISAR SI ENTRA AL CAÑÓN
	if jugador_en_rango != null and player == null and puede_capturar:
		# Cambiamos "tecla_z" por el nombre exacto de tu acción: "interactuar"
		if Input.is_action_just_pressed("interactuar"): 
			entrar_al_cañon(jugador_en_rango)

	# LÓGICA CUANDO YA ESTÁ DENTRO
	if player != null:
		var giro = Input.get_axis("ui_left", "ui_right")
		pivot.rotation += giro * velocidad_rotacion * delta
		pivot.rotation = clamp(pivot.rotation, deg_to_rad(-90), deg_to_rad(90))
		
		actualizar_trayectoria()
		
		if Input.is_action_just_pressed("ui_accept"): 
			disparar()

func _on_body_entered(body):
	if body.name == "Player":
		jugador_en_rango = body # Solo avisamos que está cerca

func _on_body_exited(body):
	if body == jugador_en_rango:
		jugador_en_rango = null # Si se aleja caminando, ya no puede entrar

func entrar_al_cañon(body):
	player = body
	player.enter_cannon(global_position)
	linea.visible = true

func disparar():
	if player:
		var direccion = Vector2.RIGHT.rotated(pivot.rotation)
		var impulso = direccion * fuerza_disparo
		
		player.launch_from_cannon(impulso)
		player.global_position = punta.global_position 
		
		player = null
		linea.visible = false
		
		# Cooldown para no entrar accidentalmente al salir
		puede_capturar = false 
		await get_tree().create_timer(0.5).timeout 
		puede_capturar = true

func actualizar_trayectoria():
	linea.clear_points()
	var pos_inicio = punta.global_position
	var vel_inicio = Vector2.RIGHT.rotated(pivot.rotation) * fuerza_disparo
	
	for i in range(30):
		var t = i * 0.05
		var pos_x = pos_inicio.x + vel_inicio.x * t
		var pos_y = pos_inicio.y + vel_inicio.y * t + 0.5 * gravedad_prediccion * t * t
		linea.add_point(to_local(Vector2(pos_x, pos_y)))
