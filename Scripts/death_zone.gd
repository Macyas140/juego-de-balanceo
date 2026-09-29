extends Area2D
@onready var Jugador: CharacterBody2D = $"../CharacterBody2D"
@onready var timer: Timer = $Timer




func _on_body_entered(body: Node2D) -> void:
	print("entro En Muerte")
	Jugador.muriendo = true
	timer.start()



func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
