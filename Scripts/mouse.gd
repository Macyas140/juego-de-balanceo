extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, get_global_mouse_position(), 16.5 * delta)
	
	var desired_scale:Vector2 = Vector2(0.35, 0.35) if Input.is_action_pressed("LanzarBufanda") else Vector2(0.4,0.4)
	scale = lerp(scale, desired_scale, 16.5 * delta)
