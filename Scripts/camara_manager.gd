extends Node

@export var jugador:CharacterBody2D
@export var CamaraMuerte:PhantomCamera2D
@export var CamaraJugador:PhantomCamera2D
@export_group("Efecto Muerte")
@export var zoomMuerte: Vector2 = Vector2(6,6)
@export var duracionZoom: float = 10.0
@export var TemblorMuerte: PhantomCameraNoise2D
@export var duracionTempblor:float = 10.0
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

@onready var noiseMuerte: PhantomCameraNoiseEmitter2D = $PhantomCamera2D/PhantomCameraNoiseEmitter2D
@onready var noiseAterrizaje: PhantomCameraNoiseEmitter2D = $"../CamaraSystem/PhantomCamera2D/PhantomCameraNoiseEmitter2D"

func _ready() -> void:
	jugador.murioColgado.connect(_on_jugador_murio)
	jugador.aterrizo.connect(_on_jugador_aterrizo)
	CamaraMuerte.priority = 0
	CamaraJugador.priority = 10
	Estamina.listoReinicio.connect(reiniciar_efectos_muerte)

func _on_jugador_murio(colgado:bool) -> void:
	jugadorMuerto = true
	jugadorMurioColgado = colgado
	update_camera()
	

func update_CurrentZone(body, zone_a, zone_b):
	if body == jugador and not jugadorMuerto:
		match currentScene:
			zone_a:
				currentScene = zone_b
			zone_b:
				currentScene = zone_a

func update_camera():
	CamaraJugador.priority = 0
	CamaraMuerte.priority = 10
	noiseMuerte.emit()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(CamaraMuerte, "zoom", zoomMuerte, duracionZoom)
	if vignetteMaterial:
		vignetteMaterial.set_shader_parameter("strength", 0.0)
		tween.tween_method(
			func(v): vignetteMaterial.set_shader_parameter("strength",v),
			0.0, intensidadVignetteMax, duracionVignette
		)
	

func reiniciar_efectos_muerte() -> void:
	if vignetteMaterial:
		vignetteMaterial.set_shader_parameter("strength", 0.0)

func _on_zone_01_body_entered(body: Node2D) -> void:
	update_CurrentZone(body, 0, 1)

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
	
	
