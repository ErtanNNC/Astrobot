extends Node3D
## Pırıl: atölyenin ateş böceği lamba-drone'u, Bip'in rehberi. Konuşmaz; ışığıyla yol gösterir.
## Görünüş: Quaternius "Bee" modeli, sarı-beyaz parlayan malzemeyle (hikaye dokümanı, D-010).
## Davranış: Bip'in omzunun üstünde uçar; sahnede "piril_point" grubundaki bir noktaya yakın
## olunca oraya uçup bekler (yön gösterir). İpucu alanlarında tuş simgesi gösterir.

@export var follow_offset := Vector3(0.9, 1.9, 0.4)

var _bip: Node3D
var _t := 0.0
var _model: Node3D
var _icon: Node3D
var _icon_kind := ""
var _guide: Node3D
var _hint_pos := Vector3.ZERO
var _visited := {}


func _ready() -> void:
	add_to_group("piril")
	_model = load("res://assets/models/quaternius/enemies/Bee.gltf").instantiate()
	_model.scale = Vector3.ONE * 0.22
	add_child(_model)
	var glow := AbilityModels.mat(Color(1.0, 0.92, 0.45), 0.3, 1.2)
	for m in _model.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		for s in mi.mesh.get_surface_count():
			var orig := mi.get_active_material(s) as StandardMaterial3D
			if orig and orig.albedo_color.get_luminance() > 0.45:
				mi.set_surface_override_material(s, glow)
	var ap: AnimationPlayer = _model.find_child("AnimationPlayer", true, false)
	if ap:
		for n in ap.get_animation_list():
			if n.ends_with("Flying"):
				ap.get_animation(n).loop_mode = Animation.LOOP_LINEAR
				ap.play(n)
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.9, 0.5)
	light.light_energy = 1.4
	light.omni_range = 4.5
	add_child(light)
	var bulb := SphereMesh.new()
	bulb.radius = 0.12
	bulb.height = 0.24
	add_child(AbilityModels.mesh_node(bulb, AbilityModels.mat(Color(1, 0.95, 0.6), 0.2, 4.0), Vector3(0, -0.05, -0.12)))
	_icon = Node3D.new()
	_icon.visible = false
	add_child(_icon)


func _process(delta: float) -> void:
	_t += delta
	if _bip == null:
		_bip = get_tree().get_first_node_in_group("player")
		if _bip:
			global_position = _bip.global_position + follow_offset
		return
	var target: Vector3
	if _icon_kind != "":
		target = _hint_pos
	else:
		_update_guide()
		if _guide:
			target = _guide.global_position + Vector3(0, sin(_t * 2.0) * 0.3, 0)
		else:
			var yaw: float = _bip.facing_yaw
			target = _bip.global_position + Vector3(follow_offset.x, 0, follow_offset.z).rotated(Vector3.UP, yaw) + Vector3.UP * follow_offset.y
	target += Vector3(sin(_t * 1.7) * 0.25, sin(_t * 2.3) * 0.2, cos(_t * 1.3) * 0.25)
	var k := 1.0 - exp(-3.0 * delta)
	var prev := global_position
	global_position = global_position.lerp(target, k)
	var v := global_position - prev
	if v.length() > 0.002:
		rotation.y = lerp_angle(rotation.y, atan2(v.x, v.z), 6.0 * delta)
	if _icon.visible:
		_icon.rotation.y += delta * 2.0
		_icon.position.y = 0.75 + sin(_t * 4.0) * 0.06


func _update_guide() -> void:
	var bpos: Vector3 = _bip.global_position
	if _guide and (bpos.distance_to(_guide.global_position) < 3.0 or bpos.distance_to(_guide.global_position) > 16.0):
		_visited[_guide] = true
		_guide = null
	if _guide:
		return
	var best: Node3D = null
	var best_d := 12.0
	for p in get_tree().get_nodes_in_group("piril_point"):
		if _visited.has(p):
			continue
		var d := bpos.distance_to(p.global_position)
		if d < best_d and d > 3.0:
			best_d = d
			best = p
	_guide = best


## Tuş simgesi göster ("" kapatır).
func show_hint(kind: String, at: Vector3) -> void:
	if kind == _icon_kind:
		return
	_icon_kind = kind
	_hint_pos = at
	for c in _icon.get_children():
		c.queue_free()
	_icon.visible = kind != ""
	if kind == "":
		return
	var disc := CylinderMesh.new()
	disc.top_radius = 0.32
	disc.bottom_radius = 0.32
	disc.height = 0.05
	var col := Color(0.25, 0.62, 1.0) if kind in ["jump", "hold_jump"] else Color(1.0, 0.75, 0.2)
	var dm := AbilityModels.mat(col, 0.4, 1.0)
	_icon.add_child(AbilityModels.mesh_node(disc, dm, Vector3.ZERO, Vector3(PI / 2, 0, 0)))
	var white := AbilityModels.mat(Color.WHITE, 0.4, 1.5)
	match kind:
		"jump", "hold_jump":
			var tri := PrismMesh.new()
			tri.size = Vector3(0.3, 0.22, 0.06)
			_icon.add_child(AbilityModels.mesh_node(tri, white, Vector3(0, 0.06, 0.04)))
			var st := BoxMesh.new()
			st.size = Vector3(0.1, 0.14, 0.06)
			_icon.add_child(AbilityModels.mesh_node(st, white, Vector3(0, -0.1, 0.04)))
			if kind == "hold_jump":
				var ring := TorusMesh.new()
				ring.inner_radius = 0.36
				ring.outer_radius = 0.42
				_icon.add_child(AbilityModels.mesh_node(ring, white, Vector3.ZERO, Vector3(PI / 2, 0, 0)))
		"ability":
			var st := CylinderMesh.new()
			st.top_radius = 0.025
			st.bottom_radius = 0.025
			st.height = 0.28
			_icon.add_child(AbilityModels.mesh_node(st, white, Vector3(0, -0.04, 0.04)))
			var tip := SphereMesh.new()
			tip.radius = 0.07
			tip.height = 0.14
			_icon.add_child(AbilityModels.mesh_node(tip, white, Vector3(0, 0.13, 0.04)))
		"look", "move":
			var ring := TorusMesh.new()
			ring.inner_radius = 0.14
			ring.outer_radius = 0.2
			_icon.add_child(AbilityModels.mesh_node(ring, white, Vector3(0, 0, 0.04), Vector3(PI / 2, 0, 0)))
	Sfx.play("select", -10.0)
