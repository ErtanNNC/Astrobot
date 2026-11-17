extends Area3D
## Alan çıkışı: parlayan bir kapı/ışık halkası. Bip girince alan biter ve sıradaki alana geçilir.

var _ring: MeshInstance3D
var _done := false
var _t := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := CylinderShape3D.new()
	b.radius = 1.3
	b.height = 3.0
	cs.shape = b
	cs.position.y = 1.5
	add_child(cs)
	var t := TorusMesh.new()
	t.inner_radius = 1.25
	t.outer_radius = 1.5
	t.rings = 32
	t.ring_segments = 8
	_ring = AbilityModels.mesh_node(t, AbilityModels.mat(Color(1, 0.85, 0.3), 0.3, 1.3), Vector3(0, 1.6, 0), Vector3(PI / 2, 0, 0))
	add_child(_ring)
	var disc := CylinderMesh.new()
	disc.top_radius = 1.25
	disc.bottom_radius = 1.25
	disc.height = 0.02
	var dm := AbilityModels.mat(Color(1, 0.95, 0.7, 0.18), 0.3, 0.4)
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	add_child(AbilityModels.mesh_node(disc, dm, Vector3(0, 1.6, 0), Vector3(PI / 2, 0, 0)))
	var pad := CylinderMesh.new()
	pad.top_radius = 1.5
	pad.bottom_radius = 1.7
	pad.height = 0.2
	add_child(AbilityModels.mesh_node(pad, AbilityModels.mat(Color(0.95, 0.75, 0.3), 0.4, 0.3), Vector3(0, 0.1, 0)))
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.85, 0.4)
	light.light_energy = 2.0
	light.omni_range = 6.0
	light.position.y = 1.6
	add_child(light)
	body_entered.connect(_on_body)


func _process(delta: float) -> void:
	_t += delta
	_ring.rotation.y = sin(_t) * 0.2
	_ring.scale = Vector3.ONE * (1.0 + sin(_t * 3.0) * 0.04)


func _on_body(b: Node) -> void:
	if b is Bip and not _done:
		_done = true
		var lvl := get_tree().current_scene
		if lvl and lvl.has_method("complete_area"):
			lvl.complete_area()
