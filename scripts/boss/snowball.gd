extends Node3D
## Kardan Dev'in kartopu: yerde mavi uyarı halkası, sonra kartopu düşer. Değerse hasar.

const WARN := 0.9

var _t := 0.0
var _ring: MeshInstance3D
var _ball: MeshInstance3D
var _hit_done := false


func _ready() -> void:
	var t := TorusMesh.new()
	t.inner_radius = 0.9
	t.outer_radius = 1.1
	_ring = AbilityModels.mesh_node(t, AbilityModels.mat(Color(1, 0.35, 0.2), 0.4, 2.0), Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1, 0.2, 1))
	add_child(_ring)
	var s := SphereMesh.new()
	s.radius = 0.6
	s.height = 1.2
	_ball = AbilityModels.mesh_node(s, AbilityModels.mat(Color(0.95, 0.97, 1.0), 0.8), Vector3(0, 14, 0))
	add_child(_ball)


func _physics_process(delta: float) -> void:
	_t += delta
	_ring.scale = Vector3(1, 0.2, 1) * (1.0 + 0.15 * sin(_t * 20.0))
	if _t > WARN * 0.4:
		_ball.position.y = maxf(_ball.position.y - delta * 20.0, 0.6)
		_ball.rotation.x += delta * 5.0
	if _ball.position.y <= 0.61 and not _hit_done:
		_hit_done = true
		Sfx.play("land", -2.0, 0.8)
		var bip := get_tree().get_first_node_in_group("player") as Bip
		if bip and Vector2(bip.global_position.x - global_position.x, bip.global_position.z - global_position.z).length() < 1.1 \
				and bip.global_position.y - global_position.y < 1.5:
			bip.take_hit(global_position)
		_ring.visible = false
		var tw := create_tween()
		tw.tween_property(_ball, "scale", Vector3(1.6, 0.2, 1.6), 0.15)
		tw.tween_property(_ball, "scale", Vector3.ZERO, 0.3)
		tw.tween_callback(queue_free)
