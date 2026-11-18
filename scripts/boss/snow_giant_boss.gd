extends Node3D
## Patron: Kardan Dev (Bölüm 3). Hazır model yok; parçalardan kurulur (D-010):
## üst üste üç kar topu, Quaternius kaya kollar, havuç burun, kömür gözler, buz taç.
## Aşama 1 (Buz):  dev kartopu atar; Zıpzıp'ları dondurup basamak yap, devin yere dayalı
##                 kaya yumruğunun üstüne çık.
## Aşama 2 (Buz):  gölün üstünde Buz ile yürü, adadaki şalteri indir.
## Aşama 3 (Pervane + Kaya): yumruktan Pervane ile başın yanındaki buz tüneğe yüksel,
##                 orada Kaya kopyala, başın üstüne çakıl → Çekirdek Pil.
## API Hurdacı Vinç ile aynı: start_fight(), on_event(), "boss_phase" grubu, alan yöneticisi.

signal defeated

@export var throw_interval := 2.2    ## s, kartopu atma aralığı

const FIST_POS := Vector3(4.6, 0, 0)   ## kaya yumruk merkezi (yerel)
const FIST_TOP := 3.2                  ## yumruk üstü yüksekliği (m): buz kütlesi (1,3) + zıplama ile ulaşılır
const HEAD_Y := 9.3                    ## baş merkezinin yüksekliği
const HEAD_R := 1.4

const PHASE_HINTS := [
	"Zıpzıpları Buz ile dondur; buz bloklarına basıp devin yumruğuna çık!",
	"Buz'u kopyala, gölün üstünde yürüyüp adadaki şalteri indir!",
	"Pervane ile devin başının üstüne yüksel, Kaya ile başına çakıl!",
]

var phase := 0          # 0 giriş, 1, 2, 3, 4 = yenildi
var _t := 0.0
var _throw_timer := 2.0
var _bip: Bip
var _lights: Array = []
var _body_root: Node3D
var _head: Node3D
var _snow_mat: StandardMaterial3D
var _fist_area: Area3D
var _hit_cooldown := 0.0
var _phase_nodes := {}
var _arm_r: Node3D


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


func _sphere(r: float, m: Material, pos: Vector3, parent: Node3D) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 24
	s.rings = 12
	var mi := AbilityModels.mesh_node(s, m, pos)
	parent.add_child(mi)
	return mi


