extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var recogida: bool = false

func _ready() -> void:
	collision_layer = 0
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if recogida or not body.is_in_group("Jugador"):
		return
	recogida = true
	var hud = get_tree().get_first_node_in_group("hud_monedas")
	if hud:
		var transf = get_viewport().get_canvas_transform()
		var pos_pantalla = transf * sprite.global_position
		var escala = transf.get_scale() * sprite.global_scale
		hud.recibir_moneda(pos_pantalla, sprite.sprite_frames, sprite.animation, sprite.frame, escala)
	queue_free()
