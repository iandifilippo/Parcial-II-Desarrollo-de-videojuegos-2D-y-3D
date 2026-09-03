extends CharacterBody3D

## Velocidad máxima de desplazamiento, en metros por segundo.
@export var speed: float = 4.0
## Qué tan rápido gana velocidad (m/s²).
@export var aceleracion: float = 20.0
## Qué tan rápido la pierde al soltar los controles (m/s²).
@export var friccion: float = 30.0
## Velocidad vertical inicial del salto (m/s).
@export var fuerza_salto: float = 5.0
## Gravedad aplicada al jugador (m/s²).
@export var gravedad: float = 9.8
## Cámara que define qué es "adelante". Si se deja vacía se usa la activa.
@export var camara: Camera3D

var _accion_salto: String = "ui_accept"


func _ready() -> void:
	if camara == null:
		camara = get_viewport().get_camera_3d()
	# Usa la acción "saltar" del Mapa de Entrada si existe; si no, la barra.
	if InputMap.has_action("saltar"):
		_accion_salto = "saltar"


func _physics_process(delta: float) -> void:
	# --- Vertical: gravedad y salto -------------------------------------
	if not is_on_floor():
		velocity.y -= gravedad * delta

	if is_on_floor() and Input.is_action_just_pressed(_accion_salto):
		velocity.y = fuerza_salto

	# --- Horizontal: hacia dónde quiere ir ------------------------------
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var entrada := Vector3(input_dir.x, 0.0, input_dir.y)

	# Movimiento relativo a la cámara (mismo patrón de la Sesión 8/9).
	var base := camara.global_basis if camara != null else global_basis
	var direction := base * entrada
	direction.y = 0.0
	direction = direction.normalized()

	# Aceleración progresiva al moverse, fricción al soltar.
	if direction.length() > 0.01:
		velocity.x = move_toward(velocity.x, direction.x * speed, aceleracion * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, aceleracion * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friccion * delta)
		velocity.z = move_toward(velocity.z, 0.0, friccion * delta)

	move_and_slide()
