extends Node2D


@export var mute: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)
	_conectar_existentes(get_tree().root)
	if not mute:
		play_music()
		
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		if not node.mouse_entered.is_connected(play_ui_hover):
			node.mouse_entered.connect(play_ui_hover)
		if not node.pressed.is_connected(play_ui_click):
			node.pressed.connect(play_ui_click)

func _conectar_existentes(nodo: Node) -> void:
	_on_node_added(nodo)
	for hijo in nodo.get_children():
		_conectar_existentes(hijo)

func play_music():
	if not mute:
		$Music.play()

func play_jump() -> void:
	if not mute:
		$Jump.play()

func play_end_level() -> void:
	if not mute:
		$EndLevel.play()
		

func play_Attack() -> void:
	if not mute:
		$Attack.play()
		
func play_Recieve_Attack() -> void:
	if not mute:
		$RecieveAttack.play()
	
func play_fall() -> void:
	if not mute:
		$Fall.play()

func play_caminar() -> void:
	if not mute and not $Caminar.playing:
		$Caminar.play()


func play_LanzarBufanda() -> void:
	if not mute:
		$"Lanzamiento de bufanda".play()

func play_ui_hover() -> void:
	if not mute and not $UIHover.playing:
		$UIHover.play()
		
func play_ui_click() -> void:
	if not mute:
		$UIClick.play()
