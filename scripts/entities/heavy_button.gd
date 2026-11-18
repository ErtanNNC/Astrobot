extends Area3D
## Ağır buton: yalnızca Kaya taşıyan Bip (ya da yere çakılma) basabilir.
## Basılınca hedef kapılar açılır. open_time > 0 ise kapı o kadar süre sonra kapanır.

signal activated

@export var targets: Array[NodePath] = []
@export var open_time := 0.0   ## s; 0 = kalıcı

var pressed := false
var _cap: MeshInstance3D
var _timer := 0.0


func _ready() -> void:
	add_to_group("poundable")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = Vector3(1.6, 0.8, 1.6)
	cs.shape = b
	cs.position.y = 0.4
	add_child(cs)
	var base := CylinderMesh.new()
	base.radial_segments = 16
	base.rings = 1
	base.top_radius = 0.9
	base.bottom_radius = 1.0
	base.height = 0.15
	add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.4, 0.42, 0.5))))
	var cap := CylinderMesh.new()
	cap.radial_segments = 16
	cap.rings = 1
	cap.top_radius = 0.7
	cap.bottom_radius = 0.75
	cap.height = 0.25
	_cap = AbilityModels.mesh_node(cap, AbilityModels.mat(Color(0.95, 0.55, 0.15), 0.4, 0.4), Vector3(0, 0.2, 0))
	add_child(_cap)
	# Üstünde kaya simgesi: "buna Kaya lazım"
	var icon := AbilityModels.make_icon("kaya")
	icon.position = Vector3(0, 0.45, 0)
	icon.scale = Vector3.ONE * 1.6
	add_child(icon)
	# Basmak için gövde
	var body := StaticBody3D.new()
	var bs := CollisionShape3D.new()
	var bb := BoxShape3D.new()
	bb.size = Vector3(1.5, 0.3, 1.5)
	bs.shape = bb
	bs.position.y = 0.15
	body.add_child(bs)
	add_child(body)


func _physics_process(delta: float) -> void:
	if pressed and open_time > 0.0:
		_timer -= delta
		if _timer <= 0.0:
			_release()
	if pressed:
		return
	for b in get_overlapping_bodies():
		if b is Bip and GameState.ability == "kaya" and b.is_on_floor():
			_press()


func on_pound(_bip: Node) -> void:
	if GameState.ability == "kaya":
		_press()


func _press() -> void:
	if pressed:
		_timer = open_time
		return
	pressed = true
	_timer = open_time
	Sfx.play("open")
	Haptics.vibrate(50)
	create_tween().tween_property(_cap, "position:y", 0.02, 0.15)
	for t in targets:
		var n := get_node_or_null(t)
		if n and n.has_method("open"):
			n.open()
	activated.emit()


func _release() -> void:
	pressed = false
	create_tween().tween_property(_cap, "position:y", 0.2, 0.3)
	for t in targets:
		var n := get_node_or_null(t)
		if n and n.has_method("close"):
			n.close()
