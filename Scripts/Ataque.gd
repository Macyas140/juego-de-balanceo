class_name Hitbox
extends Area2D

@export var dañoAtaque = 50
signal golpeo(hurtbox)

func _init() -> void:
	collision_layer = 4
	collision_mask = 2

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		golpeo.emit(area)
