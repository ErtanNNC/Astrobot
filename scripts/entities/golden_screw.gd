extends Area3D
## Gizli Altın Vida: her alanda bir tane (Bölüm 1). Kimliği: <alan>_vida

var area_id := ""
var _model: Node3D
var _t := 0.0
var _taken := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.8
	cs.shape = sh
	add_child(cs)
	var lvl := get_tree().current_scene
	if lvl and "area_id" in lvl:
		area_id = lvl.area_id
	_model = make_model()
	add_child(_model)
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.85, 0.3)
	light.light_energy = 1.5
	light.omni_range = 4.0
	add_child(light)
	if GameState.has_screw(area_id + "_vida"):
		_model.scale = Vector3.ONE * 0.6
		for m in _model.find_children("*", "MeshInstance3D", true, false):
			var mt: StandardMaterial3D = m.material_override.duplicate()
			mt.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mt.albedo_color.a = 0.35
			m.material_override = mt
	body_entered.connect(_on_body)


static func make_model() -> Node3D:
	var root := Node3D.new()
	var gold := AbilityModels.mat(Color(1.0, 0.78, 0.2), 0.15, 0.6)
	gold.metallic = 0.9
	var head := CylinderMesh.new()
	head.top_radius = 0.42
	head.bottom_radius = 0.42
	head.height = 0.16
	head.radial_segments = 6
	root.add_child(AbilityModels.mesh_node(head, gold, Vector3(0, 0.45, 0)))
	var slot := BoxMesh.new()
	slot.size = Vector3(0.6, 0.06, 0.1)
	root.add_child(AbilityModels.mesh_node(slot, AbilityModels.mat(Color(0.5, 0.35, 0.05)), Vector3(0, 0.535, 0)))
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.16
	shaft.bottom_radius = 0.06
	shaft.height = 0.8
	shaft.radial_segments = 8
	root.add_child(AbilityModels.mesh_node(shaft, gold, Vector3(0, 0.0, 0)))
	for i in 4:
		var t := TorusMesh.new()
		t.inner_radius = 0.1 - i * 0.018
		t.outer_radius = 0.2 - i * 0.025
		t.rings = 10
		t.ring_segments = 4
		root.add_child(AbilityModels.mesh_node(t, gold, Vector3(0, 0.25 - i * 0.16, 0), Vector3(0.25, 0, 0)))
	return root


func _process(delta: float) -> void:
	if _taken:
		return
	_t += delta
	_model.rotation.y += delta * 1.8
	_model.position.y = sin(_t * 1.7) * 0.15


func _on_body(b: Node) -> void:
	if b is Bip and not _taken:
		_taken = true
		var first := not GameState.has_screw(area_id + "_vida")
		GameState.add_screw(area_id + "_vida")
		Sfx.play("screw" if first else "pickup")
		Haptics.vibrate(80)
		var tw := create_tween()
		tw.tween_property(_model, "position:y", 1.5, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(_model, "rotation:y", _model.rotation.y + TAU * 2, 0.6)
		tw.tween_property(_model, "scale", Vector3.ZERO, 0.2)
		tw.tween_callback(queue_free)
		var lvl := get_tree().current_scene
		if lvl and lvl.has_method("on_screw_found"):
			lvl.on_screw_found()
