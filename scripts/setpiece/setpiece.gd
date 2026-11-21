class_name SetPiece
extends Area3D
## Tetiklenen "vay" anı: Bip alana ilk girdiğinde bir gösteri oynar (oynanışı engellemez, hasar vermez).
## Türler ve nerede kullanıldıkları: docs/features/vay-anlari/design.md

@export_enum("whale", "skywhale", "eruption", "fireworks", "meteor", "lightning", "balloons", "beacon", "aurora", "crystals") var kind := "whale"
@export var size := Vector3(10, 5, 4)       ## tetik kutusu
@export var offset := Vector3(0, 0, -12)    ## gösterinin merkezi (bu düğüme göre, dünya yönünde)
@export var big := 1.0                      ## gösterinin ölçeği
@export var repeat := 0.0                   ## s; 0 = bir kez, >0 = tetiklendikten sonra bu aralıkla yinelenir

const PARTY := [Color(1.0, 0.85, 0.3), Color(0.4, 0.9, 1.0), Color(1.0, 0.5, 0.7), Color(0.5, 1.0, 0.55), Color(0.8, 0.6, 1.0)]

var played := 0
var _t := 0.0
var _actors: Array = []        # [{node, t, dur, fn}]
var _again := -1.0
var _persist: Node3D


func _ready() -> void:
	add_to_group("setpiece")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	cs.position.y = size.y / 2.0
	add_child(cs)
	body_entered.connect(_on_body)
	set_physics_process(false)


func _on_body(b: Node) -> void:
	if played == 0 and b is Bip:
		play()


func center() -> Vector3:
	return global_position + offset


func play() -> void:
	played += 1
	set_physics_process(true)
	call("_play_" + kind)
	if repeat > 0.0:
		_again = repeat


func _physics_process(delta: float) -> void:
	_t += delta
	for a in _actors.duplicate():
		a["t"] += delta
		var k: float = clampf(a["t"] / a["dur"], 0.0, 1.0)
		if is_instance_valid(a["node"]):
			(a["fn"] as Callable).call(a["node"], k)
		if k >= 1.0:
			if is_instance_valid(a["node"]) and not a.get("keep", false):
				a["node"].queue_free()
			_actors.erase(a)
	if _again > 0.0:
		_again -= delta
		if _again <= 0.0:
			play()
	elif _actors.is_empty() and _persist == null:
		set_physics_process(false)
	if _persist and _persist.has_meta("spin"):
		_persist.rotation.y += delta * float(_persist.get_meta("spin"))


func _act(node: Node3D, dur: float, fn: Callable, delay := 0.0) -> void:
	_actors.append({"node": node, "t": -delay, "dur": dur, "fn": fn})


func _glow(c: Color, energy := 3.0, alpha := 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b, alpha)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = c
	m.emission_energy_multiplier = energy
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _ball(r: float, m: Material) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 10
	s.rings = 5
	var mi := MeshInstance3D.new()
	mi.mesh = s
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func _spawn(n: Node3D, at: Vector3) -> Node3D:
	get_parent().add_child(n)
	n.global_position = at
	return n


func _shake(a: float) -> void:
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("shake"):
		cam.shake(a)


# ---------- Balina: sudan fırlar, yolun üstünden kavisle geçer, geri dalar ----------
func _whale(s: float) -> Node3D:
	var w: Node3D = load("res://assets/models/quaternius/fish/Whale.fbx").instantiate()
	var holder := Node3D.new()
	holder.add_child(w)
	w.scale = Vector3.ONE * s
	w.rotation.y = PI / 2.0
	var ap := w.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if ap and ap.get_animation_list().size() > 0:
		var an: String = ap.get_animation_list()[0]
		ap.get_animation(an).loop_mode = Animation.LOOP_LINEAR
		ap.play(an)
	for mi in w.find_children("*", "MeshInstance3D", true, false):
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(0.32, 0.52, 0.8)
		m.roughness = 0.5
		(mi as MeshInstance3D).material_override = m
	return holder


