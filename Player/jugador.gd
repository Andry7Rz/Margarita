extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_category("Movimiento Base")
@export var max_speed = 220.0 
@export var acceleration = 1400.0
@export var friction = 1500.0
@export var air_friction = 800.0

@export_category("Salto Celeste")
@export var jump_force = -300.0 
@export var gravity_multiplier = 1.0
@export var fall_multiplier = 1.8 
@export var coyote_duration = 0.15 
@export var jump_buffer_duration = 0.1 

@export_category("Dash")
@export var dash_speed = 600.0
@export var dash_duration = 0.15

@export_category("Mecánicas de Pared")
@export var wall_jump_force = Vector2(400, -350)
@export var wall_slide_speed = 100.0
@export var wall_climb_speed = -150.0
@export var max_stamina = 40.0

@export_category("Mecánicas de Agua")
@export var water_speed_multiplier = 0.6
@export var water_float_force = -80.0
@export var water_sink_speed = 100.0

# --- VARIABLES INTERNAS ---
@onready var sprite = $AnimatedSprite2D 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dashing = false
var can_dash = true
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var stamina = max_stamina
var is_in_water = false












func enter_water():
	print("JUGADOR: ¡He entrado al agua!") # <--- Esto confirmará si la señal llega
	is_in_water = true
	velocity.y *= 0.3
	can_dash = true 

func exit_water():
	print("JUGADOR: He salido del agua")
	is_in_water = false









# --- VARIABLES DE CÁMARA ---
@onready var camera = $Camera2D # Ajusta la ruta a tu cámara
var zoom_normal = Vector2(3, 3)
var zoom_amplio = Vector2(1, 1) # Menos de 1 significa más lejos


