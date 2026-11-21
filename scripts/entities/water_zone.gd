extends Area3D
## Su havuzu: Bip normalde yüzer; Kaya taşıyorsa dibe batar ve altta yürüyebilir.

@export var size := Vector3(8, 4, 8)   ## yüzey = üst kenar
@export var lava := false              ## Volkan Adası: değen yanar (son kontrol noktası); Buz üstünde taş karolar yapar


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size + Vector3(0, 1.5, 0)   # yüzeyin 1,5 m üstü de algılanır (Buz için)
	cs.shape = b
	cs.position.y = -size.y / 2 + 0.75
	add_child(cs)
	var plane := PlaneMesh.new()
	plane.size = Vector2(size.x, size.z)
	plane.subdivide_width = int(size.x)
	plane.subdivide_depth = int(size.z)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/water.gdshader")
	mat.set_shader_parameter("wave_height", 0.06)
	if lava:
		mat.set_shader_parameter("deep", Color(0.85, 0.18, 0.04))
		mat.set_shader_parameter("shallow", Color(1.0, 0.62, 0.12))
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = mat
	add_child(mi)
	mi.visible = not lava          # lavda yalnızca parlayan çekirdek görünür
	# Su içi hacmi (yarı saydam)
	var vol := BoxMesh.new()
	vol.size = Vector3(size.x - 0.02, size.y, size.z - 0.02)
	var vm := StandardMaterial3D.new()
	vm.albedo_color = Color(0.2, 0.55, 0.9, 0.35) if not lava else Color(1.0, 0.35, 0.05, 1.0)
	if lava:
		# Lav: parlayan turuncu çekirdek (uzaktan "değme" diye okunur)
		vm.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		vm.emission_enabled = true
		vm.emission = Color(1.0, 0.38, 0.05)
		vm.emission_energy_multiplier = 1.6
	vm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vm.cull_mode = BaseMaterial3D.CULL_DISABLED
	add_child(AbilityModels.mesh_node(vol, vm, Vector3(0, -size.y / 2 - (0.05 if not lava else 0.02), 0)))
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


var _tiles := {}


## Buz taşıyan Bip suyun üstünde yürür: ayağının altında buz karoları belirir (Bölüm 3).
var _burn_cd := 0.0


func _physics_process(delta: float) -> void:
	if lava:
		_burn_cd = maxf(_burn_cd - delta, 0.0)
		for b in get_overlapping_bodies():
			if _burn_cd <= 0.0 and b is Bip and b.global_position.y < global_position.y - 0.3 and owner and owner.has_method("_fall"):
				_burn_cd = 1.5
				Fx.burst(b.global_position + Vector3.UP * 0.4, Color(1, 0.5, 0.1), 10, 3.0)
				owner._fall()
				return
	if GameState.ability != "buz":
		return
	for b in get_overlapping_bodies():
		if b is Bip and b.global_position.y > global_position.y - 0.7:
			var lp := to_local(b.global_position + b.velocity * 0.12)
			var key := Vector2i(roundi(lp.x / 2.0), roundi(lp.z / 2.0))
			if absf(key.x * 2.0) > size.x / 2 or absf(key.y * 2.0) > size.z / 2:
				continue
			if not _tiles.has(key) or not is_instance_valid(_tiles[key]):
				_tiles[key] = _make_tile(Vector3(key.x * 2.0, 0, key.y * 2.0))


func _make_tile(p: Vector3) -> StaticBody3D:
	var t := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bx := BoxShape3D.new()
	bx.size = Vector3(2.05, 0.4, 2.05)
	cs.shape = bx
	cs.position.y = -0.18
	t.add_child(cs)
	var m := BoxMesh.new()
	m.size = Vector3(2.0, 0.36, 2.0)
	var mat := AbilityModels.mat(Color(0.8, 0.95, 1.0, 0.85) if not lava else Color(0.35, 0.3, 0.32, 1.0), 0.05 if not lava else 0.8, 0.3 if not lava else 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	t.add_child(AbilityModels.mesh_node(m, mat, Vector3(0, -0.18, 0)))
	add_child(t)
	t.position = p
	t.scale = Vector3(0.3, 1, 0.3)
	var tw := t.create_tween()
	tw.tween_property(t, "scale", Vector3.ONE, 0.12)
	tw.tween_interval(6.0)
	tw.tween_property(t, "scale", Vector3(0.6, 0.3, 0.6), 0.6)
	tw.tween_callback(t.queue_free)
	Sfx.play("glass", -14.0, 1.4)
	return t


func _on_enter(b: Node) -> void:
	if b is Bip and not lava:
		b.water_level = global_position.y


func _on_exit(b: Node) -> void:
	if b is Bip and not lava:
		b.water_level = -INF
