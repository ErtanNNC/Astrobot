class_name Battery
extends Area3D
## Pil: toplanabilir. Kimliği (düğüm adı) kayda yazılır; toplanmış piller silik görünür
## ve tekrar sayılmaz (Bölüm 1 kural 3). Mıknatıs taşıyan Bip'e uzaktan çekilir.

const MAGNET_RANGE := 3.5
const VACUUM_RANGE := 1.6   ## m, yeteneksiz de pil bu kadar yakından çekilir

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


static var _mesh_cache: ArrayMesh


## Pil modeli: tek parça (tek çizim çağrısı), renkler köşe renginde. Gölge atmaz.
static func make_model() -> Node3D:
	if _mesh_cache == null:
		_mesh_cache = _build_mesh()
	var root := Node3D.new()
	var mi := MeshInstance3D.new()
	mi.mesh = _mesh_cache
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.3
	m.emission_enabled = true
	m.emission = Color(0.25, 0.8, 0.35)
	m.emission_energy_multiplier = 0.5
	mi.material_override = m
	root.add_child(mi)
	root.rotation.z = 0.35
	return root


static func _build_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	_add_cyl(st, 0.16, 0.42, 0.0, Color(0.3, 0.95, 0.45))         # gövde
	_add_cyl(st, 0.168, 0.1, -0.12, Color(0.12, 0.14, 0.2))       # koyu bant
	_add_cyl(st, 0.065, 0.07, 0.245, Color(0.95, 0.85, 0.3))      # uç
	st.generate_normals()
	return st.commit()


static func _add_cyl(st: SurfaceTool, r: float, h: float, cy: float, c: Color) -> void:
	var seg := 10
	var y0 := cy - h / 2
	var y1 := cy + h / 2
	st.set_color(c)
	for i in seg:
		var a0 := TAU * i / seg
		var a1 := TAU * (i + 1) / seg
		var p0 := Vector3(cos(a0) * r, 0, sin(a0) * r)
		var p1 := Vector3(cos(a1) * r, 0, sin(a1) * r)
		# yan yüz
		st.add_vertex(p0 + Vector3.UP * y0); st.add_vertex(p1 + Vector3.UP * y1); st.add_vertex(p1 + Vector3.UP * y0)
		st.add_vertex(p0 + Vector3.UP * y0); st.add_vertex(p0 + Vector3.UP * y1); st.add_vertex(p1 + Vector3.UP * y1)
		# üst ve alt kapak
		st.add_vertex(Vector3.UP * y1); st.add_vertex(p1 + Vector3.UP * y1); st.add_vertex(p0 + Vector3.UP * y1)
		st.add_vertex(Vector3.UP * y0); st.add_vertex(p0 + Vector3.UP * y0); st.add_vertex(p1 + Vector3.UP * y0)


func _id() -> String:
	return dynamic_id if dynamic_id != "" else String(name)


func _set_ghost() -> void:
	_ghost = true
	for m in _model.find_children("*", "MeshInstance3D", true, false):
		var mat: StandardMaterial3D = m.material_override.duplicate()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.vertex_color_use_as_albedo = false
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
	# Astro Bot'taki gibi: yakından geçince pil her zaman Bip'e çekilir (Mıknatısla daha uzaktan)
	var bip := get_tree().get_first_node_in_group("player") as Node3D
	if bip:
		var target := bip.global_position + Vector3.UP * 0.6
		var d := global_position.distance_to(target)
		var reach := MAGNET_RANGE if GameState.ability == "miknatis" else VACUUM_RANGE
		if d < reach or _flying:
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
	Daily.add("pil")
	_combo_time = 0.6
	Sfx.play("pickup", -6.0 if _ghost else -2.0, 1.0 + _combo * 0.04, 0.0)
	Fx.burst(global_position, Color(0.4, 1.0, 0.55), 8, 2.5)
	if _combo >= 5 and _combo % 5 == 0:
		# Pil zinciri: art arda 5 ve 10 pilde altın halka + parıltı
		Fx.ring(global_position, Color(1.0, 0.9, 0.35), 1.4, 0.35, false)
		Fx.burst(global_position, Color(1.0, 0.9, 0.35), 10, 4.0)
		Haptics.vibrate(20)
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
