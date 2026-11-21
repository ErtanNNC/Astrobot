extends Area3D
## Atıcı düşmanın mermisi: yavaş, parlak bir enerji topu. Bip'e değerse hasar verir; duvara çarpınca ya da
## süresi dolunca söner. Dönme saldırısı mermiyi söndürür. Bkz. docs/features/dusmanlar/design.md

var velocity := Vector3.ZERO
var life := 3.5


func _ready() -> void:
	add_to_group("enemy_shot")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.28
	cs.shape = sh
	add_child(cs)
	var m := SphereMesh.new()
	m.radius = 0.26
	m.height = 0.52
	m.radial_segments = 10
	m.rings = 5
	var mi := AbilityModels.mesh_node(m, AbilityModels.mat(Color(1.0, 0.45, 0.2), 0.3, 2.5))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	body_entered.connect(_on_body)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	life -= delta
	if life <= 0.0:
		_pop()


func _on_body(b: Node) -> void:
	if b is Bip:
		if (b as Bip).spin_left > 0.0:
			Sfx.play("pop", -6.0, 1.5)      # dönme saldırısı mermiyi söndürür
		else:
			(b as Bip).take_hit(global_position - velocity.normalized())
	_pop()


func _pop() -> void:
	Fx.burst(global_position, Color(1.0, 0.6, 0.25), 6, 2.0)
	queue_free()
