extends Node3D
## Patron: Hurdacı Vinç (Bölüm 1). Hazır model bulunmadığı için parçalardan kurulur (D-010).
## Aşama 1 (Yay):    düşen hurdalardan kaç, kanca alçalınca Yay ile kancanın üstüne zıpla.
## Aşama 2 (Balon):  rüzgâr kollarının arasından Balon ile süzülüp adadaki şalteri indir.
## Aşama 3 (Mıknatıs + Kaya): kuledeki metal bloklara Mıknatısla tırman, tepede Kaya kopyala,
##                   kabinin çatısına çakıl → Çekirdek Pil düşer.

signal defeated

@export var tower_height := 13.0
@export var boom_length := 11.0
@export var hook_low_y := 3.6        ## kancanın inip beklediği yükseklik (plaka üstü), Yay ile ulaşılır
@export var scrap_interval := 1.6    ## s

var phase := 0          # 0 giriş, 1, 2, 3, 4 = yenildi
var _t := 0.0
var _boom: Node3D
var _hook: AnimatableBody3D
var _hook_target := Vector3.ZERO
var _hook_state := 0    # 0 yukarıda, 1 iniyor, 2 bekliyor, 3 çıkıyor
var _hook_timer := 0.0
var _cabin: Node3D
var _lights: Array = []
var _scrap_timer := 2.0
var _cell: MeshInstance3D
var _roof_hit := false
var _bip: Bip
var _body_mat: StandardMaterial3D
var _phase_nodes := {}


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


func _on_bip_pounded(at: Vector3) -> void:
	var roof_pos := _cabin.global_position + Vector3(0, 2.3, 0)
	if phase == 3 and Vector2(at.x - roof_pos.x, at.z - roof_pos.z).length() < 2.4 and absf(at.y - roof_pos.y) < 1.2:
		on_roof_pound()


