extends Node
## Küçük görsel efektler (autoload: Fx): parıltı patlaması, vuruş donması (hit-stop).

var _spark_mesh: SphereMesh
var _spark_mats := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_spark_mesh = SphereMesh.new()
	_spark_mesh.radius = 0.06
	_spark_mesh.height = 0.12
	_spark_mesh.radial_segments = 6
	_spark_mesh.rings = 3


## Bir noktada renkli parıltı patlaması.
func burst(at: Vector3, color := Color(1, 0.95, 0.5), amount := 12, speed := 3.0) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = amount
	p.lifetime = 0.45
	p.explosiveness = 1.0
	p.mesh = _spark_mesh
	var key := color.to_html()
	if not _spark_mats.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = color
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 3.0
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_spark_mats[key] = m
	p.material_override = _spark_mats[key]
	p.direction = Vector3.UP
	p.spread = 180.0
	p.gravity = Vector3(0, -6, 0)
	p.initial_velocity_min = speed * 0.5
	p.initial_velocity_max = speed
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.3
	scene.add_child(p)
	p.global_position = at
	p.emitting = true
	get_tree().create_timer(1.0, false).timeout.connect(p.queue_free)


## Vuruş donması: oyunu çok kısa durdurur, darbeye ağırlık verir.
func hitstop(seconds := 0.06) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(seconds, true, false, true).timeout
	Engine.time_scale = 1.0
