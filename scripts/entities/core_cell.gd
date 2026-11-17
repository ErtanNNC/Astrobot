extends Area3D
## Çekirdek Pil: patron yenilince düşer. Alınca bölüm biter (kapanış sahnesi).

@export var cell_id := "ch1"

var _model: MeshInstance3D
var _t := 0.0
var _taken := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 1.2
	cs.shape = sh
	add_child(cs)
	var c := CylinderMesh.new()
	c.top_radius = 0.45
	c.bottom_radius = 0.45
	c.height = 1.2
	_model = AbilityModels.mesh_node(c, AbilityModels.mat(Color(0.4, 1.0, 0.9), 0.3, 4.0))
	add_child(_model)
	var l := OmniLight3D.new()
	l.light_color = Color(0.4, 1.0, 0.9)
	l.light_energy = 3.0
	l.omni_range = 8.0
	add_child(l)
	body_entered.connect(_on_body)


func _process(delta: float) -> void:
	_t += delta
	_model.rotation.y += delta * 2.0
	_model.position.y = 0.6 + sin(_t * 2.0) * 0.15


func _on_body(b: Node) -> void:
	if _taken or not (b is Bip):
		return
	_taken = true
	GameState.add_core_cell(cell_id)
	Sfx.play("core")
	Haptics.vibrate(200)
	b.controls_enabled = false
	var anim: AnimationPlayer = b.get_node("Visual/Model/AnimationPlayer")
	anim.play("RobotArmature|Robot_ThumbsUp", 0.2)
	var tw := create_tween()
	tw.tween_property(_model, "position:y", 3.0, 1.0).set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(2.0).timeout
	GameState.data["area"] = "ch1_patron"
	GameState.save(true)
	Scenes.go("res://scenes/story/closing.tscn")
