extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export_category("Movimiento Base")
@export var max_speed = 250.0
@export var acceleration = 1400.0
@export var friction = 1500.0
@export var air_friction = 800.0

@export_category("Salto Celeste")
@export var jump_force = -350.0
@export var gravity_multiplier = 1.0
@export var fall_multiplier = 1.8 
@export var coyote_duration = 0.15 
@export var jump_buffer_duration = 0.1 

@export_category("Dash")
@export var dash_speed = 600.0
@export var dash_duration = 0.15

@export_category("Mecánicas de Pared")
@export var wall_jump_force = Vector2(400, -350) # Impulso hacia afuera y arriba
@export var wall_slide_speed = 100.0             # Velocidad máxima al deslizar
@export var wall_climb_speed = -150.0            # Velocidad al trepar
@export var max_stamina = 40.0                  # Resistencia total

# --- VARIABLES INTERNAS ---
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dashing = false
var can_dash = true
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var stamina = max_stamina

func _physics_process(delta: float) -> void:
	if is_dashing:
		move_and_slide()
		return 

	# 1. GESTIÓN DE ESTADOS Y TIMERS
	if is_on_floor():
		coyote_timer = coyote_duration
		can_dash = true
		stamina = max_stamina # Recargar stamina en el suelo
	else:
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_duration
	else:
		jump_buffer_timer -= delta

	# 2. GRAVEDAD
	_apply_gravity(delta)

	# 3. LÓGICA DE PARED (Wall Jump / Slide / Climb)
	_handle_wall_mechanics(delta)

	# 4. SALTO NORMAL (Suelo)
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_force
		jump_buffer_timer = 0
		coyote_timer = 0 

	# 5. MOVIMIENTO HORIZONTAL
	if not is_on_wall() or is_on_floor(): # No mover horizontalmente si estamos trepando
		_handle_horizontal_move(delta)

	# 6. ACTIVAR DASH
	if Input.is_action_just_pressed("ui_focus_next") and can_dash: 
		start_dash()

	move_and_slide()

# --- FUNCIONES DE APOYO ---

func _apply_gravity(delta):
	if not is_on_floor() and not is_on_wall():
		var mult = fall_multiplier if velocity.y > 0 else gravity_multiplier
		velocity.y += gravity * mult * delta

func _handle_horizontal_move(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		var current_friction = friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0, current_friction * delta)

func _handle_wall_mechanics(delta):
	if is_on_wall_only():
		var wall_normal = get_wall_normal()
		var direction_input = Input.get_axis("ui_left", "ui_right")
		
		# Solo consideramos que está "empujando" si presiona la tecla contra la pared
		var is_pushing = (direction_input != 0 and sign(direction_input) == -sign(wall_normal.x))

		if is_pushing:
			# 1. EVITAR EL LANZAMIENTO HACIA ARRIBA AL CHOCAR
			# Si vienes muy rápido, reseteamos la velocidad vertical para que no salga disparado
			if is_on_floor() == false and velocity.y < wall_climb_speed:
				velocity.y = wall_climb_speed

			# 2. DESLIZAMIENTO
			if velocity.y > 0:
				velocity.y = min(velocity.y, wall_slide_speed)
			
			# 3. TREPAR (Solo si presiona ARRIBA y tiene STAMINA)
			if Input.is_action_pressed("ui_up") and stamina > 0:
				velocity.y = wall_climb_speed
				stamina -= 45 * delta
			# 4. QUEDARSE QUIETO (Hold)
			# Si no presionas arriba ni abajo, te quedas pegado consumiendo poca stamina
			elif not Input.is_action_pressed("ui_down"):
				velocity.y = 0 
				stamina -= 10 * delta 
		
		# 5. SALTO DE PARED
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
		dir.x = 1.0 
	velocity = dir.normalized() * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	velocity = velocity * 0.5