func _play_whale() -> void:
	var holder := _whale(0.22 * big)
	_spawn(holder, center())
	var c := center()
	var axis := global_basis.x
	var span := 9.0 * big
	var a := c - axis * span
	var b := c + axis * span
	holder.rotation.y = global_rotation.y
	Sfx.play("drop", 0.0, 0.5)
	Fx.burst(a + Vector3.UP, Color(0.85, 0.95, 1.0), 30, 8.0)
	Fx.ring(a, Color(0.85, 0.95, 1.0), 5.0 * big, 0.8)
	_shake(0.25)
	_act(holder, 3.2, func(n: Node3D, k: float):
		n.global_position = a.lerp(b, k) + Vector3.UP * (-3.0 + 13.0 * big * sin(PI * k))
		n.rotation.z = lerpf(0.9, -0.9, k)
		if k >= 1.0:
			Sfx.play("drop", 0.0, 0.45)
			Fx.burst(b + Vector3.UP, Color(0.85, 0.95, 1.0), 30, 8.0)
			Fx.ring(b, Color(0.85, 0.95, 1.0), 5.0 * big, 0.8)
			_shake(0.2))


# ---------- Gök balinası: bulutların arasından ağır ağır süzülür ----------
func _play_skywhale() -> void:
	var holder := _whale(0.6 * big)
	var c := center()
	var axis := global_basis.x
	var a := c - axis * 45.0
	var b := c + axis * 45.0
	_spawn(holder, a)
	holder.rotation.y = global_rotation.y
	Sfx.play("wake", -2.0, 0.45)
	_act(holder, 16.0, func(n: Node3D, k: float):
		n.global_position = a.lerp(b, k) + Vector3.UP * sin(k * TAU * 2.0) * 1.5
		n.rotation.z = sin(k * TAU * 2.0) * 0.12
		if randf() < 0.25:
			Fx.burst(n.global_position - axis * 6.0, Color(1, 1, 1), 1, 1.0))


# ---------- Volkan patlaması: kızgın kayalar fışkırır ----------
func _play_eruption() -> void:
	var c := center()
	Sfx.play("break", 2.0, 0.4)
	_shake(0.55)
	Fx.burst(c, Color(1.0, 0.5, 0.15), 40, 12.0)
	Fx.ring(c, Color(1.0, 0.6, 0.2), 14.0 * big, 0.9, false)
	var flash := _ball(3.0 * big, _glow(Color(1.0, 0.7, 0.3), 6.0, 0.8))
	_spawn(flash, c)
	_act(flash, 0.7, func(n: Node3D, k: float): n.scale = Vector3.ONE * (1.0 + k * 2.0) * (1.0 - k))
	var m := _glow(Color(1.0, 0.45, 0.1), 4.0)
	for i in 26:
		var rock := _ball(randf_range(0.5, 1.3) * big, m)
		_spawn(rock, c)
		var v := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * randf_range(6.0, 16.0) * sqrt(big)
		var up := randf_range(22.0, 34.0) * sqrt(big)
		_act(rock, randf_range(3.0, 4.2), func(n: Node3D, k: float):
			var t := k * 4.0
			n.global_position = c + v * t + Vector3.UP * (up * t - 9.0 * t * t)
			n.scale = Vector3.ONE * (1.0 - k * 0.6), i * 0.09)


# ---------- Havai fişek ----------
func _play_fireworks() -> void:
	var c := center()
	for i in 10:
		var at := c + Vector3(randf_range(-9, 9), randf_range(3, 11), randf_range(-6, 6)) * big
		var col: Color = PARTY[i % PARTY.size()]
		var rocket := _ball(0.18, _glow(col, 5.0))
		_spawn(rocket, Vector3(at.x, c.y - 6.0, at.z))
		var from := rocket.global_position
		_act(rocket, 0.7, func(n: Node3D, k: float):
			n.global_position = from.lerp(at, 1.0 - (1.0 - k) * (1.0 - k))
			if k >= 1.0:
				Fx.burst(at, col, 26, 8.0)
				Fx.burst(at, Color(1, 1, 1), 10, 4.0)
				Fx.ring(at, col, 4.0, 0.5, false)
				Sfx.play("pop", -4.0, randf_range(0.7, 1.3)), i * 0.32)


