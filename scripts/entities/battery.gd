class_name Battery
extends Area3D
## Pil: toplanabilir. Kimliği (düğüm adı) kayda yazılır; toplanmış piller silik görünür
## ve tekrar sayılmaz (Bölüm 1 kural 3). Mıknatıs taşıyan Bip'e uzaktan çekilir.

const MAGNET_RANGE := 3.5

var area_id := ""
var collected := false
var dynamic_id := ""        ## sandık/düşmandan çıkanlar için
var _t := 0.0
var _model: Node3D
var _ghost := false
var _flying := false
var _base_y := 0.0

static var _combo := 0
static var _combo_time := 0.0


func _ready() -> void:
	add_to_group("battery")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.55
	cs.shape = sh
	add_child(cs)
	_model = make_model()
	add_child(_model)
	_t = randf() * TAU
	_base_y = position.y
	body_entered.connect(_on_body)
	var lvl := get_tree().current_scene
	if lvl and "area_id" in lvl:
		area_id = lvl.area_id
	if GameState.has_battery(area_id, _id()):
		_set_ghost()


static func make_model() -> Node3D:
	var root := Node3D.new()
	var body := CylinderMesh.new()
	body.top_radius = 0.16
	body.bottom_radius = 0.16
	body.height = 0.42
	body.radial_segments = 12
	var green := AbilityModels.mat(Color(0.3, 0.95, 0.45), 0.3, 0.8)
	var dark := AbilityModels.mat(Color(0.12, 0.14, 0.2), 0.4)
	var tip := AbilityModels.mat(Color(0.95, 0.85, 0.3), 0.2, 0.5)
	root.add_child(AbilityModels.mesh_node(body, green))
	var band := CylinderMesh.new()
	band.top_radius = 0.165
	band.bottom_radius = 0.165
	band.height = 0.1
	band.radial_segments = 12
	root.add_child(AbilityModels.mesh_node(band, dark, Vector3(0, -0.12, 0)))
	var cap := CylinderMesh.new()
	cap.top_radius = 0.06
	cap.bottom_radius = 0.07
	cap.height = 0.07
	cap.radial_segments = 8
	root.add_child(AbilityModels.mesh_node(cap, tip, Vector3(0, 0.245, 0)))
	root.rotation.z = 0.35
	return root


func _id() -> String:
	return dynamic_id if dynamic_id != "" else String(name)


func _set_ghost() -> void:
	_ghost = true
	for m in _model.find_children("*", "MeshInstance3D", true, false):
		var mat: StandardMaterial3D = m.material_override.duplicate()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.6, 0.85, 1.0, 0.3)
		mat.emission_enabled = false
		m.material_override = mat


func _process(delta: float) -> void:
	if collected:
		return
	_t += delta
	_model.rotation.y += delta * 2.5
	_model.position.y = sin(_t * 2.0) * 0.08
	if _combo_time > 0.0:
		_combo_time -= delta
	elif _combo > 0:
		_combo = 0
	# Mıknatıs pasifi: küçük metal nesneler Bip'e çekilir (kopyalama tablosu)
	if GameState.ability == "miknatis" or _flying:
		var bip := get_tree().get_first_node_in_group("player") as Node3D
		if bip:
			var target := bip.global_position + Vector3.UP * 0.6
			var d := global_position.distance_to(target)
			if d < MAGNET_RANGE or _flying:
				_flying = true
				global_position = global_position.move_toward(target, delta * (6.0 + 10.0 / maxf(d, 0.3)))


func _on_body(b: Node) -> void:
	if b is Bip and not collected:
		collect()


func collect() -> void:
	collected = true
	if not _ghost:
		GameState.add_battery(area_id, _id())
	_combo = mini(_combo + 1, 12)
	_combo_time = 0.6
	Sfx.play("pickup", -6.0 if _ghost else -2.0, 1.0 + _combo * 0.04, 0.0)
	Fx.burst(global_position, Color(0.4, 1.0, 0.55), 8, 2.5)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_model, "scale", Vector3.ONE * 1.6, 0.12)
	tw.tween_property(_model, "position:y", _model.position.y + 0.8, 0.2)
	tw.chain().tween_property(_model, "scale", Vector3.ZERO, 0.1)
	tw.chain().tween_callback(queue_free)


## Sandıktan/düşmandan pil saçmak için yardımcı.
static func burst(parent: Node, at: Vector3, count: int, prefix: String) -> void:
	for i in count:
		var b := Battery.new()
		b.dynamic_id = "%s_%d" % [prefix, i]
		b.name = "dyn_%s_%d" % [prefix, i]
		parent.add_child(b)
		b.global_position = at + Vector3.UP * 0.5
		var ang := TAU * i / count + randf() * 0.4
		var dest := at + Vector3(cos(ang), 0, sin(ang)) * randf_range(1.0, 1.8) + Vector3.UP * 0.6
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "global_position:x", dest.x, 0.45)
		tw.tween_property(b, "global_position:z", dest.z, 0.45)
		tw.tween_property(b, "global_position:y", dest.y + 1.5, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tw.chain().tween_property(b, "global_position:y", dest.y, 0.23).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
