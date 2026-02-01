extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_category("Movimiento Base")
@export var max_speed = 220.0 #250
@export var acceleration = 1400.0
@export var friction = 1500.0
@export var air_friction = 800.0

@export_category("Salto Celeste")
@export var jump_force = -300.0 #350
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

func _physics_process(delta: float) -> void:
	if is_dashing:
		# Mientras dasheas, forzamos la animación dash_1
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
		velocity.y = jump_force
		jump_buffer_timer = 0
		coyote_timer = 0 

	if not is_on_wall() or is_on_floor() or is_in_water: 
		_handle_horizontal_move(delta)

	if Input.is_action_just_pressed("ui_focus_next") and can_dash: 
		start_dash()

	# ACTUALIZAR ANIMACIONES (Solo si no estamos dasheando)
	_update_animations()

	move_and_slide()

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
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")

func _apply_gravity(delta):
	if is_in_water:
		velocity.y = move_toward(velocity.y, water_float_force, 600 * delta)
		if velocity.y > water_sink_speed:
			velocity.y = water_sink_speed
	elif not is_on_floor() and not is_on_wall():
		var mult = fall_multiplier if velocity.y > 0 else gravity_multiplier
		velocity.y += gravity * mult * delta

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

		if is_pushing:
			if velocity.y < wall_climb_speed:
				velocity.y = wall_climb_speed
			if velocity.y > 0:
				velocity.y = min(velocity.y, wall_slide_speed)
			if Input.is_action_pressed("ui_up") and stamina > 0:
				velocity.y = wall_climb_speed
				stamina -= 45 * delta
			elif not Input.is_action_pressed("ui_down"):
				velocity.y = 0 
				stamina -= 10 * delta 
		
		if jump_buffer_timer > 0:
			velocity.x = wall_normal.x * wall_jump_force.x
			velocity.y = wall_jump_force.y
			jump_buffer_timer = 0
			stamina -= 10

func start_dash():
	is_dashing = true
	can_dash = false
	
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir == Vector2.ZERO:
		dir.x = -1.0 if sprite.flip_h else 1.0 
	
	velocity = dir.normalized() * dash_speed
	
	# Cambiamos a la animación de dash inmediatamente
	sprite.play("dash_1")
	
	await get_tree().create_timer(dash_duration).timeout
	
	is_dashing = false
	velocity = velocity * 0.5

func enter_water():
	is_in_water = true
	velocity.y *= 0.3
	can_dash = true 

func exit_water():
	is_in_water = false
	if velocity.y < 0:
		velocity.y = jump_force * 0.5
