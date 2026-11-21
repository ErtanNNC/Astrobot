class_name Cannon
extends Area3D
## Fırlatma Topu ("vay" anı): Bip içine girer, top nişan alır ve onu büyük bir kavisle hedefe fırlatır.
## Uçuş betikle yürür (oyuncu kontrol etmez), kamera uzaklaşır. Kurallar: docs/features/vay-anlari/design.md

@export var offset := Vector3(0, 8, -20)   ## hedef (topa göre, dünya yönünde)
@export var arc := 6.0                     ## m, kavisin en yüksek noktası (iki uçtan yüksek olanın üstünde)
@export var time := 1.7                    ## s, uçuş süresi
@export var windup := 0.6                  ## s, nişan alma
@export var finish := false                ## alanı bitiren top: Bip uçarken alan tamamlanır (öğreticinin sonu)
@export var secret := false                ## gizli köşeye giden top: kaidesi mor

var _barrel: Node3D
var _bip: Bip
var _t := -1.0
var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _trail := 0.0
var busy := false


func _ready() -> void:
	add_to_group("setpiece")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := CylinderShape3D.new()
	sh.radius = 1.1
	sh.height = 1.6
	cs.shape = sh
	cs.position.y = 0.9
	add_child(cs)
	# Kaide (renkli halka: "buraya gir") + top
	var base := CylinderMesh.new()
	base.top_radius = 1.5
	base.bottom_radius = 1.7
	base.height = 0.25
	base.radial_segments = 20
	add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.7, 0.4, 0.95) if secret else Color(0.95, 0.75, 0.2), 0.4, 0.6), Vector3(0, 0.12, 0)))
	_barrel = Node3D.new()
	_barrel.position.y = 1.1
	add_child(_barrel)
	_build_barrel()
	var flat := Vector3(offset.x, 0, offset.z)
	if flat.length() > 0.1:
		_barrel.look_at(global_position + Vector3.UP * 1.1 + flat, Vector3.UP)
	body_entered.connect(_on_body)


## Oyuncak top: lacivert namlu, altın halkalar, kırmızı tekerlekler. Namlu -Z'ye ve 40° yukarı bakar.
func _build_barrel() -> void:
	var tilt := Node3D.new()
	tilt.rotation.x = deg_to_rad(40.0)
	_barrel.add_child(tilt)
	var navy := AbilityModels.mat(Color(0.16, 0.22, 0.45), 0.35)
	var gold := AbilityModels.mat(Color(1.0, 0.8, 0.25), 0.3, 0.4)
	var red := AbilityModels.mat(Color(0.9, 0.25, 0.2), 0.5)
	var body := CylinderMesh.new()
	body.top_radius = 0.95
	body.bottom_radius = 0.8
	body.height = 2.4
	body.radial_segments = 18
	tilt.add_child(AbilityModels.mesh_node(body, navy, Vector3(0, 0, -0.5), Vector3(-PI / 2, 0, 0)))
	var back := SphereMesh.new()
	back.radius = 0.82
	back.height = 1.64
	tilt.add_child(AbilityModels.mesh_node(back, navy, Vector3(0, 0, 0.7)))
	for z in [-1.62, -0.6, 0.4]:
		var ring := TorusMesh.new()
		ring.inner_radius = 0.82
		ring.outer_radius = 1.08 if z < -1.0 else 0.98
		ring.rings = 18
		ring.ring_segments = 6
		tilt.add_child(AbilityModels.mesh_node(ring, gold, Vector3(0, 0, z), Vector3(PI / 2, 0, 0)))
	var hole := CylinderMesh.new()
	hole.top_radius = 0.72
	hole.bottom_radius = 0.72
	hole.height = 0.06
	tilt.add_child(AbilityModels.mesh_node(hole, AbilityModels.mat(Color(0.03, 0.03, 0.06), 0.9), Vector3(0, 0, -1.71), Vector3(-PI / 2, 0, 0)))
	for x in [-1.0, 1.0]:
		var wheel := CylinderMesh.new()
		wheel.top_radius = 0.75
		wheel.bottom_radius = 0.75
		wheel.height = 0.3
		wheel.radial_segments = 16
		_barrel.add_child(AbilityModels.mesh_node(wheel, red, Vector3(x, -0.35, 0.3), Vector3(0, 0, PI / 2)))
		var hub := CylinderMesh.new()
		hub.top_radius = 0.25
		hub.bottom_radius = 0.25
		hub.height = 0.36
		_barrel.add_child(AbilityModels.mesh_node(hub, gold, Vector3(x, -0.35, 0.3), Vector3(0, 0, PI / 2)))


