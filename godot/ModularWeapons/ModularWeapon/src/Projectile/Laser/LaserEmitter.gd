extends ProjectileEmitter

var firing := false
var current_lifetime := 0.0

onready var tracer := $LaserTracer
onready var laser_line := $Line2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("fire"):
		firing = false
		var points: Array = laser_line.points
		for i in range(points.size(), -1, -6):
			laser_line.points = points.slice(0, i)
			current_lifetime = projectile_lifetime * i / points.size()
			yield(get_tree(), "idle_frame")
		laser_line.points = []
		tracer.hide()
		tracer.position = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("fire"):
		fire()

		current_lifetime = min(
			current_lifetime + _delta * projectile_lifetime * 8, projectile_lifetime
		)

	laser_line.width = current_lifetime / projectile_lifetime * 10

	if firing:
		var points: Array = tracer.trace_path(current_lifetime)
		laser_line.points = points


func _do_fire(_direction: Vector2, _motions: Array, _lifetime: float) -> void:
	if not firing:
		firing = true
		current_lifetime = 0.0
		tracer.show()
	tracer.setup(global_position, Vector2.UP.rotated(global_rotation), _motions, _lifetime)
