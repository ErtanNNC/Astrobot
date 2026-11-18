extends Node3D
## Son patron: Statik (Bölüm 4). Fırtınadan doğmuş mor kıvılcımlı bulut; yenilmez, ikna edilir (D-014).
## Görünüş: Quaternius bulut modelleri mora boyanmış, kıvılcım parçacıkları, iki göz, metal taç (D-010).
## Aşama 1 (Kaya):   yıldırımlardan kaç; üç paratoneri (grup "boss_rod", çatlak blok) Kaya ile çakarak göm.
## Aşama 2 (Pervane + Balon): Statik yükselir; yüzen bulutlardan sırtındaki şaltere ulaş (tetikleyici "switch").
## Aşama 3 (Mıknatıs): Statik alçalır; metal tacına Mıknatısla çekil, tacın üstünde Yetenek tuşu:
##                    anteninden enerji akar → Statik sakinleşir, pembeye döner, son Çekirdek Pil'i bırakır.
## API diğer patronlarla aynı (scripts/boss/crane_boss.gd).

signal defeated

@export var boss_name := "Statik"
@export var strike_interval := 1.5     ## s, aşama 1 yıldırım aralığı

const HOVER := [6.5, 6.5, 13.0, 3.5, 3.5]   ## aşamaya göre bulutun merkez yüksekliği
const CROWN_SIZE := Vector3(3.0, 0.8, 3.0)

var phase := 0
var _t := 0.0
var _strike_timer := 2.0
var _bip: Bip
var _cloud: Node3D
var _cloud_mats: Array = []
var _lights: Array = []
var _crown: StaticBody3D
var _sparks: CPUParticles3D
var _phase_nodes := {}
var _beam: MeshInstance3D
var _calm := false
var _y := 6.5


func _ready() -> void:
	add_to_group("boss")
	_build()
	_bip = get_tree().get_first_node_in_group("player")
	for n in get_tree().get_nodes_in_group("boss_phase"):
		var p: int = int(n.get_meta("phase", 0))
		if not _phase_nodes.has(p):
			_phase_nodes[p] = []
		_phase_nodes[p].append(n)
	_set_phase_nodes.call_deferred(1)


func _tint(node: Node3D, c: Color) -> void:
	for m in node.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		for s in mi.mesh.get_surface_count():
			var mat := AbilityModels.mat(c, 0.6, 0.35)
			mi.set_surface_override_material(s, mat)
			_cloud_mats.append(mat)


func _build() -> void:
	_cloud = Node3D.new()
	_cloud.position.y = HOVER[0]
	add_child(_cloud)
	var purple := Color(0.55, 0.35, 0.85)
	for i in 4:
		var c: Node3D = load("res://assets/models/quaternius/platformer/Cloud_%d.gltf" % (1 + i % 3)).instantiate()
		var a := TAU * i / 4.0
		c.position = Vector3(cos(a) * 2.2, 0.0, sin(a) * 2.2)
		c.scale = Vector3.ONE * (1.3 + 0.2 * i)
		c.rotation.y = a
		_cloud.add_child(c)
		_tint(c, purple)
	var core: Node3D = load("res://assets/models/quaternius/platformer/Cloud_2.gltf").instantiate()
	core.scale = Vector3.ONE * 2.2
	_cloud.add_child(core)
	_tint(core, purple.darkened(0.1))
	# Gözler (+Z, girişe bakar)
	for sx in [-0.8, 0.8]:
		var e := SphereMesh.new()
		e.radial_segments = 12
		e.rings = 6
		e.radius = 0.45
		e.height = 0.9
		_cloud.add_child(AbilityModels.mesh_node(e, AbilityModels.mat(Color.WHITE, 0.3, 1.0), Vector3(sx, 0.4, 2.6)))
		var p := SphereMesh.new()
		p.radial_segments = 12
		p.rings = 6
		p.radius = 0.2
		p.height = 0.4
		_cloud.add_child(AbilityModels.mesh_node(p, AbilityModels.mat(Color(0.15, 0.05, 0.25)), Vector3(sx, 0.4, 3.0)))
	# Kıvılcımlar
	_sparks = CPUParticles3D.new()
	_sparks.amount = 30
	_sparks.lifetime = 0.6
	var q := SphereMesh.new()
	q.radial_segments = 12
	q.rings = 6
	q.radius = 0.1
	q.height = 0.2
	_sparks.mesh = q
	_sparks.material_override = AbilityModels.mat(Color(0.85, 0.6, 1.0), 0.3, 5.0)
	_sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	_sparks.emission_sphere_radius = 3.5
	_sparks.gravity = Vector3(0, -8, 0)
	_sparks.initial_velocity_min = 1.0
	_sparks.initial_velocity_max = 3.0
	_cloud.add_child(_sparks)
	var light := OmniLight3D.new()
	light.light_color = Color(0.8, 0.5, 1.0)
	light.light_energy = 2.5
	light.omni_range = 14.0
	_cloud.add_child(light)
	# Metal taç (aşama 3'te Mıknatısla çekilinir)
	_crown = StaticBody3D.new()
	_crown.set_script(load("res://scripts/entities/metal_block.gd"))
	_crown.size = CROWN_SIZE
	_crown.position = Vector3(0, 2.6, 0)
	_crown.name = "Tac"
	_cloud.add_child(_crown)
	var gold := AbilityModels.mat(Color(1.0, 0.8, 0.25), 0.25, 0.4)
	gold.metallic = 0.8
	for i in 5:
		var a := TAU * i / 5.0
		var spike := PrismMesh.new()
		spike.size = Vector3(0.5, 0.7, 0.3)
		_crown.add_child(AbilityModels.mesh_node(spike, gold, Vector3(cos(a) * 1.25, 0.75, sin(a) * 1.25)))
	# Can ışıkları
	for i in 3:
		var l := SphereMesh.new()
		l.radial_segments = 12
		l.rings = 6
		l.radius = 0.2
		l.height = 0.4
		var lm := AbilityModels.mat(Color(1.0, 0.85, 0.2), 0.3, 3.0)
		_cloud.add_child(AbilityModels.mesh_node(l, lm, Vector3(-0.8 + i * 0.8, 1.6, 2.4)))
		_lights.append(lm)


