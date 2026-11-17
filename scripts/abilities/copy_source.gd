@tool
extends Area3D
## Kopyalanabilir nesne: Bip menzile girince parlar; Yetenek tuşu yeteneği kopyalar.
## Kopyalanınca yok olmaz, sınırsız kopyalanabilir (kopyalama kural 7).

@export_enum("yay", "balon", "miknatis", "kaya") var ability := "yay":
	set(v):
		ability = v
		if is_inside_tree():
			_build()

var _model: Node3D
var _ring: MeshInstance3D
var _ring_mat: StandardMaterial3D
var _sparkles: CPUParticles3D
var _near := false
var _t := 0.0


func _ready() -> void:
	_build()
	if Engine.is_editor_hint():
		return
	monitoring = true
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 1.8
	cs.shape = sh
	cs.position.y = 0.6
	add_child(cs)
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	# Katı gövde: üstüne çıkılabilir, içinden geçilmez
	var body := StaticBody3D.new()
	var bs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.5
	cyl.height = 0.9
	bs.shape = cyl
	bs.position.y = 0.45
	body.add_child(bs)
	add_child(body)


func _build() -> void:
	if _model:
		_model.queue_free()
	if _ring:
		_ring.queue_free()
	_model = AbilityModels.make_source(ability)
	add_child(_model)
	var c := AbilityModels.color(ability)
	_ring_mat = AbilityModels.mat(c, 0.5, 1.6)
	_ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ring_mat.albedo_color.a = 0.6
	_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var t := TorusMesh.new()
	t.inner_radius = 0.62
	t.outer_radius = 0.72
	t.rings = 24
	t.ring_segments = 6
	_ring = AbilityModels.mesh_node(t, _ring_mat, Vector3(0, 0.04, 0), Vector3.ZERO, Vector3(1, 0.3, 1))
	add_child(_ring)
	if not Engine.is_editor_hint() and _sparkles == null:
		_sparkles = CPUParticles3D.new()
		_sparkles.amount = 10
		_sparkles.lifetime = 1.4
		var q := SphereMesh.new()
		q.radius = 0.035
		q.height = 0.07
		q.radial_segments = 4
		q.rings = 2
		_sparkles.mesh = q
		_sparkles.material_override = AbilityModels.mat(Color(1, 1, 0.8), 0.5, 3.0)
		_sparkles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		_sparkles.emission_sphere_radius = 0.6
		_sparkles.direction = Vector3.UP
		_sparkles.spread = 20.0
		_sparkles.gravity = Vector3.ZERO
		_sparkles.initial_velocity_min = 0.3
		_sparkles.initial_velocity_max = 0.7
		_sparkles.position.y = 0.6
		add_child(_sparkles)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_t += delta
	var pulse := 0.5 + 0.5 * sin(_t * (6.0 if _near else 2.5))
	_ring_mat.emission_energy_multiplier = (2.5 if _near else 1.0) + pulse * 1.5
	_ring.scale = Vector3.ONE * (1.0 + (0.12 if _near else 0.04) * pulse) * Vector3(1, 0.3, 1)
	if ability == "balon":
		_model.position.y = sin(_t * 1.6) * 0.08
		_model.rotation.z = sin(_t * 1.1) * 0.08


func _on_enter(b: Node) -> void:
	if b is Bip:
		b.register_source(self)
		_near = true


func _on_exit(b: Node) -> void:
	if b is Bip:
		b.unregister_source(self)
		_near = false


func on_copied() -> void:
	var tw := create_tween()
	tw.tween_property(_model, "scale", Vector3(1.25, 0.75, 1.25), 0.08)
	tw.tween_property(_model, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
