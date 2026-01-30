extends ParallaxLayer

# En Godot 4 usamos @export con una arroba
@export var cloud_speed: float = -30.0

func _process(delta: float) -> void:
	# La propiedad motion_offset sigue funcionando igual
	self.motion_offset.x += cloud_speed * delta
