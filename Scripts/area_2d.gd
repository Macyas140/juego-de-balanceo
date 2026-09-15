extends Area2D
@onready var timer: Timer = $Timer
@onready var Jugador: CharacterBody2D = $"../CharacterBody2D"



func _on_body_entered(body):
	print("Lol")
	Jugador.muriendo = true
	timer.start()



func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
