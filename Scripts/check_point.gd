extends Area2D
@onready var spawn: Marker2D = $Marker2D


@export var color_activo: Color = Color(0.4, 1.0, 0.4)
var activado: bool = false

func _ready() -> void:
	collision_layer = 0
	body_entered.connect(_on_body_entered)
	if Checkpoint.es_checkpoint_actual(global_position):
		_marcar_activo()

func _on_body_entered(body: Node2D) -> void:
	print("Entro")
	if activado or not body.is_in_group("Jugador"):
		return
	if body.muriendo or body.muriendoColgado:
		return
	Checkpoint.guardar(spawn.global_position)   # <-- posición de spawn, no la del Area2D
	_marcar_activo()

func _marcar_activo() -> void:
	activado = true
	#Sprite2D.modulate = color_activo
