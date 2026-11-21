extends Node3D
## Patron: Paslı Kaptan (Bölüm 2). Görünüş: fanuslu balık robot (Pixabay, bkz. CREDITS.md);
## oynanış parçaları (çapa kolu, can ışıkları, metal şapka) koddan kurulur.
## Aşama 1 (Pervane): dev çapa güvertede döner; çapanın üstünden atla/atıl, direğin tepesindeki
##                    çana Pervane ile çık (tetikleyici "mast").
## Aşama 2 (Kaya):    güverteye düşen üç fıçıyı Kaya ile ez → kalkan iner.
## Aşama 3 (Mıknatıs + Kaya): kaptanın metal şapkasına Mıknatısla çekil, şapkanın üstündeki
##                    Kaya'yı kopyala, şapkaya çakıl → Çekirdek Pil düşer.
## API, Hurdacı Vinç ile aynı (scripts/boss/crane_boss.gd).

signal defeated

@export var boss_name := "Paslı Kaptan"
@export var body_height := 6.0
@export var sweep_radius := 10.0       ## çapa kolunun uzunluğu
@export var sweep_speed := 1.1         ## rad/s (aşama 1)

const PHASE_HINTS := [
	"Pervane'yi kopyala, direğin tepesindeki gözcü yerine uç!",
	"Kaya'yı kopyala, güverteye düşen 3 sandığı kır (üstüne zıpla ya da çakıl)!",
	"Mıknatısla kaptanın şapkasına çekil, tepedeki Kaya ile şapkaya çakıl!",
]

var phase := 0
var _t := 0.0
var _bip: Bip
var _lights: Array = []
var _sweeper: Node3D
var _sweep_area: Area3D
var _hat: StaticBody3D
var _barrels: Array = []
var _phase_nodes := {}
var _eye: MeshInstance3D       ## fanustaki balık
var _model: Node3D
var _flash: StandardMaterial3D
var _fish_rot := Vector3.ZERO
var _fish_pos := Vector3.ZERO
var _hat_hit := false


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
	if _bip:
		_bip.pounded.connect(_on_bip_pounded)


func _build() -> void:
	var iron := AbilityModels.mat(Color(0.35, 0.37, 0.42), 0.4)
	iron.metallic = 0.6
	# Gövde: çarpışma silindiri (görünmez)
	var body := StaticBody3D.new()
	add_child(body)
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 2.0
	cyl.height = body_height
	cs.shape = cyl
	cs.position.y = body_height / 2
	body.add_child(cs)
	# Görünüş: fanuslu balık robot (Pixabay "Fish mecha robot alien", bkz. CREDITS.md).
	# Fanusun içindeki balık (_eye) yüzer; vuruşta bütün model beyaz parlar.
	_model = load("res://assets/models/pixabay/fish_mecha.glb").instantiate()
	_model.scale = Vector3.ONE * (body_height / 5.85)
	add_child(_model)
	_flash = StandardMaterial3D.new()
	_flash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_flash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_flash.albedo_color = Color(1, 1, 1, 0.0)
	for mi in _model.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).material_overlay = _flash
		if mi.name == "Fish":
			_eye = mi
	_fish_rot = _eye.rotation
	_fish_pos = _eye.position
	# Can ışıkları (3)
	for i in 3:
		var l := SphereMesh.new()
		l.radial_segments = 12
		l.rings = 6
		l.radius = 0.2
		l.height = 0.4
		var lm := AbilityModels.mat(Color(1.0, 0.85, 0.2), 0.3, 3.0)
		add_child(AbilityModels.mesh_node(l, lm, Vector3(-0.7 + i * 0.7, body_height * 0.3, 1.6)))
		_lights.append(lm)
	# Metal kaptan şapkası: aşama 3'te Mıknatısla yapışılır, üstüne çakılır
	_hat = StaticBody3D.new()
	_hat.set_script(load("res://scripts/entities/metal_block.gd"))
	_hat.size = Vector3(5.0, 1.2, 5.0)
	_hat.position = Vector3(0, body_height + 0.6, 0)
	add_child(_hat)
	var badge := CylinderMesh.new()
	badge.radial_segments = 16
	badge.rings = 1
	badge.top_radius = 0.35
	badge.bottom_radius = 0.35
	badge.height = 0.1
	add_child(AbilityModels.mesh_node(badge, AbilityModels.mat(Color(1, 0.85, 0.3), 0.2, 1.0), Vector3(0, body_height + 0.6, 2.53), Vector3(PI / 2, 0, 0)))
	# Dönen çapa kolu: güvertede, zıplanarak geçilir
	_sweeper = Node3D.new()
	add_child(_sweeper)
	var chain := BoxMesh.new()
	chain.size = Vector3(0.5, 0.5, sweep_radius - 2.0)
	_sweeper.add_child(AbilityModels.mesh_node(chain, iron, Vector3(0, 0.4, -(sweep_radius + 2.0) / 2)))
	var anchor: Node3D = load("res://assets/models/quaternius/platformer/Hazard_Saw.gltf").instantiate()
	anchor.scale = Vector3.ONE * 0.5
	anchor.position = Vector3(0, 0.75, -sweep_radius)
	_sweeper.add_child(anchor)
	_sweep_area = Area3D.new()
	_sweep_area.collision_layer = 0
	_sweep_area.collision_mask = 1
	var sa := CollisionShape3D.new()
	var sb := BoxShape3D.new()
	sb.size = Vector3(0.7, 0.8, sweep_radius - 1.6)
	sa.shape = sb
	sa.position = Vector3(0, 0.4, -(sweep_radius + 1.6) / 2)
	_sweep_area.add_child(sa)
	_sweeper.add_child(_sweep_area)
	_sweeper.visible = false


