extends StaticBody3D
## Çatlak zemin: yalnızca Kaya ile yere çakılınca kırılır.

@export var size := Vector3(3, 0.6, 3)

var _broken := false


func _ready() -> void:
	add_to_group("poundable")
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	add_child(cs)
	var mesh := BoxMesh.new()
	mesh.size = size
	add_child(AbilityModels.mesh_node(mesh, AbilityModels.mat(Color(0.72, 0.62, 0.5), 0.9)))
	# Çatlak çizgileri (koyu, zikzak)
	var dark := AbilityModels.mat(Color(0.25, 0.18, 0.12), 1.0)
	for i in 5:
		var crack := BoxMesh.new()
		crack.size = Vector3(size.x * randf_range(0.3, 0.6), 0.02, 0.06)
		add_child(AbilityModels.mesh_node(crack, dark, Vector3(randf_range(-0.3, 0.3) * size.x, size.y / 2 + 0.005, randf_range(-0.35, 0.35) * size.z), Vector3(0, randf() * PI, 0)))


func on_pound(bip: Node) -> void:
	if _broken or bip.global_position.y < global_position.y:
		return
	_broken = true
	Sfx.play("break", 2.0, 0.8)
	for i in 10:
		var p := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3(0.5, 0.3, 0.5) * randf_range(0.6, 1.2)
		p.mesh = b
		p.material_override = AbilityModels.mat(Color(0.72, 0.62, 0.5))
		get_parent().add_child(p)
		p.global_position = global_position + Vector3(randf_range(-0.4, 0.4) * size.x, 0, randf_range(-0.4, 0.4) * size.z)
		var tw := p.create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "global_position", p.global_position + Vector3(randf_range(-1, 1), -4, randf_range(-1, 1)), 0.8).set_ease(Tween.EASE_IN)
		tw.tween_property(p, "rotation", Vector3(randf() * 5, randf() * 5, 0), 0.8)
		tw.chain().tween_callback(p.queue_free)
	queue_free()
