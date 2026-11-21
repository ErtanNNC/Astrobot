extends Node3D
## Kardan Dev'in kartopu: yerde mavi uyarı halkası, sonra kartopu düşer. Değerse hasar.

const WARN := 0.9
const IMPACT := 1.03   ## s, kartopunun yere değdiği an

var _t := 0.0
var _ring: WarnMark
var _ball: MeshInstance3D
var _hit_done := false


func _ready() -> void:
	_ring = WarnMark.make(Color(1, 0.35, 0.2), 1.0, IMPACT)
	add_child(_ring)
	var s := SphereMesh.new()
	s.radial_segments = 12
	s.rings = 6
	s.radius = 0.6
	s.height = 1.2
	_ball = AbilityModels.mesh_node(s, AbilityModels.mat(Color(0.95, 0.97, 1.0), 0.8), Vector3(0, 14, 0))
	add_child(_ball)


func _physics_process(delta: float) -> void:
	_t += delta
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
		_ring.finish()
		Fx.ring(global_position, Color(0.9, 0.95, 1.0), 1.6)
		var tw := create_tween()
		tw.tween_property(_ball, "scale", Vector3(1.6, 0.2, 1.6), 0.15)
		tw.tween_property(_ball, "scale", Vector3.ZERO, 0.3)
		tw.tween_callback(queue_free)