func start_fight() -> void:
	if phase == 0:
		phase = 1
		_sweeper.visible = true


func _physics_process(delta: float) -> void:
	_t += delta
	if phase < 1 or phase >= 4:
		return
	# Fanustaki balık yüzer, robot gövdesi hafifçe sallanır
	_eye.rotation.y = _fish_rot.y + sin(_t * 1.6) * 0.7
	_eye.position.y = _fish_pos.y + sin(_t * 2.3) * 0.06
	_model.position.y = sin(_t * 2.0) * 0.08
	_model.rotation.z = sin(_t * 1.1) * 0.03
	# İkinci saldırı (2026-11-22): güverteye aralıklı varil/hurda düşer; 2. aşamada sıra hâlinde
	_drop_t -= delta
	if _drop_t <= 0.0 and (phase == 1 or phase == 2):
		_drop_t = DROP_INTERVAL
		var bp := get_tree().get_first_node_in_group("player") as Bip
		if bp and Vector2(bp.global_position.x - global_position.x, bp.global_position.z - global_position.z).length() > 3.5:
			var at := Vector3(bp.global_position.x, bp.last_floor_y, bp.global_position.z)
			_attack_n += 1
			if phase == 2 and _attack_n % BossPatterns.EVERY == 0:
				BossPatterns.volley(get_parent(), "res://scripts/boss/scrap.gd", "line", global_position, at)
			else:
				var s := load("res://scripts/boss/scrap.gd").new() as Node3D
				get_parent().add_child(s)
				s.global_position = at + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
	var spd: float = [0.0, sweep_speed, sweep_speed * 0.6, 0.0][phase]
	_sweeper.rotation.y += spd * delta
	if spd > 0.0:
		for b in _sweep_area.get_overlapping_bodies():
			if b is Bip:
				b.take_hit(b.global_position - _sweeper.global_basis.x)
	if phase == 2:
		_barrels = _barrels.filter(func(x): return is_instance_valid(x))
		if _barrels.is_empty():
			_hit()


const DROP_INTERVAL := 3.2       ## s
var _drop_t := 4.0
var _attack_n := 0


func _spawn_barrels() -> void:
	var crate_script := load("res://scripts/entities/crate.gd")
	for i in 3:
		var a := TAU * i / 3.0 + 0.5
		var b := StaticBody3D.new()
		b.set_script(crate_script)
		b.batteries = 2
		b.name = "Fici%d" % i
		get_parent().add_child(b)
		var dest := global_position + Vector3(cos(a), 0, sin(a)) * 6.5
		b.global_position = dest + Vector3.UP * 12.0
		var tw := b.create_tween()
		tw.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tw.tween_property(b, "global_position", dest, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_barrels.append(b)


func _hit() -> void:
	Sfx.play("break", 2.0, 0.6)
	Haptics.vibrate(150)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam:
		cam.shake(0.6)
	var lm: StandardMaterial3D = _lights[phase - 1]
	lm.emission_energy_multiplier = 0.0
	lm.albedo_color = Color(0.2, 0.2, 0.2)
	var tw := create_tween()
	tw.tween_property(_flash, "albedo_color:a", 0.75, 0.06)
	tw.tween_property(_flash, "albedo_color:a", 0.0, 0.3)
	tw.parallel().tween_property(self, "rotation:z", 0.06, 0.1)
	tw.tween_property(self, "rotation:z", 0.0, 0.4).set_trans(Tween.TRANS_ELASTIC)
	phase += 1
	var lvl := get_tree().current_scene
	if phase <= 3:
		_set_phase_nodes(phase)
		if phase == 2:
			_spawn_barrels()
		if lvl and lvl.has_method("boss_phase"):
			lvl.boss_phase(phase)
	else:
		_defeat()


## Aşamaya ait nesneler yalnızca o aşamada görünür/çalışır. Şapka yalnızca 3. aşamada metaldir.
func _set_phase_nodes(p: int) -> void:
	for k in _phase_nodes:
		var on: bool = k == p
		for n in _phase_nodes[k]:
			n.visible = on
			n.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED)
			if n is Area3D:
				n.set_deferred("monitoring", on)
			if n is CollisionObject3D:
				for c in n.get_children():
					if c is CollisionShape3D:
						c.set_deferred("disabled", not on)
	if p == 3:
		_hat.add_to_group("metal")
	else:
		_hat.remove_from_group("metal")


## Aşama 1: direğin tepesindeki tetikleyici.
func on_event(what: String) -> void:
	if what == "mast" and phase == 1:
		_hit()


func _on_bip_pounded(at: Vector3) -> void:
	var top := _hat.global_position + Vector3(0, 0.6, 0)
	if phase == 3 and not _hat_hit and Vector2(at.x - top.x, at.z - top.z).length() < 2.8 and absf(at.y - top.y) < 1.2:
		_hat_hit = true
		_hit()


func _defeat() -> void:
	phase = 4
	_sweeper.visible = false
	Sfx.play("core")
	var tw := create_tween()
	tw.tween_property(self, "rotation:x", -0.25, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_eye, "rotation:z", _fish_rot.z + PI * 0.9, 1.0)   # balık şaşkın, ters döner
	await tw.finished
	defeated.emit()
	var lvl := get_tree().current_scene
	if lvl and lvl.has_method("boss_defeated"):
		lvl.boss_defeated(global_position + Vector3(0, 1.0, 5.0))


## Sıradaki hedef(ler): alan yöneticisi üstlerine ok koyar.
func goal_nodes() -> Array:
	match phase:
		2:
			return _barrels.filter(func(x): return is_instance_valid(x))
		3:
			return [_hat]
	return []
