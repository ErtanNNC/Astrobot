extends Node
## Küçük görsel efektler (autoload: Fx): parıltı patlaması, vuruş donması (hit-stop).

var _spark_mesh: SphereMesh
var _spark_mats := {}
var _ring_mesh: TorusMesh


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


## Yerde (ya da havada) genişleyip sönen halka: iniş, çift zıplama, kontrol noktası, darbe.
func ring(at: Vector3, color := Color(1, 1, 1), radius := 1.2, seconds := 0.35, flat := true) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	if _ring_mesh == null:
		_ring_mesh = TorusMesh.new()
		_ring_mesh.rings = 20
		_ring_mesh.ring_segments = 5
		_ring_mesh.inner_radius = 0.88
		_ring_mesh.outer_radius = 1.0
	var mi := MeshInstance3D.new()
	mi.mesh = _ring_mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = m
	scene.add_child(mi)
	mi.global_position = at + Vector3(0, 0.06 if flat else 0.0, 0)
	mi.scale = Vector3(0.2, 0.25, 0.2)
	var tw := mi.create_tween()
	tw.set_parallel(true)
	tw.tween_property(mi, "scale", Vector3(radius, 0.25, radius), seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(m, "albedo_color:a", 0.0, seconds).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(mi.queue_free)


## Kutlama: birkaç renkte yukarı fışkıran parıltılar (kontrol noktası, alan sonu).
func confetti(at: Vector3) -> void:
	for c in [Color(1.0, 0.85, 0.3), Color(0.4, 0.9, 1.0), Color(1.0, 0.5, 0.7), Color(0.5, 1.0, 0.55)]:
		burst(at, c, 8, 5.5)


## Vuruş donması: oyunu çok kısa durdurur, darbeye ağırlık verir.
func hitstop(seconds := 0.06) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(seconds, true, false, true).timeout
	Engine.time_scale = 1.0
