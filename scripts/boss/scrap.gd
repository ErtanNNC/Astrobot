extends Node3D
## Vinçten düşen hurda: önce yerde kırmızı uyarı halkası, sonra hurda iner. Değerse hasar.

const WARN := 1.0

var _t := 0.0
var _ring: MeshInstance3D
var _crate: Node3D
var _hit_done := false


func _ready() -> void:
	var t := TorusMesh.new()
	t.inner_radius = 0.9
	t.outer_radius = 1.1
	var m := AbilityModels.mat(Color(1, 0.25, 0.15), 0.4, 2.0)
	_ring = AbilityModels.mesh_node(t, m, Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1, 0.2, 1))
	add_child(_ring)
	_crate = load("res://assets/models/quaternius/platformer/Cube_Bricks.gltf").instantiate()
	_crate.scale = Vector3.ONE * 0.45
	_crate.position.y = 14.0
	add_child(_crate)


func _physics_process(delta: float) -> void:
	_t += delta
	_ring.scale = Vector3(1, 0.2, 1) * (1.0 + 0.15 * sin(_t * 20.0))
	if _t > WARN * 0.4:
		_crate.position.y = maxf(_crate.position.y - delta * 22.0, 0.45)
		_crate.rotation.y += delta * 4.0
	if _crate.position.y <= 0.46 and not _hit_done:
		_hit_done = true
		Sfx.play("land", -2.0, 0.6)
		var bip := get_tree().get_first_node_in_group("player") as Bip
		if bip and Vector2(bip.global_position.x - global_position.x, bip.global_position.z - global_position.z).length() < 1.1 \
				and bip.global_position.y - global_position.y < 1.5:
			bip.take_hit(global_position)
		var tw := create_tween()
		tw.tween_interval(0.5)
		tw.tween_property(_crate, "scale", Vector3.ZERO, 0.2)
		tw.tween_callback(queue_free)
