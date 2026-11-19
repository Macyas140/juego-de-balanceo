extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var pausa_en_negro: float = 0.15
var _en_transicion: bool = false

signal on_transition_finished

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 105
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animated_finished)

func _on_animated_finished(anim_name):
	if anim_name == "FadeOutAnim":
		on_transition_finished.emit()
		await get_tree().create_timer(pausa_en_negro, true, false, true).timeout
		animation_player.play("FadeToNormal")
		on_transition_finished.emit()
	elif anim_name == "FadeToNormal":
		color_rect.visible = false
		_en_transicion = false

func transition():
	_en_transicion = true
	color_rect.visible = true
	animation_player.play("FadeOutAnim")

func revelar():
	if _en_transicion:
		return
	_en_transicion = true
	color_rect.visible = true
	animation_player.play("FadeToNormal")
	animation_player.advance(0) 
