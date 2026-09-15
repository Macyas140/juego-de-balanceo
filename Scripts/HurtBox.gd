class_name Hurtbox
extends Area2D

func _init() -> void:
	collision_layer = 2
	collision_mask = 4
	

func _ready() -> void:
	area_entered.connect(_on_entro_area)

func _on_entro_area(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	if not hitbox.hay_linea_de_vision(self):
		return
	if owner.has_method("RecibirDaño"):
		var direccion = (owner.global_position - hitbox.global_position).normalized()
		owner.RecibirDaño(hitbox.dañoAtaque, direccion)
