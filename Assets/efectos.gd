class_name Efectos
extends RefCounted

## Funciones de efectos visuales reutilizables (vistas en la Sesión 11).
## Ya están completas — no son parte del examen, son una herramienta para
## usar en la Tarea de efectos visuales.

static func flash(objetivo: Object, propiedad: String, color: Color, duracion: float, quien_llama: Node) -> bool:
	if objetivo == null or quien_llama == null:
		return false
	var color_original = objetivo.get(propiedad)
	var tween := quien_llama.create_tween()
	tween.tween_property(objetivo, propiedad, color, duracion)
	tween.tween_property(objetivo, propiedad, color_original, duracion)
	return true


static func particulas(sistema: GPUParticles3D) -> bool:
	if sistema == null:
		return false
	sistema.restart()
	sistema.emitting = true
	return true
