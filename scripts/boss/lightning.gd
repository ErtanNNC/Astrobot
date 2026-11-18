extends Node3D
## Statik'in yıldırımı: önce yerde mor uyarı halkası, sonra gökten yıldırım iner. Değerse hasar.

const WARN := 1.1

var _t := 0.0
var _ring: MeshInstance3D
var _done := false


func _ready() -> void:
	var t := TorusMesh.new()
	t.inner_radius = 1.0
	t.outer_radius = 1.25
	_ring = AbilityModels.mesh_node(t, AbilityModels.mat(Color(0.8, 0.4, 1.0), 0.4, 2.5), Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1, 0.2, 1))
	add_child(_ring)


func _physics_process(delta: float) -> void:
	_t += delta
	_ring.scale = Vector3(1, 0.2, 1) * (1.0 + 0.15 * sin(_t * 22.0))
	if _t >= WARN and not _done:
		_done = true
		_strike()


func _strike() -> void:
	var m := AbilityModels.mat(Color(0.9, 0.8, 1.0), 0.2, 6.0)
	var holder := Node3D.new()
	add_child(holder)
	var prev := Vector3(0, 20.0, 0)
	for i in 7:
		var nxt := Vector3(randf_range(-0.5, 0.5), 20.0 - (i + 1) * 3.0, randf_range(-0.5, 0.5))
		if i == 6:
			nxt = Vector3.ZERO
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.08
		cyl.bottom_radius = 0.08
		cyl.height = prev.distance_to(nxt)
		var seg := AbilityModels.mesh_node(cyl, m)
		holder.add_child(seg)
		seg.position = (prev + nxt) * 0.5
		var dir := (nxt - prev).normalized()
		seg.basis = Basis(Quaternion(Vector3.UP, dir)) if absf(dir.dot(Vector3.UP)) < 0.999 else Basis()
		prev = nxt
	Sfx.play("break", -2.0, 0.5)
	Fx.burst(global_position + Vector3.UP * 0.3, Color(0.85, 0.6, 1.0), 14, 4.0)
	var bip := get_tree().get_first_node_in_group("player") as Bip
	if bip and Vector2(bip.global_position.x - global_position.x, bip.global_position.z - global_position.z).length() < 1.3 \
			and absf(bip.global_position.y - global_position.y) < 2.0:
		bip.take_hit(global_position)
	var tw := create_tween()
	tw.tween_interval(0.25)
	tw.tween_callback(queue_free)
