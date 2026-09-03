extends SpringArm3D

## Cámara de tercera persona (mismo patrón de la Sesión 9).

@export var objetivo: Node3D
@export var sensibilidad: float = 0.004
@export var suavizado: float = 12.0
@export var altura: float = 1.4


func _ready() -> void:
	if objetivo == null:
		objetivo = get_parent() as Node3D

	top_level = true

	if objetivo is CollisionObject3D:
		add_excluded_object(objetivo.get_rid())

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if evento is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= evento.relative.x * sensibilidad
		rotation.x -= evento.relative.y * sensibilidad
		rotation.x = clamp(rotation.x, deg_to_rad(-55.0), deg_to_rad(25.0))


func _physics_process(delta: float) -> void:
	if objetivo == null:
		return

	var destino: Vector3 = objetivo.global_position + Vector3(0.0, altura, 0.0)
	global_position = global_position.lerp(destino, delta * suavizado)