func crown_top() -> Vector3:
	return _crown.global_position + Vector3(0, CROWN_SIZE.y / 2, 0)


func start_fight() -> void:
	if phase == 0:
		phase = 1
		_strike_timer = 1.5


func _physics_process(delta: float) -> void:
	_t += delta
	var want: float = HOVER[clampi(phase, 0, 4)]
	_y = move_toward(_y, want, 4.0 * delta)
	var bob := 0.0 if phase >= 3 else sin(_t * 1.2) * 0.4
	_cloud.position.y = _y + bob
	if phase < 3:
		_cloud.rotation.y = sin(_t * 0.5) * 0.25
	else:
		_cloud.rotation.y = move_toward(_cloud.rotation.y, 0.0, delta)
	if phase == 1:
		_strike_timer -= delta
		if _strike_timer <= 0.0:
			_strike_timer = strike_interval
			_strike()
		var left := 0
		for r in get_tree().get_nodes_in_group("boss_rod"):
			if is_instance_valid(r) and not r.is_queued_for_deletion():
				left += 1
		if left == 0:
			_hit()
	elif phase == 2:
		_strike_timer -= delta
		if _strike_timer <= 0.0:
			_strike_timer = strike_interval * 1.6
			_strike()
	elif phase == 3:
		_check_energy()
	if _beam:
		_beam.scale.x = maxf(_beam.scale.x - delta * 0.8, 0.0)
		_beam.scale.z = _beam.scale.x


func _strike() -> void:
	if not _bip:
		return
	var at := _bip.global_position + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
	at.y = _bip.last_floor_y
	var l := load("res://scripts/boss/lightning.gd").new() as Node3D
	get_parent().add_child(l)
	l.global_position = at


## Aşama 3: Bip tacın üstündeyken Yetenek tuşu → enerji ver.
func _check_energy() -> void:
	if _calm or not _bip or not _bip.is_on_floor():
		return
	var top := crown_top()
	var p := _bip.global_position
	if Vector2(p.x - top.x, p.z - top.z).length() < 2.2 and absf(p.y - top.y) < 0.6:
		if Input.is_action_just_pressed("ability"):
			_give_energy()


func _give_energy() -> void:
	_calm = true
	Sfx.play("core")
	Haptics.vibrate(200)
	var from := _bip.global_position + Vector3.UP * 1.3
	var to := _cloud.global_position
	var cyl := CylinderMesh.new()
	cyl.radial_segments = 16
	cyl.rings = 1
	cyl.top_radius = 0.18
	cyl.bottom_radius = 0.18
	cyl.height = 1.0
	_beam = AbilityModels.mesh_node(cyl, AbilityModels.mat(Color(0.4, 1.0, 0.9), 0.2, 6.0))
	get_parent().add_child(_beam)
	_beam.global_position = (from + to) * 0.5
	var dir := (to - from).normalized()
	_beam.basis = Basis(Quaternion(Vector3.UP, dir)) if absf(dir.dot(Vector3.UP)) < 0.999 else Basis()
	_beam.scale = Vector3(1, from.distance_to(to), 1)
	Fx.burst(to, Color(0.4, 1.0, 0.9), 30, 6.0)
	_hit()


func _hit() -> void:
	if phase < 1 or phase > 3:
		return
	Sfx.play("break", 2.0, 0.6)
	Haptics.vibrate(150)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam:
		cam.shake(0.5)
	var lm: StandardMaterial3D = _lights[phase - 1]
	lm.emission_energy_multiplier = 0.0
	lm.albedo_color = Color(0.2, 0.2, 0.2)
	phase += 1
	var lvl := get_tree().current_scene
	if phase <= 3:
		_set_phase_nodes(phase)
		if lvl and lvl.has_method("boss_phase"):
			lvl.boss_phase(phase)
	else:
		_defeat()


## Aşamaya ait nesneler yalnızca o aşamada görünür. Taç yalnızca 3. aşamada metaldir.
func _set_phase_nodes(p: int) -> void:
	for k in _phase_nodes:
		var on: bool = k == p
		for n in _phase_nodes[k]:
			if not is_instance_valid(n):
				continue
			n.visible = on
			n.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED)
			if n is Area3D:
				n.set_deferred("monitoring", on)
			if n is CollisionObject3D:
				for c in n.get_children():
					if c is CollisionShape3D:
						c.set_deferred("disabled", not on)
	if p == 3:
		_crown.add_to_group("metal")
	else:
		_crown.remove_from_group("metal")


func on_event(what: String) -> void:
	if what == "switch" and phase == 2:
		_hit()


## Statik sakinleşir: pembeye döner, kıvılcımlar söner, son Çekirdek Pil düşer.
func _defeat() -> void:
	phase = 4
	_crown.remove_from_group("metal")
	_sparks.emitting = false
	var tw := create_tween().set_parallel(true)
	for m in _cloud_mats:
		tw.tween_property(m, "albedo_color", Color(1.0, 0.72, 0.85), 1.5)
		tw.tween_property(m, "emission", Color(1.0, 0.72, 0.85), 1.5)
	await tw.finished
	defeated.emit()
	var lvl := get_tree().current_scene
	if lvl and lvl.has_method("boss_defeated"):
		lvl.boss_defeated(global_position + Vector3(0, 1.0, 6.0))