# ---------- Meteor yağmuru: kayan yıldızlar, sonuncusu yakına düşer ----------
func _play_meteor() -> void:
	var c := center()
	var m := _glow(Color(0.8, 0.95, 1.0), 6.0)
	for i in 9:
		var star := _ball((1.4 if i == 8 else 0.7) * big, m)
		var last := i == 8
		var b := c if last else c + Vector3(randf_range(-30, 30), randf_range(12, 26), randf_range(-25, 10))
		var a := b + Vector3(38, 30, 12)
		_spawn(star, a)
		_act(star, 1.1 if not last else 1.6, func(n: Node3D, k: float):
			n.global_position = a.lerp(b, k)
			Fx.burst(n.global_position, Color(0.8, 0.95, 1.0), 3, 1.5)
			n.scale = Vector3(1, 1, 1) * (1.0 + 0.3 * sin(k * 40.0))
			if k >= 1.0 and last:
				Sfx.play("break", 0.0, 0.5)
				Fx.burst(b, Color(0.8, 0.95, 1.0), 40, 9.0)
				Fx.ring(b, Color(0.8, 0.95, 1.0), 7.0, 0.7)
				_shake(0.45), i * 0.45)


# ---------- Yıldırımlar (zararsız, uzaktaki paratonerlere) ----------
func _play_lightning() -> void:
	var c := center()
	for i in 5:
		var at := c + Vector3(randf_range(-10, 10), 0, randf_range(-8, 8)) * big
		var holder := Node3D.new()
		_spawn(holder, at)
		holder.visible = false
		_bolt(holder)
		_act(holder, 0.22, func(n: Node3D, k: float):
			if not n.visible:
				n.visible = true
				Sfx.play("break", -1.0, randf_range(0.4, 0.6))
				Fx.burst(at, Color(0.9, 0.8, 1.0), 16, 6.0)
				_shake(0.3)
			n.scale.x = 1.0 - k * 0.7
			n.scale.z = n.scale.x, 0.3 + i * 0.5)


static var _curtain: GradientTexture2D


## Kutup ışığı perdesi: altta parlak, yukarı doğru eriyen, kenarları yumuşak doku.
func _curtain_tex() -> GradientTexture2D:
	if _curtain == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.15, 0.45, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
		_curtain = GradientTexture2D.new()
		_curtain.gradient = g
		_curtain.fill_from = Vector2(0.5, 1.0)
		_curtain.fill_to = Vector2(0.5, 0.0)
		_curtain.width = 8
		_curtain.height = 64
	return _curtain


func _bolt(holder: Node3D) -> void:
	var m := _glow(Color(0.9, 0.82, 1.0), 6.0)
	var prev := Vector3(0, 32.0, 0)
	for i in 8:
		var nxt := Vector3(randf_range(-1.2, 1.2), 32.0 - (i + 1) * 4.0, randf_range(-1.2, 1.2))
		if i == 7:
			nxt = Vector3.ZERO
		var cyl := CylinderMesh.new()
		cyl.radial_segments = 6
		cyl.rings = 1
		cyl.top_radius = 0.16
		cyl.bottom_radius = 0.16
		cyl.height = prev.distance_to(nxt)
		var seg := MeshInstance3D.new()
		seg.mesh = cyl
		seg.material_override = m
		seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		holder.add_child(seg)
		seg.position = (prev + nxt) * 0.5
		var dir := (nxt - prev).normalized()
		if absf(dir.dot(Vector3.UP)) < 0.999:
			seg.basis = Basis(Quaternion(Vector3.UP, dir))
		prev = nxt


# ---------- Balon şenliği: aşağıdan onlarca balon yükselir ----------
func _play_balloons() -> void:
	var c := center()
	Sfx.play("wake", -2.0, 1.2)
	for i in 16:
		var col: Color = PARTY[i % PARTY.size()]
		var bal := _ball(0.9 * big, AbilityModels.mat(col, 0.3, 0.25))
		bal.scale = Vector3(1, 1.2, 1)
		var from := c + Vector3(randf_range(-14, 14), randf_range(-14, -8), randf_range(-10, 10))
		_spawn(bal, from)
		var rise := randf_range(34.0, 46.0)
		var sway := randf_range(0.0, TAU)
		_act(bal, randf_range(9.0, 13.0), func(n: Node3D, k: float):
			n.global_position = from + Vector3(sin(k * 9.0 + sway) * 1.2, rise * k, cos(k * 7.0 + sway) * 1.2), i * 0.18)


