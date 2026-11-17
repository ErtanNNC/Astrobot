extends Node3D
## Kapanış sahnesi (hikaye): Bip Çekirdek Pili jeneratöre takar, vadi aydınlanır,
## atölye robotları alkışlar; Statik uzakta bir sonraki bölgeye kaçar. Sözsüz, atlanabilir.

const NEXT := "res://scenes/ui/results.tscn"

var cam: Camera3D
var env: Environment
var sun: DirectionalLight3D
var _generator: Node3D
var _storm: Node3D
var _done := false
var _hold := 0.0
var _robots: Array = []


func _ready() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.1, 0.1, 0.25)
	sm.sky_horizon_color = Color(0.3, 0.28, 0.45)
	sm.ground_horizon_color = Color(0.3, 0.28, 0.45)
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, 30, 0)
	sun.light_energy = 0.3
	sun.shadow_enabled = true
	add_child(sun)
	var island := CSGBox3D.new()
	island.size = Vector3(30, 4, 30)
	island.position.y = -2
	var im := ShaderMaterial.new()
	im.shader = load("res://assets/shaders/toon_terrain.gdshader")
	island.material = im
	add_child(island)
	var prop := load("res://scripts/entities/prop.gd")
	_generator = Node3D.new()
	_generator.set_script(prop)
	_generator.kind = "generator"
	_generator.color = Color(0.15, 0.2, 0.22)
	add_child(_generator)
	_storm = Node3D.new()
	_storm.set_script(prop)
	_storm.kind = "storm"
	_storm.size = 2.0
	_storm.position = Vector3(-25, 18, -30)
	add_child(_storm)
	var bip: Node3D = load("res://assets/models/quaternius/robot/Robot.fbx").instantiate()
	bip.scale = Vector3.ONE * 0.2
	bip.position = Vector3(0, 0, 5)
	bip.rotation.y = PI
	add_child(bip)
	var colors := [Color(0.4, 0.7, 1.0), Color(0.5, 0.9, 0.4), Color(1.0, 0.5, 0.7), Color(0.8, 0.6, 1.0), Color(0.3, 0.9, 0.9)]
	for i in 5:
		var r: Node3D = load("res://assets/models/quaternius/robot/Robot.fbx").instantiate()
		r.scale = Vector3.ONE * randf_range(0.16, 0.24)
		var a := PI * 0.15 + i * PI * 0.17
		r.position = Vector3(cos(a) * 8.5, 0, sin(a) * 8.5)
		r.look_at_from_position(r.position, Vector3(0, 0, 0), Vector3.UP)
		r.rotate_y(PI)
		for m in r.find_children("*", "MeshInstance3D", true, false):
			var mi := m as MeshInstance3D
			for s in mi.mesh.get_surface_count():
				var mat := mi.get_active_material(s)
				if mat is StandardMaterial3D and mat.albedo_color.s > 0.35:
					var d: StandardMaterial3D = mat.duplicate()
					d.albedo_color = d.albedo_color.lerp(colors[i], 0.75)
					mi.set_surface_override_material(s, d)
		r.visible = false
		add_child(r)
		_robots.append(r)
	cam = Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 4, 14)
	cam.look_at(Vector3(0, 3, 0))
	_play.call_deferred(bip)


func _process(delta: float) -> void:
	var holding := Input.is_action_pressed("jump") or Input.is_action_pressed("ability") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_hold = _hold + delta if holding else 0.0
	if _hold > 1.0:
		_finish()


func _wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func _play(bip: Node3D) -> void:
	var ap: AnimationPlayer = bip.find_child("AnimationPlayer", true, false)
	ap.get_animation("RobotArmature|Robot_Walking").loop_mode = Animation.LOOP_LINEAR
	ap.play("RobotArmature|Robot_Walking")
	var tw := create_tween()
	tw.tween_property(bip, "position", Vector3(0, 0, 2.6), 2.0)
	await _wait(2.0)
	if _done: return
	ap.play("RobotArmature|Robot_Punch")
	await _wait(0.6)
	# Pil takılır: bir yuva yanar, ada aydınlanır
	var cell: MeshInstance3D = _generator._part.get_child(0)
	cell.material_override = AbilityModels.mat(Color(0.4, 1.0, 0.9), 0.3, 4.0)
	Sfx.play("core")
	Haptics.vibrate(150)
	var light := create_tween().set_parallel(true)
	light.tween_property(env, "ambient_light_energy", 1.2, 2.5)
	light.tween_property(sun, "light_energy", 1.3, 2.5)
	light.tween_property(cam, "position", Vector3(6, 6, 16), 4.0)
	_generator.spin = 0.6
	await _wait(1.5)
	if _done: return
	# Robotlar dışarı çıkıp alkışlar
	ap.play("RobotArmature|Robot_Dance")
	ap.get_animation("RobotArmature|Robot_Dance").loop_mode = Animation.LOOP_LINEAR
	for r in _robots:
		r.visible = true
		var rap: AnimationPlayer = r.find_child("AnimationPlayer", true, false)
		var n: String = ["RobotArmature|Robot_Yes", "RobotArmature|Robot_Wave", "RobotArmature|Robot_Dance"][randi() % 3]
		rap.get_animation(n).loop_mode = Animation.LOOP_LINEAR
		rap.play(n)
		Sfx.play("pickup", -10.0, randf_range(1.0, 1.5))
		await _wait(0.25)
	Sfx.play("clear")
	await _wait(2.5)
	if _done: return
	# Statik uzakta bir sonraki bölgeye kaçar
	var st := create_tween()
	st.tween_property(_storm, "position", Vector3(-90, 35, -140), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	var ct := create_tween()
	ct.tween_property(cam, "rotation_degrees:y", cam.rotation_degrees.y + 25.0, 2.0)
	await _wait(3.2)
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	GameState.mark_seen("closing_ch1")
	GameState.save(true)
	Scenes.go(NEXT)
