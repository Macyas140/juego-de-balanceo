extends Node2D

var button_type = null

func _on_start_pressed() -> void:
	button_type = "Start"
	#$MenuInicioTrans.show()
	#$MenuInicioTrans/Fade_Timer.start()
	#$MenuInicioTrans/AnimationPlayer.play("TransicionInicio")
	get_tree().change_scene_to_file("res://Scenes/juego.tscn")
	


func _on_settings_pressed() -> void:
	button_type = "Settings"
	#$MenuInicioTrans.show()
	#$MenuInicioTrans/Fade_Timer.start()
	#$MenuInicioTrans/AnimationPlayer.play("TransicionInicio")
	get_tree().change_scene_to_file("res://Scenes/settingsPausa.tscn")
	


func _on_quit_pressed() -> void:
	get_tree().quit()


#func _on_fade_timer_timeout() -> void:
#	if button_type == "Start":
#		get_tree().change_scene_to_file("res://Scenes/juego.tscn")
#	elif button_type == "Settings":
#		get_tree().change_scene_to_file("res://Scenes/settingsPausa.tscn")
