extends Node

@export var jugador:CharacterBody2D
@export var CamaraMuerte:PhantomCamera2D
@export var CamaraJugador:PhantomCamera2D
@export_group("Efecto Muerte")
@export var zoomMuerte: Vector2 = Vector2(6,6)
@export var duracionZoom: float = 8.0
@export var TemblorMuerte: PhantomCameraNoise2D
@export var duracionTempblor:float = 8.0
@export var amplitud_temblor_max: float = 20.0
@onready var vignetteMaterial: ShaderMaterial = $"../CanvasLayer/ColorRect".material
@export var intensidadVignetteMax: float = 0.8
@export var duracionVignette: float = 8
@export_group("Efecto Aterrizaje")
@export var RuidoAterrizaje: PhantomCameraNoise2D
@export var amplitudAterrizajeMin: float = 3.0
@export var amplitudAterrizajeMax: float = 10.0
@export var caidaVelocidadMin: float = 302.0
@export var caidaVelocidadMax: float = 1200.0
@export var duracionAterrizaje: float = 0.2


var currentScene:int = 0
var jugadorMuerto:bool = false
var jugadorMurioColgado: bool = false
var tween_muerte: Tween

@onready var noiseMuerte: PhantomCameraNoiseEmitter2D = $PhantomCamera2D/PhantomCameraNoiseEmitter2D
@onready var noiseAterrizaje: PhantomCameraNoiseEmitter2D = $"../CamaraSystem/PhantomCamera2D/PhantomCameraNoiseEmitter2D"

func _ready() -> void:
	print("Prioridades al cargar -> Jugador: ", CamaraJugador.priority, " | Muerte: ", CamaraMuerte.priority)
	jugador.murioColgado.connect(_on_jugador_murio)
	jugador.aterrizo.connect(_on_jugador_aterrizo)
	jugadorMuerto = false
	jugadorMurioColgado = false
	_restaurar_camaras.call_deferred()
	
	Estamina.listoReinicio.connect(reiniciar_efectos_muerte)
	
	if Checkpoint.tiene_checkpoint:
		CamaraJugador.global_position = Checkpoint.posicion_respawn

func _restaurar_camaras() -> void:
	CamaraMuerte.priority = 0
	CamaraJugador.priority = 10
	if CamaraJugador.has_method("make_current"):
		CamaraJugador.make_current()

func _on_jugador_murio(colgado:bool) -> void:
	jugadorMuerto = true
	jugadorMurioColgado = colgado
	update_camera()
	

func update_camera():
	CamaraJugador.priority = 0
	CamaraMuerte.priority = 10
	noiseMuerte.emit()
	
	tween_muerte = create_tween()
	tween_muerte.set_parallel(true)
	tween_muerte.tween_property(CamaraMuerte, "zoom", zoomMuerte, duracionZoom)
	if vignetteMaterial:
		vignetteMaterial.set_shader_parameter("strength", 0.0)
		tween_muerte.tween_method(
			func(v): vignetteMaterial.set_shader_parameter("strength",v),
			0.0, intensidadVignetteMax, duracionVignette
		)
	

func reiniciar_efectos_muerte() -> void:
	if tween_muerte and tween_muerte.is_valid():
		tween_muerte.kill()
	
	jugadorMuerto = false
	jugadorMurioColgado = false
	_restaurar_camaras()
	if vignetteMaterial:
		vignetteMaterial.set_shader_parameter("strength", 0.0)

func _on_jugador_aterrizo(velocidad_caida: float) -> void:
	if jugadorMuerto or not RuidoAterrizaje or not noiseAterrizaje:
		return
	if velocidad_caida < caidaVelocidadMin:
		return
	var t = clamp((velocidad_caida - caidaVelocidadMin) / (caidaVelocidadMax - caidaVelocidadMin), 0.0, 0.2)
	RuidoAterrizaje.amplitude = lerp(amplitudAterrizajeMin, amplitudAterrizajeMax, t)
	noiseAterrizaje.noise = RuidoAterrizaje
	noiseAterrizaje.duration = duracionAterrizaje
	noiseAterrizaje.emit()
	
func snap_camara_al_jugador() -> void:
	CamaraJugador.global_position = Checkpoint.posicion_respawn
	
