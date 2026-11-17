extends Area3D
## Zıplama mantarı / trambolin: üstüne düşen Bip yükseğe sıçrar (yetenek gerekmez).

@export var height := 6.0   ## m

var _top: MeshInstance3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var c := CylinderShape3D.new()
	c.radius = 1.0
	c.height = 0.6
	cs.shape = c
	cs.position.y = 0.55
	add_child(cs)
	var base := CylinderMesh.new()
	base.top_radius = 0.9
	base.bottom_radius = 1.0
	base.height = 0.4
	add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.3, 0.32, 0.4)), Vector3(0, 0.2, 0)))
	var top := CylinderMesh.new()
	top.top_radius = 0.95
	top.bottom_radius = 0.95
	top.height = 0.12
	_top = AbilityModels.mesh_node(top, AbilityModels.mat(Color(0.25, 0.85, 0.95), 0.3, 0.5), Vector3(0, 0.45, 0))
	add_child(_top)
	var body := StaticBody3D.new()
	var bs := CollisionShape3D.new()
	var bc := CylinderShape3D.new()
	bc.radius = 0.95
	bc.height = 0.45
	bs.shape = bc
	bs.position.y = 0.22
	body.add_child(bs)
	add_child(body)
	body_entered.connect(_on_body)


func _on_body(b: Node) -> void:
	if b is Bip and b.velocity.y <= 0.5:
		b.bounce(sqrt(2.0 * b.gravity * height))
		Sfx.play("bounce", -2.0)
		Haptics.vibrate(30)
		var tw := create_tween()
		tw.tween_property(_top, "scale", Vector3(1.2, 0.4, 1.2), 0.06)
		tw.tween_property(_top, "scale", Vector3.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