# ---------- Fener ışığı: dev ışın dönmeye başlar (kalıcı) ----------
func _play_beacon() -> void:
	if _persist:
		return
	_persist = Node3D.new()
	_spawn(_persist, center())
	_persist.set_meta("spin", 0.7)
	var m := _glow(Color(1.0, 0.93, 0.6), 2.5, 0.28)
	for s in [-1.0, 1.0]:
		var cone := CylinderMesh.new()
		cone.top_radius = 0.4
		cone.bottom_radius = 5.0 * big
		cone.height = 60.0 * big
		cone.radial_segments = 12
		cone.rings = 1
		var mi := MeshInstance3D.new()
		mi.mesh = cone
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.rotation.z = s * PI / 2.0
		mi.position.x = -s * 30.0 * big
		_persist.add_child(mi)
	_persist.add_child(_ball(1.6 * big, _glow(Color(1.0, 0.95, 0.7), 6.0)))
	_persist.scale = Vector3.ONE * 0.01
	create_tween().tween_property(_persist, "scale", Vector3.ONE, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sfx.play("core", -2.0)
	Fx.ring(center(), Color(1.0, 0.93, 0.6), 12.0, 0.9, false)
	_shake(0.2)


# ---------- Kutup ışıkları: gökte dalgalanan renkli perdeler (kalıcı) ----------
func _play_aurora() -> void:
	if _persist:
		return
	_persist = Node3D.new()
	_spawn(_persist, center())
	var cols := [Color(0.3, 1.0, 0.6), Color(0.4, 0.8, 1.0), Color(0.7, 0.5, 1.0)]
	for i in 7:
		var q := QuadMesh.new()
		q.size = Vector2(34.0, 20.0) * big
		var mi := MeshInstance3D.new()
		mi.mesh = q
		var m := _glow(cols[i % 3], 1.6, 0.0)
		m.albedo_texture = _curtain_tex()
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = Vector3((i - 3) * 20.0, sin(i * 1.7) * 4.0, cos(i * 2.3) * 10.0) * big
		mi.rotation.y = sin(i * 1.3) * 0.25
		_persist.add_child(mi)
		var tw := mi.create_tween()
		tw.tween_property(m, "albedo_color:a", 0.75, 2.5).set_delay(i * 0.3)
		var lp := mi.create_tween().set_loops()
		lp.tween_property(mi, "position:y", mi.position.y + 3.0, 4.0 + i * 0.4).set_trans(Tween.TRANS_SINE)
		lp.tween_property(mi, "position:y", mi.position.y, 4.0 + i * 0.4).set_trans(Tween.TRANS_SINE)
	Sfx.play("wake", -3.0, 0.6)


# ---------- Kristaller: karanlık mağarada dev kristaller sırayla büyüyüp ışıldar (kalıcı) ----------
func _play_crystals() -> void:
	if _persist:
		return
	_persist = Node3D.new()
	_spawn(_persist, center())
	var cols := [Color(0.5, 0.9, 1.0), Color(0.75, 0.6, 1.0), Color(1.0, 0.6, 0.85)]
	for i in 10:
		var side := -1.0 if i % 2 == 0 else 1.0
		var pr := PrismMesh.new()
		var h := randf_range(3.0, 6.5) * big
		pr.size = Vector3(1.2 * big, h, 1.2 * big)
		var mi := MeshInstance3D.new()
		mi.mesh = pr
		mi.material_override = _glow(cols[i % 3], 2.2, 0.85)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = Vector3(side * randf_range(4.6, 5.6), h * 0.5 - 0.3, -6.0 + i * 1.4)
		mi.rotation = Vector3(randf_range(-0.2, 0.2), randf_range(0, TAU), -side * randf_range(0.15, 0.5))
		mi.scale = Vector3(1, 0.01, 1)
		_persist.add_child(mi)
		var tw := mi.create_tween()
		tw.tween_interval(i * 0.16)
		tw.tween_callback(func():
			Sfx.play("pickup", -6.0, 0.6 + i * 0.07, 0.0)
			Fx.burst(mi.global_position, cols[i % 3], 10, 4.0))
		tw.tween_property(mi, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var lamp := OmniLight3D.new()
		lamp.light_color = cols[i % 3]
		lamp.light_energy = 0.0
		lamp.omni_range = 7.0
		lamp.shadow_enabled = false
		mi.add_child(lamp)
		if i % 3 == 0:
			tw.parallel().tween_property(lamp, "light_energy", 1.6, 0.6)