func _build() -> void:
	_snow_mat = AbilityModels.mat(Color(0.96, 0.98, 1.0), 0.8)
	var coal := AbilityModels.mat(Color(0.08, 0.08, 0.1), 0.6)
	_body_root = Node3D.new()
	add_child(_body_root)
	# Gövde: üç kar topu
	_sphere(2.6, _snow_mat, Vector3(0, 2.4, 0), _body_root)
	_sphere(1.9, _snow_mat, Vector3(0, 6.3, 0), _body_root)
	_head = Node3D.new()
	_head.position = Vector3(0, HEAD_Y, 0)
	_body_root.add_child(_head)
	_sphere(HEAD_R, _snow_mat, Vector3.ZERO, _head)
	# Kömür gözler (kızgın kırmızı parıltı) ve düğmeler
	var eye := AbilityModels.mat(Color(1.0, 0.3, 0.25), 0.3, 2.5)
	for sx in [-0.5, 0.5]:
		_sphere(0.2, coal, Vector3(sx, 0.35, 1.25), _head)
		_sphere(0.08, eye, Vector3(sx, 0.38, 1.42), _head)
	for i in 3:
		_sphere(0.22, coal, Vector3(0, 5.4 + i * 0.75, 1.75 - absf(i - 1) * 0.15), _body_root)
	# Havuç burun
	var nose := CylinderMesh.new()
	nose.radial_segments = 16
	nose.rings = 1
	nose.top_radius = 0.0
	nose.bottom_radius = 0.22
	nose.height = 1.0
	var nmi := AbilityModels.mesh_node(nose, AbilityModels.mat(Color(1.0, 0.5, 0.12), 0.5), Vector3(0, 0, 1.75), Vector3(PI / 2, 0, 0))
	_head.add_child(nmi)
	# Buz taç
	var crown_m := AbilityModels.mat(Color(0.65, 0.9, 1.0, 0.85), 0.05, 0.8)
	crown_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for i in 6:
		var a := TAU * i / 6.0
		var spike := CylinderMesh.new()
		spike.top_radius = 0.0
		spike.bottom_radius = 0.22
		spike.height = 0.8
		spike.radial_segments = 5
		_head.add_child(AbilityModels.mesh_node(spike, crown_m, Vector3(cos(a) * 0.95, 1.3, sin(a) * 0.95), Vector3(sin(a) * 0.3, 0, -cos(a) * 0.3)))
	# Can ışıkları (taçta 3 parlayan kristal)
	for i in 3:
		var lm := AbilityModels.mat(Color(0.4, 0.95, 1.0), 0.2, 3.0)
		_sphere(0.2, lm, Vector3(-0.6 + i * 0.6, 1.25, 0.9), _head)
		_lights.append(lm)
	# Kaya kollar: sağ kol yere dayalı yumruk (aşama 1'in hedefi), sol kol havada
	var rock: PackedScene = load("res://assets/models/quaternius/platformer/Rock_1.gltf")
	_arm_r = Node3D.new()
	_body_root.add_child(_arm_r)
	for i in 3:
		var r: Node3D = rock.instantiate()
		var t := i / 2.0
		r.position = Vector3(lerpf(1.8, FIST_POS.x, t), lerpf(5.6, 1.7, t), 0)
		r.scale = Vector3.ONE * (0.9 + t * 0.6)
		r.rotation = Vector3(t, i * 1.3, 0.4)
		_arm_r.add_child(r)
	var arm_l := Node3D.new()
	_body_root.add_child(arm_l)
	for i in 3:
		var r: Node3D = rock.instantiate()
		r.position = Vector3(-1.9 - i * 0.9, 6.0 + i * 0.6, 0.2)
		r.scale = Vector3.ONE * 0.8
		r.rotation = Vector3(0, i, 0.5)
		arm_l.add_child(r)
	# Katı gövde (içinden geçilmez) + yumruk üstü + baş üstü
	var body := StaticBody3D.new()
	add_child(body)
	for spec in [[Vector3(0, 2.4, 0), 2.4], [Vector3(0, 6.3, 0), 1.75]]:
		var cs := CollisionShape3D.new()
		var sh := SphereShape3D.new()
		sh.radius = spec[1]
		cs.shape = sh
		cs.position = spec[0]
		body.add_child(cs)
	var fist := CollisionShape3D.new()
	var fb := BoxShape3D.new()
	fb.size = Vector3(2.4, FIST_TOP, 2.4)
	fist.shape = fb
	fist.position = FIST_POS + Vector3(0, FIST_TOP / 2, 0)
	body.add_child(fist)
	var head_top := CollisionShape3D.new()
	var hb := BoxShape3D.new()
	hb.size = Vector3(2.2, 0.4, 2.2)
	head_top.shape = hb
	head_top.position = Vector3(0, HEAD_Y + HEAD_R - 0.2, 0)
	body.add_child(head_top)
	var head_body := CollisionShape3D.new()
	var hs := SphereShape3D.new()
	hs.radius = HEAD_R - 0.05
	head_body.shape = hs
	head_body.position = Vector3(0, HEAD_Y, 0)
	body.add_child(head_body)
	# Yumruk görünüşü: kar kaplı kaya blok
	var fm := BoxMesh.new()
	fm.size = Vector3(2.4, FIST_TOP, 2.4)
	add_child(AbilityModels.mesh_node(fm, AbilityModels.mat(Color(0.55, 0.52, 0.5), 0.9), FIST_POS + Vector3(0, FIST_TOP / 2, 0)))
	var cap := BoxMesh.new()
	cap.size = Vector3(2.5, 0.25, 2.5)
	add_child(AbilityModels.mesh_node(cap, _snow_mat, FIST_POS + Vector3(0, FIST_TOP - 0.05, 0)))
	# Yumruk üstüne çıkışı algılayan alan (aşama 1)
	_fist_area = Area3D.new()
	_fist_area.collision_layer = 0
	_fist_area.collision_mask = 1
	var fa := CollisionShape3D.new()
	var fab := BoxShape3D.new()
	fab.size = Vector3(2.4, 1.2, 2.4)
	fa.shape = fab
	fa.position = FIST_POS + Vector3(0, FIST_TOP + 0.6, 0)
	_fist_area.add_child(fa)
	add_child(_fist_area)