func ajustar_zoom(objetivo: Vector2):
	# Creamos un Tween para que el cambio sea suave
	var tween = create_tween()
	# Transición de 1 segundo con suavizado de entrada y salida
	tween.tween_property(camera, "zoom", objetivo, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


























# --- NUEVO: VARIABLE DE GRAVEDAD ---
var gravity_direction = 1.0 # 1.0 es suelo abajo, -1.0 es suelo arriba

func _physics_process(delta: float) -> void:
	if is_dashing:
		sprite.play("dash_1")
		move_and_slide()
		return 

	# 1. GESTIÓN DE ESTADOS Y TIMERS
	if is_on_floor():
		coyote_timer = coyote_duration
		can_dash = true
		stamina = max_stamina
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_duration
	else:
		jump_buffer_timer -= delta

	_apply_gravity(delta)

	if not is_in_water:
		_handle_wall_mechanics(delta)

	if (jump_buffer_timer > 0 and coyote_timer > 0) or (is_in_water and Input.is_action_just_pressed("ui_accept")):
		# Multiplicamos la fuerza de salto por la dirección de la gravedad
		velocity.y = jump_force * gravity_direction # <--- CAMBIO
		jump_buffer_timer = 0
		coyote_timer = 0 

	if not is_on_wall() or is_on_floor() or is_in_water: 
		_handle_horizontal_move(delta)

	if Input.is_action_just_pressed("ui_focus_next") and can_dash: 
		start_dash()

	_update_animations()
	move_and_slide()

# --- FUNCIÓN PARA CAMBIAR LA GRAVEDAD (LLAMADA DESDE EL AREA) ---
func change_gravity_orientation(inverted: bool):
	if inverted:
		gravity_direction = -1.0
		up_direction = Vector2.DOWN # Le dice al CharacterBody que el techo es suelo
		sprite.flip_v = true # Girar el sprite de cabeza
	else:
		gravity_direction = 1.0
		up_direction = Vector2.UP
		sprite.flip_v = false

# --- FUNCIONES DE APOYO ---

func _update_animations():
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		sprite.flip_h = (direction < 0)

	if is_on_wall_only() and not is_in_water:
		sprite.play("wall_jump")
	elif is_on_floor():
		if direction != 0:
			sprite.play("run")
		else:
			sprite.play("idle")
	else:
		# Comparamos velocidad relativa a la dirección de la gravedad
		if velocity.y * gravity_direction < 0: # <--- CAMBIO
			sprite.play("jump")
		else:
			sprite.play("fall")

func _apply_gravity(delta):
	if is_in_water:
		# En el agua, invertimos la flotación también si es necesario, 
		# pero por simplicidad aquí solo afectamos la gravedad estándar
		velocity.y = move_toward(velocity.y, water_float_force * gravity_direction, 600 * delta)
		# Ajustar lógica de hundirse según dirección... (simplificado para este ejemplo)
	elif not is_on_floor() and not is_on_wall():
		# Verificar dirección de caída
		var going_up = (velocity.y * gravity_direction) < 0 
		var mult = gravity_multiplier if going_up else fall_multiplier
		
		# Aplicamos gravedad en la dirección correcta
		velocity.y += gravity * mult * delta * gravity_direction # <--- CAMBIO

func _handle_horizontal_move(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	var final_speed = max_speed * water_speed_multiplier if is_in_water else max_speed
	var final_accel = acceleration * water_speed_multiplier if is_in_water else acceleration
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * final_speed, final_accel * delta)
	else:
		var current_friction = friction
		if is_in_water:
			current_friction = friction * 2.0
		elif not is_on_floor():
			current_friction = air_friction
		velocity.x = move_toward(velocity.x, 0, current_friction * delta)

func _handle_wall_mechanics(delta):
	if is_on_wall_only():
		var wall_normal = get_wall_normal()
		var direction_input = Input.get_axis("ui_left", "ui_right")
		var is_pushing = (direction_input != 0 and sign(direction_input) == -sign(wall_normal.x))

		# Invertimos la lógica de "abajo" y "arriba" para las paredes
		var going_down_wall = (velocity.y * gravity_direction) > 0
		
		if is_pushing:
			# Si estamos cayendo por la pared
			if going_down_wall:
				velocity.y = min(abs(velocity.y), wall_slide_speed) * sign(velocity.y)
				# Esto asegura que no resbale más rápido de lo permitido, sea arriba o abajo

			# Escalada (simplificada para invertir gravedad)
			if Input.is_action_pressed("ui_up") and stamina > 0:
				velocity.y = wall_climb_speed * gravity_direction # <--- CAMBIO
				stamina -= 45 * delta
			elif not Input.is_action_pressed("ui_down"):
				# Fricción estática en pared
				# velocity.y = 0  <-- A veces es mejor dejar un pequeño deslizamiento
				stamina -= 10 * delta 
		
		if jump_buffer_timer > 0:
			velocity.x = wall_normal.x * wall_jump_force.x
			# Invertimos la fuerza Y del salto de pared
			velocity.y = wall_jump_force.y * gravity_direction # <--- CAMBIO
			jump_buffer_timer = 0
			stamina -= 10

func start_dash():
	is_dashing = true
	can_dash = false
	
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si no presiona nada, dash hacia donde mira
	if dir == Vector2.ZERO:
		dir.x = -1.0 if sprite.flip_h else 1.0 
	
	# El dash no se ve afectado por la gravedad, así que sigue igual
	velocity = dir.normalized() * dash_speed
	sprite.play("dash_1")
	
	await get_tree().create_timer(dash_duration).timeout
	
	is_dashing = false
	velocity = velocity * 0.5
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# --- AÑADIR AL SCRIPT DEL JUGADOR ---

func enter_cannon(cannon_position):
	velocity = Vector2.ZERO
	global_position = cannon_position
	# Desactivamos colisiones y visuales temporalmente
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.visible = false
	
	ajustar_zoom(zoom_amplio) # <--- SE ALEJA
	velocity = Vector2.ZERO
	# Un estado especial para que no se mueva con las teclas
	set_physics_process(false) 

func launch_from_cannon(impulse_vector):
	# Reactivamos todo
	$CollisionShape2D.set_deferred("disabled", false)
	sprite.visible = true
	set_physics_process(true)
	ajustar_zoom(zoom_normal) # <--- VUELVE A LA NORMALIDAD
	
	# ¡BUM! Aplicamos la fuerza
	velocity = impulse_vector
	
	# Pequeño truco: forzamos el estado de salto para que la gravedad actúe bien
	# (Si usas máquinas de estado, cambia a estado FALL o JUMP aquí)