func _build() -> void:
	_body_mat = AbilityModels.mat(Color(0.95, 0.65, 0.15), 0.5)
	var dark := AbilityModels.mat(Color(0.25, 0.27, 0.32), 0.6)
	# Taban ve kule
	var base := CylinderMesh.new()
	base.radial_segments = 16
	base.rings = 1
	base.top_radius = 3.0
	base.bottom_radius = 3.4
	base.height = 1.0
	add_child(AbilityModels.mesh_node(base, dark, Vector3(0, 0.5, 0)))
	var body := StaticBody3D.new()
	add_child(body)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(2.2, tower_height, 2.2)
	cs.shape = bs
	cs.position.y = tower_height / 2
	body.add_child(cs)
	var tower := BoxMesh.new()
	tower.size = Vector3(2.2, tower_height, 2.2)
	add_child(AbilityModels.mesh_node(tower, _body_mat, Vector3(0, tower_height / 2, 0)))
	for i in int(tower_height / 1.5):
		var bar := BoxMesh.new()
		bar.size = Vector3(2.3, 0.15, 2.3)
		add_child(AbilityModels.mesh_node(bar, dark, Vector3(0, 0.8 + i * 1.5, 0), Vector3(0, 0, 0.6 if i % 2 == 0 else -0.6)))
	# Dönen bom + kabin
	_boom = Node3D.new()
	_boom.position.y = tower_height
	add_child(_boom)
	var arm := BoxMesh.new()
	arm.size = Vector3(1.2, 1.0, boom_length + 4.0)
	_boom.add_child(AbilityModels.mesh_node(arm, _body_mat, Vector3(0, 0.5, -(boom_length - 4.0) / 2)))
	var cw := BoxMesh.new()
	cw.size = Vector3(2.0, 1.6, 2.0)
	_boom.add_child(AbilityModels.mesh_node(cw, dark, Vector3(0, 0.6, 3.2)))
	# Kabin (çatısı aşama 3'te Kaya ile kırılır)
	_cabin = Node3D.new()
	_cabin.position = Vector3(0, 1.0, 0.5)
	_boom.add_child(_cabin)
	var cab := BoxMesh.new()
	cab.size = Vector3(2.4, 2.0, 2.4)
	_cabin.add_child(AbilityModels.mesh_node(cab, _body_mat, Vector3(0, 1.0, 0)))
	var win := BoxMesh.new()
	win.size = Vector3(1.8, 0.8, 0.05)
	var eye := AbilityModels.mat(Color(1.0, 0.3, 0.2), 0.3, 2.5)
	_cabin.add_child(AbilityModels.mesh_node(win, eye, Vector3(0, 1.3, -1.22)))
	# Kabin çatısı: katı zemin (Bip üstüne iner)
	var roof := StaticBody3D.new()
	_cabin.add_child(roof)
	var rs := CollisionShape3D.new()
	var rb := BoxShape3D.new()
	rb.size = Vector3(3.4, 0.3, 3.4)
	rs.shape = rb
	rs.position.y = 2.15
	roof.add_child(rs)
	var roofm := BoxMesh.new()
	roofm.size = Vector3(3.4, 0.3, 3.4)
	_cabin.add_child(AbilityModels.mesh_node(roofm, AbilityModels.mat(Color(0.72, 0.62, 0.5)), Vector3(0, 2.15, 0)))
	# Can ışıkları (3 aşama)
	for i in 3:
		var l := SphereMesh.new()
		l.radial_segments = 12
		l.rings = 6
		l.radius = 0.18
		l.height = 0.36
		var lm := AbilityModels.mat(Color(1.0, 0.85, 0.2), 0.3, 3.0)
		var li := AbilityModels.mesh_node(l, lm, Vector3(-0.7 + i * 0.7, 2.5, 0))
		_cabin.add_child(li)
		_lights.append(lm)
	# Boma çıkılabilen yürüyüş yolu (aşama 3'te Kaya burada)
	var walk := StaticBody3D.new()
	_boom.add_child(walk)
	var ws := CollisionShape3D.new()
	var wb := BoxShape3D.new()
	wb.size = Vector3(1.2, 1.0, boom_length + 4.0)
	ws.shape = wb
	ws.position = Vector3(0, 0.5, -(boom_length - 4.0) / 2)
	walk.add_child(ws)
	# Kanca: hareketli plaka, altında parlayan Çekirdek Pil
	_hook = AnimatableBody3D.new()
	_hook.sync_to_physics = true
	add_child(_hook)
	var hs := CollisionShape3D.new()
	var hb := BoxShape3D.new()
	hb.size = Vector3(2.6, 0.4, 2.6)
	hs.shape = hb
	_hook.add_child(hs)
	var plate := BoxMesh.new()
	plate.size = Vector3(2.6, 0.4, 2.6)
	_hook.add_child(AbilityModels.mesh_node(plate, dark))
	var stripe := BoxMesh.new()
	stripe.size = Vector3(2.65, 0.12, 2.65)
	_hook.add_child(AbilityModels.mesh_node(stripe, AbilityModels.mat(Color(1, 0.85, 0.2), 0.4, 0.6), Vector3(0, 0.15, 0)))
	var cellm := CylinderMesh.new()
	cellm.radial_segments = 16
	cellm.rings = 1
	cellm.top_radius = 0.4
	cellm.bottom_radius = 0.4
	cellm.height = 1.0
	_cell = AbilityModels.mesh_node(cellm, AbilityModels.mat(Color(0.4, 1.0, 0.9), 0.3, 3.5), Vector3(0, -0.8, 0))
	_hook.add_child(_cell)
	var glow := OmniLight3D.new()
	glow.light_color = Color(0.4, 1.0, 0.9)
	glow.light_energy = 2.0
	glow.omni_range = 6.0
	glow.position.y = -0.8
	_hook.add_child(glow)
	_hook.position = _hook_top_pos()


func _hook_top_pos() -> Vector3:
	var tip := _boom.global_transform * Vector3(0, -0.2, -boom_length) if is_inside_tree() else Vector3(0, tower_height - 0.2, -boom_length)
	return to_local(tip) if is_inside_tree() else tip


func start_fight() -> void:
	if phase == 0:
		phase = 1
		_hook_state = 0
		_hook_timer = 2.0


