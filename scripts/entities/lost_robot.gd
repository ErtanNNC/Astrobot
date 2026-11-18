extends Area3D
## Kayıp atölye robotu (Astro Bot'taki kurtarılacak botlar gibi): el sallayıp yardım bekler.
## Bip dokununca sevinir ve Atölye'ye ışınlanır; kurtarılan robotlar Atölye'de dans eder.

var robot_id := ""
var _model: Node3D
var _anim: AnimationPlayer
var _done := false
var _bubble: MeshInstance3D
var _t := 0.0

const COLORS := [Color(0.4, 0.7, 1.0), Color(0.5, 0.9, 0.4), Color(1.0, 0.5, 0.7), Color(0.8, 0.6, 1.0),
	Color(0.3, 0.9, 0.9), Color(1.0, 0.85, 0.3), Color(0.95, 0.45, 0.35)]


static func tinted_robot(id: String, scale_f: float) -> Node3D:
	var r: Node3D = load("res://assets/models/quaternius/robot/Robot.fbx").instantiate()
	r.scale = Vector3.ONE * scale_f
	var c: Color = COLORS[absi(id.hash()) % COLORS.size()]
	for m in r.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(i)
			if mat is StandardMaterial3D and mat.albedo_color.s > 0.35 and mat.albedo_color.v > 0.35:
				var d: StandardMaterial3D = mat.duplicate()
				d.albedo_color = d.albedo_color.lerp(c, 0.8)
				mi.set_surface_override_material(i, d)
	return r


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := SphereShape3D.new()
	sh.radius = 0.9
	cs.shape = sh
	cs.position.y = 0.6
	add_child(cs)
	_model = tinted_robot(robot_id, 0.13)
	add_child(_model)
	_anim = _model.find_child("AnimationPlayer", true, false)
	_anim.get_animation("RobotArmature|Robot_Wave").loop_mode = Animation.LOOP_LINEAR
	_anim.play("RobotArmature|Robot_Wave")
	# "Yardım!" balonu: sarı bir ünlem
	var b := SphereMesh.new()
	b.radius = 0.16
	b.height = 0.32
	b.radial_segments = 10
	b.rings = 5
	_bubble = AbilityModels.mesh_node(b, AbilityModels.mat(Color(1, 0.9, 0.3), 0.3, 1.5), Vector3(0, 1.25, 0))
	add_child(_bubble)
	var bar := BoxMesh.new()
	bar.size = Vector3(0.05, 0.16, 0.05)
	_bubble.add_child(AbilityModels.mesh_node(bar, AbilityModels.mat(Color(0.2, 0.15, 0.1)), Vector3(0, 0.03, 0.15)))
	body_entered.connect(_on_body)


func _process(delta: float) -> void:
	_t += delta
	if _bubble:
		_bubble.position.y = 1.25 + sin(_t * 4.0) * 0.06
	var bip := get_tree().get_first_node_in_group("player") as Node3D
	if bip and not _done:
		var to := bip.global_position - global_position
		_model.rotation.y = lerp_angle(_model.rotation.y, atan2(to.x, to.z), 4.0 * delta)


func _on_body(b: Node) -> void:
	if _done or not (b is Bip):
		return
	_done = true
	if not GameState.data.has("robots"):
		GameState.data["robots"] = []
	if not GameState.data["robots"].has(robot_id):
		GameState.data["robots"].append(robot_id)
	Sfx.play("secret")
	Haptics.vibrate(50)
	Fx.burst(global_position + Vector3.UP * 0.6, Color(1, 0.95, 0.6), 18, 3.5)
	_bubble.queue_free()
	_bubble = null
	_anim.play("RobotArmature|Robot_Yes")
	var lvl := get_tree().current_scene
	if lvl and lvl.has_method("on_robot_rescued"):
		lvl.on_robot_rescued()
	await get_tree().create_timer(1.2, false).timeout
	if not is_inside_tree():
		return
	# Atölye'ye ışınlanma: incelip yukarı uçar
	var tw := create_tween()
	tw.tween_property(_model, "scale", Vector3(0.02, 0.4, 0.02), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_model, "position:y", 3.0, 0.35)
	tw.tween_callback(queue_free)
	Sfx.play("magnet", -6.0, 1.4)