func _on_body(b: Node) -> void:
	if b is Bip and not busy:
		_load(b)


func _load(b: Bip) -> void:
	busy = true
	_bip = b
	_from = global_position + Vector3.UP * 1.6
	_to = global_position + offset
	b.controls_enabled = false
	b.reset_state(global_position + Vector3.UP * 0.4)
	b.set_physics_process(false)
	b.visual.visible = false
	Sfx.play("charge", -2.0, 0.8)
	Haptics.vibrate(30)
	var tw := create_tween()
	tw.tween_property(_barrel, "scale", Vector3(1.15, 0.8, 1.15), windup * 0.8).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(_barrel, "scale", Vector3(0.9, 1.25, 0.9), 0.06)
	tw.tween_callback(_fire)
	tw.tween_property(_barrel, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _fire() -> void:
	if not is_instance_valid(_bip):
		busy = false
		return
	_t = 0.0
	_bip.visual.visible = true
	var flat := Vector3(offset.x, 0, offset.z)
	if flat.length() > 0.1:
		_bip.facing_yaw = atan2(-flat.x, -flat.z)
		_bip.rotation.y = _bip.facing_yaw
	Sfx.play("break", 0.0, 0.55)
	Sfx.play("spring", -2.0, 0.7)
	Haptics.vibrate(90)
	Fx.ring(_from, Color(1.0, 0.85, 0.4), 3.0, 0.4, false)
	Fx.burst(_from, Color(1.0, 0.9, 0.6), 24, 7.0)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.45)
	if finish:
		get_tree().create_timer(0.7, false).timeout.connect(func():
			var sc := get_tree().current_scene
			if sc and sc.has_method("complete_area"):
				sc.complete_area())


func _physics_process(delta: float) -> void:
	if _t < 0.0 or not is_instance_valid(_bip):
		return
	_t += delta
	var k := clampf(_t / time, 0.0, 1.0)
	var p := _from.lerp(_to, k)
	var top := maxf(_from.y, _to.y) + arc
	# İki uçtan geçen, tepesi `top` olan kavis
	p.y = lerpf(_from.y, _to.y, k) + (top - lerpf(_from.y, _to.y, 0.5)) * 4.0 * k * (1.0 - k)
	_bip.global_position = p
	_bip.velocity = Vector3.ZERO
	_bip.visual.rotation.x = -k * TAU * 2.0          # havada takla
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and "extra_distance" in cam:
		cam.extra_distance = lerpf(cam.extra_distance, 6.0, 1.0 - exp(-4.0 * delta))
	_trail -= delta
	if _trail <= 0.0:
		_trail = 0.05
		Fx.burst(p + Vector3.UP * 0.5, Color(1.0, 0.9, 0.5), 2, 0.8)
	if k >= 1.0:
		_land()


func _land() -> void:
	_t = -1.0
	_bip.visual.rotation.x = 0.0
	if finish:
		return                     # alan bitti; Bip havada kalır, sahne değişir
	_bip.reset_state(_to)
	_bip.set_physics_process(true)
	_bip.controls_enabled = true
	Sfx.play("land", 0.0, 0.7)
	Haptics.vibrate(60)
	Fx.ring(_to, Color(0.95, 0.92, 0.85), 2.6, 0.45)
	Fx.burst(_to + Vector3.UP * 0.2, Color(0.95, 0.92, 0.85), 14, 3.5)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.3)
	_bip = null
	get_tree().create_timer(0.8, false).timeout.connect(func(): busy = false)
