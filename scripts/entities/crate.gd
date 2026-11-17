extends StaticBody3D
## Kırılan sandık: üstüne zıplanınca ya da Kaya ile çakılınca kırılır, pil saçar.

@export var batteries := 3

var _broken := false
var _model: Node3D


func _ready() -> void:
	add_to_group("poundable")
	add_to_group("stompable")
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(1, 1, 1)
	cs.shape = sh
	cs.position.y = 0.5
	add_child(cs)
	_model = load("res://assets/models/quaternius/platformer/Cube_Crate.gltf").instantiate()
	_model.scale = Vector3.ONE * 0.5
	_model.position.y = 0.5
	add_child(_model)


func on_stomp(bip: Node) -> void:
	bip.bounce(9.0)
	smash()


func on_pound(_bip: Node) -> void:
	smash()


func smash() -> void:
	if _broken:
		return
	_broken = true
	Sfx.play("break")
	Haptics.vibrate(30)
	var parent := get_parent()
	Battery.burst(parent, global_position, batteries, String(name))
	# Parçalar
	for i in 6:
		var p := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3(0.3, 0.12, 0.3)
		p.mesh = b
		p.material_override = AbilityModels.mat(Color(0.8, 0.55, 0.3))
		parent.add_child(p)
		p.global_position = global_position + Vector3(randf_range(-0.3, 0.3), 0.5, randf_range(-0.3, 0.3))
		var dir := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		var tw := p.create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "global_position", p.global_position + dir * 1.5 + Vector3.UP * 0.2, 0.5)
		tw.tween_property(p, "rotation", Vector3(randf() * 6, randf() * 6, 0), 0.5)
		tw.tween_property(p, "scale", Vector3.ZERO, 0.5).set_delay(0.2)
		tw.chain().tween_callback(p.queue_free)
	queue_free()

