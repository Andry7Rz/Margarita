extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_category("Movimiento Base")
@export var max_speed = 220.0 
@export var acceleration = 1400.0
@export var friction = 1500.0
@export var air_friction = 800.0

# --- NUEVOS: NODOS DE AUDIO ---
@onready var sonido_salto = $SonidoSalto
@onready var sonido_dash = $SonidoDash
@onready var sonido_daño = $SonidoDaño

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

# --- SEÑALES DEL JUGADOR Y EL ENTORNO ---
signal cambio_vida(nueva_cantidad)

# --- VARIABLES INTERNAS ---
@onready var sprite = $AnimatedSprite2D 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dashing = false
var can_dash = true
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var stamina = max_stamina
var is_in_water = false
var gravity_direction = 1.0 
var esta_hablando = false
var vidas_maximas = 5
var vidas_actuales = 5
var es_invulnerable = false

# --- VARIABLES DE CÁMARA ---
@onready var camera = $Camera2D 
var zoom_normal = Vector2(3, 3)
var zoom_amplio = Vector2(1, 1)

# --- FUNCIÓN READY (Modificada para el Marker) ---
func _ready() -> void:
	# --- LÓGICA DE POSICIONAMIENTO ---
	if Global.volver_desde_menu:
		# Buscamos el Marker2D llamado "PuntoAparicionMenu" en la escena actual
		var marcador = get_tree().current_scene.find_child("PuntoAparicionMenu")
		if marcador:
			global_position = marcador.global_position
		# Resetear bandera
		Global.volver_desde_menu = false
	
	# --- LÓGICA ORIGINAL ---
	vidas_actuales = vidas_maximas
	await get_tree().create_timer(0.1).timeout
	cambio_vida.emit(vidas_actuales)

# --- PROCESO FÍSICO (Sin cambios) ---
func _physics_process(delta: float) -> void:
	if esta_hablando:
		_apply_gravity(delta)
		_update_animations()
		move_and_slide()
		return 

	if is_dashing:
		sprite.play("dash_1")
		move_and_slide()
		return 

	if is_on_floor():
		coyote_timer = coyote_duration
		can_dash = true
		stamina = max_stamina
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("saltar"):
		jump_buffer_timer = jump_buffer_duration
	else:
		jump_buffer_timer -= delta

	_apply_gravity(delta)

	if not is_in_water:
		_handle_wall_mechanics(delta)

	if (jump_buffer_timer > 0 and coyote_timer > 0) or (is_in_water and Input.is_action_just_pressed("saltar")):
		velocity.y = jump_force * gravity_direction
		jump_buffer_timer = 0
		coyote_timer = 0 
		if sonido_salto:
			sonido_salto.pitch_scale = randf_range(0.9, 1.1)
			sonido_salto.play()

	if not is_on_wall() or is_on_floor() or is_in_water: 
		_handle_horizontal_move(delta)

	if Input.is_action_just_pressed("dash") and can_dash: 
		start_dash()

	_update_animations()
	move_and_slide()

# --- FUNCIONES DE APOYO ---
func set_hablando(valor: bool):
	esta_hablando = valor
	if valor:
		velocity = Vector2.ZERO

func start_dash():
	is_dashing = true
	can_dash = false
	if sonido_dash:
		sonido_dash.play()
	var dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	if dir == Vector2.ZERO:
		dir.x = -1.0 if sprite.flip_h else 1.0 
	velocity = dir.normalized() * dash_speed
	sprite.play("dash_1")
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)

func _update_animations():
	var direction = Input.get_axis("izquierda", "derecha")
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
		if velocity.y * gravity_direction < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")

func _apply_gravity(delta):
	if is_in_water:
		velocity.y = move_toward(velocity.y, water_float_force * gravity_direction, 600 * delta)
	elif not is_on_floor() and not is_on_wall():
		var going_up = (velocity.y * gravity_direction) < 0 
		var mult = gravity_multiplier if going_up else fall_multiplier
		velocity.y += gravity * mult * delta * gravity_direction

func _handle_horizontal_move(delta):
	var direction = Input.get_axis("izquierda", "derecha")
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
	if is_on_wall_only() and not is_dashing:
		var wall_normal = get_wall_normal()
		var direction_input = Input.get_axis("izquierda", "derecha")
		var is_pushing = (direction_input != 0 and sign(direction_input) == -sign(wall_normal.x))
		if is_pushing:
			if Input.is_action_pressed("arriba") and stamina > 0:
				velocity.y = wall_climb_speed * gravity_direction
				stamina -= 60 * delta 
			elif Input.is_action_pressed("abajo"):
				velocity.y = wall_slide_speed * 2 * gravity_direction
			else:
				if stamina > 0:
					velocity.y = 0 
					stamina -= 15 * delta 
				else:
					velocity.y = wall_slide_speed * gravity_direction
		if Input.is_action_just_pressed("saltar"):
			velocity.x = wall_normal.x * wall_jump_force.x
			velocity.y = wall_jump_force.y * gravity_direction
			stamina -= 5 
			can_dash = true
			if sonido_salto:
				sonido_salto.play()

func change_gravity_orientation(inverted: bool):
	if inverted:
		gravity_direction = -1.0
		up_direction = Vector2.DOWN
		sprite.flip_v = true
	else:
		gravity_direction = 1.0
		up_direction = Vector2.UP
		sprite.flip_v = false

func enter_water():
	is_in_water = true
	velocity.y *= 0.3
	can_dash = true 

func exit_water():
	is_in_water = false

func ajustar_zoom(objetivo: Vector2):
	var tween = create_tween()
	tween.tween_property(camera, "zoom", objetivo, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func enter_cannon(cannon_position):
	velocity = Vector2.ZERO
	global_position = cannon_position
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.visible = false
	ajustar_zoom(zoom_amplio)
	set_physics_process(false) 

func launch_from_cannon(impulse_vector):
	$CollisionShape2D.set_deferred("disabled", false)
	sprite.visible = true
	set_physics_process(true)
	ajustar_zoom(zoom_normal)
	velocity = impulse_vector

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass

func recibir_daño():
	if es_invulnerable:
		return
	if vidas_actuales > 0:
		vidas_actuales -= 1
		sonido_daño.play()
		cambio_vida.emit(vidas_actuales)
		es_invulnerable = true
		modulate.a = 0.5 
		await get_tree().create_timer(1.5).timeout
		es_invulnerable = false
		modulate.a = 1.0 
		if vidas_actuales <= 0:
			morir()

func morir():
	get_tree().change_scene_to_file("res://D/UI/screen_lose.tscn")