func start_fight() -> void:
	if phase == 0:
		phase = 1
		_throw_timer = 1.5


func _physics_process(delta: float) -> void:
	_t += delta
	_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
	# Hafif sallanma: dev nefes alıyor
	_body_root.rotation.z = sin(_t * 0.9) * 0.025
	_head.rotation.y = sin(_t * 0.7) * 0.25
	if phase == 0 or phase >= 4:
		return
	_throw_timer -= delta
	if _throw_timer <= 0.0:
		_throw_timer = throw_interval * (1.4 if phase == 3 else 1.0)
		_throw_snowball()
	if phase == 1 and _hit_cooldown <= 0.0:
		for b in _fist_area.get_overlapping_bodies():
			if b is Bip and b.is_on_floor():
				_hit()
				b.bounce(9.0)
				break


func _throw_snowball() -> void:
	if not _bip:
		return
	# Bip devin yakınında (yumruk/baş çevresinde) değilse at
	var at := _bip.global_position + Vector3(randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0))
	at.y = _bip.last_floor_y
	if Vector2(at.x - global_position.x, at.z - global_position.z).length() < 3.5:
		return
	var s := load("res://scripts/boss/snowball.gd").new() as Node3D
	get_parent().add_child(s)
	s.global_position = at
	Sfx.play("glide", -8.0, 0.6)


func _hit() -> void:
	_hit_cooldown = 1.5
	Sfx.play("break", 2.0, 0.6)
	Sfx.play("glass", 0.0, 0.7)
	Haptics.vibrate(150)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam:
		cam.shake(0.6)
	var lm: StandardMaterial3D = _lights[phase - 1]
	lm.emission_energy_multiplier = 0.0
	lm.albedo_color = Color(0.2, 0.25, 0.3)
	var tw := create_tween()
	tw.tween_property(_snow_mat, "albedo_color", Color(0.6, 0.85, 1.0), 0.06)
	tw.tween_property(_snow_mat, "albedo_color", Color(0.96, 0.98, 1.0), 0.35)
	tw.parallel().tween_property(_body_root, "scale", Vector3(1.06, 0.94, 1.06), 0.1)
	tw.tween_property(_body_root, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC)
	phase += 1
	var lvl := get_tree().current_scene
	if phase <= 3:
		_set_phase_nodes(phase)
		if lvl and lvl.has_method("boss_phase"):
			lvl.boss_phase(phase)
	else:
		_defeat()


## Aşamaya ait nesneler (düşmanlar, şalter, yetenek kaynakları) yalnızca o aşamada etkin.
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


## Aşama 2: adadaki şalter indirildi.
func on_event(what: String) -> void:
	if what == "switch" and phase == 2:
		_hit()


## Aşama 3: Kaya ile başın üstüne çakılma.
func _on_bip_pounded(at: Vector3) -> void:
	var top := global_position + Vector3(0, HEAD_Y + HEAD_R, 0)
	if phase == 3 and Vector2(at.x - top.x, at.z - top.z).length() < 2.2 and absf(at.y - top.y) < 1.3:
		_hit()


func _defeat() -> void:
	phase = 4
	Sfx.play("core")
	# Dev erir: küçülüp çöker, Çekirdek Pil baştan düşer
	var tw := create_tween()
	tw.tween_property(_body_root, "scale", Vector3(1.3, 0.15, 1.3), 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_head, "position:y", 1.0, 1.6)
	await tw.finished
	for c in get_children():
		if c is StaticBody3D:
			c.queue_free()
	defeated.emit()
	var lvl := get_tree().current_scene
	if lvl and lvl.has_method("boss_defeated"):
		lvl.boss_defeated(global_position + Vector3(0, 1.2, 3.5))


## Sıradaki hedef(ler): alan yöneticisi üstlerine ok koyar.
func goal_nodes() -> Array:
	match phase:
		1:
			return [_fist_area]
		3:
			return [_head]
	return []