func _physics_process(delta: float) -> void:
	_t += delta
	if phase == 0 or phase >= 4:
		_update_hook(delta)
		return
	# Bom döner; aşamaya göre hızlanır
	var spin: float = [0.0, 0.25, 0.45, 0.2][phase]
	if _hook_state == 0 or phase != 1:
		_boom.rotation.y += spin * delta
	_update_hook(delta)
	if phase == 1:
		_scrap_timer -= delta
		if _scrap_timer <= 0.0:
			_scrap_timer = scrap_interval
			_drop_scrap()
		_check_hook_landing()


func _update_hook(delta: float) -> void:
	var top := _hook_top_pos()
	match _hook_state:
		0:
			_hook.position = top
			if phase == 1:
				_hook_timer -= delta
				if _hook_timer <= 0.0:
					_hook_state = 1
		1:
			_hook.position = _hook.position.move_toward(Vector3(top.x, hook_low_y - 0.2, top.z), 7.0 * delta)
			if _hook.position.y <= hook_low_y - 0.15:
				_hook_state = 2
				_hook_timer = 3.5
				Sfx.play("drop", -2.0, 0.6)
		2:
			_hook.position = Vector3(top.x, hook_low_y - 0.2 + sin(_t * 3.0) * 0.05, top.z)
			_hook_timer -= delta
			if _hook_timer <= 0.0:
				_hook_state = 3
		3:
			_hook.position = _hook.position.move_toward(top, 5.0 * delta)
			if _hook.position.distance_to(top) < 0.1:
				_hook_state = 0
				_hook_timer = 4.0
	_cell.rotation.y += delta * 2.0


## Aşama 1: Bip kancanın üstüne inerse vinç sarsılır.
func _check_hook_landing() -> void:
	if not _bip or _hook_state == 0:
		return
	if _bip.is_on_floor():
		var c := _bip.get_last_slide_collision()
		if c and c.get_collider() == _hook:
			_hit()
			_bip.bounce(12.0)
			_bip.velocity += (_bip.global_position - global_position).normalized() * Vector3(1, 0, 1) * 6.0
			_hook_state = 3


func _drop_scrap() -> void:
	if not _bip:
		return
	var at := _bip.global_position + Vector3(randf_range(-2.5, 2.5), 0, randf_range(-2.5, 2.5))
	at.y = _bip.last_floor_y
	var s := load("res://scripts/boss/scrap.gd").new() as Node3D
	get_parent().add_child(s)
	s.global_position = at


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
	tw.tween_property(_body_mat, "albedo_color", Color(1, 1, 1), 0.06)
	tw.tween_property(_body_mat, "albedo_color", Color(0.95, 0.65, 0.15), 0.3)
	tw.parallel().tween_property(self, "rotation:z", 0.06, 0.1)
	tw.tween_property(self, "rotation:z", 0.0, 0.4).set_trans(Tween.TRANS_ELASTIC)
	phase += 1
	var lvl := get_tree().current_scene
	if phase <= 3:
		_set_phase_nodes(phase)
		if lvl and lvl.has_method("boss_phase"):
			lvl.boss_phase(phase)
	else:
		_defeat()


## Aşamaya ait nesneler (yetenek kaynakları, şalter, metal bloklar) yalnızca o aşamada görünür.
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
			if n.is_in_group("metal_phase"):
				if on:
					n.add_to_group("metal")
				else:
					n.remove_from_group("metal")


## Aşama 2: şalter indirildi (tetikleyiciden).
func on_event(what: String) -> void:
	if what == "switch" and phase == 2:
		_hit()


## Aşama 3: Kaya ile kabin çatısına çakılınca (Bip'in pounded sinyali, alan yöneticisinden).
func on_roof_pound() -> void:
	if phase == 3 and not _roof_hit:
		_roof_hit = true
		_hit()


func _defeat() -> void:
	phase = 4
	Sfx.play("core")
	# Vinç çöker, kanca düşer, Çekirdek Pil yere iner
	var tw := create_tween()
	tw.tween_property(_boom, "rotation:x", -0.35, 1.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	var drop := _hook.position
	drop.y = 0.6
	tw.parallel().tween_property(_hook, "position", drop, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_hook_state = 99
	await tw.finished
	defeated.emit()
	var lvl := get_tree().current_scene
	if lvl and lvl.has_method("boss_defeated"):
		lvl.boss_defeated(_hook.global_position + Vector3(0, 1.0, 0))
