extends Node3D
## Açılış sahnesi (hikaye dokümanı): fırtına, Statik dört Çekirdek Pili kapar, ada kararır;
## atölyede yıldırım uyuyan Bip'in antenine düşer, Bip'in gözleri yanar. Sözsüz.
## Atlamak: herhangi bir tuşu / ekranı 1 sn basılı tut (hikaye kural 2).

const NEXT := "res://scenes/chapter1/a0_atolye.tscn"
const SKIP_HOLD := 1.0

var cam: Camera3D
var env: Environment
var sun: DirectionalLight3D
var flash: ColorRect
var skip_ring: Control
var _hold := 0.0
var _done := false
var _generator: Node3D
var _storm: Node3D
var _cells: Array = []
var _bip_model: Node3D
var _tip_mat: StandardMaterial3D
var _rain: Node3D


func _ready() -> void:
	_build_world()
	_build_ui()
	_play.call_deferred()


func _build_world() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.05, 0.05, 0.14)
	sm.sky_horizon_color = Color(0.18, 0.16, 0.32)
	sm.ground_horizon_color = Color(0.18, 0.16, 0.32)
	sm.ground_bottom_color = Color(0.03, 0.04, 0.1)
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.5, 0.8)
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.fog_enabled = true
	env.fog_light_color = Color(0.15, 0.13, 0.28)
	env.fog_density = 0.008
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_color = Color(0.6, 0.65, 1.0)
	sun.light_energy = 0.4
	add_child(sun)
	# Ada ve jeneratör
	var island := CSGBox3D.new()
	island.size = Vector3(30, 4, 30)
	island.position = Vector3(0, -2, 0)
	var im := ShaderMaterial.new()
	im.shader = load("res://assets/shaders/toon_terrain.gdshader")
	island.material = im
	add_child(island)
	var sea := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	pm.subdivide_depth = 40
	pm.subdivide_width = 40
	sea.mesh = pm
	var wm := ShaderMaterial.new()
	wm.shader = load("res://assets/shaders/water.gdshader")
	wm.set_shader_parameter("deep", Color(0.05, 0.1, 0.25))
	wm.set_shader_parameter("shallow", Color(0.12, 0.2, 0.4))
	sea.material_override = wm
	sea.position.y = -3
	add_child(sea)
	var prop := load("res://scripts/entities/prop.gd")
	_generator = Node3D.new()
	_generator.set_script(prop)
	_generator.kind = "generator"
	_generator.color = Color(0.4, 1.0, 0.9)
	_generator.spin = 0.4
	add_child(_generator)
	for i in 3:
		var t: Node3D = load("res://assets/models/quaternius/platformer/Tree.gltf").instantiate()
		t.scale = Vector3.ONE * 0.5
		t.position = Vector3(-9 + i * 9, 0, -9 + (i % 2) * 3)
		add_child(t)
	_storm = Node3D.new()
	_storm.set_script(prop)
	_storm.kind = "storm"
	_storm.size = 2.5
	_storm.position = Vector3(40, 22, -40)
	add_child(_storm)
	_rain = Node3D.new()
	_rain.set_script(prop)
	_rain.kind = "rain"
	_rain.size = 2.0
	_rain.position = Vector3(0, 18, 0)
	add_child(_rain)
	cam = Camera3D.new()
	cam.fov = 55
	add_child(cam)
	cam.position = Vector3(0, 6, 22)
	cam.look_at(Vector3(0, 4, 0))


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(flash)
	skip_ring = Control.new()
	skip_ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	skip_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skip_ring.draw.connect(_draw_skip)
	layer.add_child(skip_ring)


func _draw_skip() -> void:
	var k := skip_ring.size.y / 720.0
	var c := Vector2(skip_ring.size.x - 70 * k, skip_ring.size.y - 70 * k)
	var a := 0.35 + 0.65 * minf(_hold / 0.15, 1.0)
	skip_ring.draw_arc(c, 30 * k, 0, TAU, 32, Color(1, 1, 1, 0.25 * a), 5 * k, true)
	if _hold > 0.0:
		skip_ring.draw_arc(c, 30 * k, -PI / 2, -PI / 2 + TAU * _hold / SKIP_HOLD, 32, Color(1, 1, 1, 0.9), 5 * k, true)
	# ">>" simgesi
	for i in 2:
		var o := c + Vector2((-8 + i * 12) * k, 0)
		skip_ring.draw_colored_polygon(PackedVector2Array([o + Vector2(-6, -10) * k, o + Vector2(8, 0) * k, o + Vector2(-6, 10) * k]), Color(1, 1, 1, 0.8 * a))


func _process(delta: float) -> void:
	var holding := Input.is_action_pressed("jump") or Input.is_action_pressed("ability") or Input.is_action_pressed("pause") \
			or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or _touching
	_hold = _hold + delta if holding else maxf(_hold - delta * 2.0, 0.0)
	skip_ring.queue_redraw()
	if _hold >= SKIP_HOLD:
		_finish()


var _touching := false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_touching = event.pressed


func _lightning(strength := 1.0) -> void:
	Sfx.play("break", -2.0, 0.45)
	var tw := create_tween()
	tw.tween_property(flash, "color:a", 0.75 * strength, 0.05)
	tw.parallel().tween_property(sun, "light_energy", 4.0, 0.05)
	tw.tween_property(flash, "color:a", 0.0, 0.35)
	tw.parallel().tween_property(sun, "light_energy", 0.4, 0.4)


func _wait(t: float) -> void:
	if _done:
		return
	await get_tree().create_timer(t).timeout


func _play() -> void:
	# 1) Gece, fırtına; jeneratör parlıyor
	var tw := create_tween()
	tw.tween_property(cam, "position", Vector3(4, 8, 16), 6.0).set_trans(Tween.TRANS_SINE)
	await _wait(1.5)
	_lightning(0.6)
	await _wait(1.0)
	# 2) Statik geliyor
	var st := create_tween()
	st.tween_property(_storm, "position", Vector3(0, 13, -2), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await _wait(3.2)
	if _done:
		return
	_lightning(1.0)
	# 3) Dört Çekirdek Pil tek tek buluta uçar, ışıklar söner
	var part: Node3D = _generator._part
	var cells := part.get_children()
	for i in cells.size():
		var c: Node3D = cells[i]
		var from := c.global_position
		part.remove_child(c)
		add_child(c)
		c.global_position = from
		var ct := create_tween()
		ct.tween_property(c, "global_position", _storm.global_position + Vector3(randf_range(-1, 1), 0, 0), 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		ct.tween_property(c, "scale", Vector3.ZERO, 0.15)
		Sfx.play("magnet", -4.0, 0.8 + i * 0.1)
		env.ambient_light_energy = 0.6 - (i + 1) * 0.12
		await _wait(0.65)
	if _done:
		return
	_lightning(0.8)
	# 4) Statik kaçar, ada karanlık
	var away := create_tween()
	away.tween_property(_storm, "position", Vector3(-60, 30, -80), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	var ct2 := create_tween()
	ct2.tween_property(cam, "position", Vector3(0, 3, 9), 3.0).set_trans(Tween.TRANS_SINE)
	await _wait(3.0)
	if _done:
		return
	# 5) Atölye: Bip uyuyor; yıldırım anteninden girer
	var fade := create_tween()
	fade.tween_property(flash, "color", Color(0, 0, 0, 1), 0.5)
	await _wait(0.6)
	if _done:
		return
	_build_workshop()
	fade = create_tween()
	fade.tween_property(flash, "color:a", 0.0, 0.6)
	await _wait(2.2)
	if _done:
		return
	flash.color = Color(1, 1, 1, 0)
	_bolt()
	_lightning(1.0)
	Haptics.vibrate(120)
	_tip_mat.emission_energy_multiplier = 10.0
	await _wait(0.8)
	# Gözler yanar, Bip uyanır
	var ap: AnimationPlayer = _bip_model.find_child("AnimationPlayer", true, false)
	ap.play("RobotArmature|Robot_Standing")
	Sfx.play("wake")
	await _wait(1.0)
	ap.play("RobotArmature|Robot_Yes")
	await _wait(1.8)
	_finish()


func _build_workshop() -> void:
	for c in get_children():
		if c is Node3D and c != cam and not (c is WorldEnvironment) and c != sun:
			c.queue_free()
	var fl := CSGBox3D.new()
	fl.size = Vector3(10, 1, 10)
	fl.position.y = -0.5
	var fm := ShaderMaterial.new()
	fm.shader = load("res://assets/shaders/toon_terrain.gdshader")
	fm.set_shader_parameter("top_color", Color(0.6, 0.48, 0.36))
	fm.set_shader_parameter("top_color2", Color(0.56, 0.45, 0.33))
	fl.material = fm
	add_child(fl)
	var back := CSGBox3D.new()
	back.size = Vector3(10, 5, 0.5)
	back.position = Vector3(0, 2.5, -3)
	back.material = fm
	add_child(back)
	var prop := load("res://scripts/entities/prop.gd")
	var st := Node3D.new()
	st.set_script(prop)
	st.kind = "station"
	add_child(st)
	_bip_model = load("res://assets/models/quaternius/robot/Robot.fbx").instantiate()
	_bip_model.scale = Vector3.ONE * 0.2
	_bip_model.position = Vector3(0, 0.35, 0)
	add_child(_bip_model)
	var ap: AnimationPlayer = _bip_model.find_child("AnimationPlayer", true, false)
	ap.play("RobotArmature|Robot_Sitting")
	ap.seek(0.4, true)
	ap.pause()
	# Anten
	var tip := SphereMesh.new()
	tip.radius = 0.07
	tip.height = 0.14
	_tip_mat = AbilityModels.mat(Color(0.4, 0.95, 1.0), 0.3, 1.0)
	var t := AbilityModels.mesh_node(tip, _tip_mat, Vector3(0, 1.25, 0))
	add_child(t)
	var lamp := OmniLight3D.new()
	lamp.light_color = Color(1, 0.8, 0.5)
	lamp.light_energy = 0.6
	lamp.position = Vector3(1.5, 2.5, 2)
	add_child(lamp)
	sun.light_energy = 0.3
	env.ambient_light_energy = 0.5
	cam.position = Vector3(0, 1.3, 3.6)
	cam.look_at(Vector3(0, 0.8, 0))
	var ct := create_tween()
	ct.tween_property(cam, "position", Vector3(0.3, 1.1, 2.6), 3.0)


func _bolt() -> void:
	var pts := [Vector3(0.6, 12, -1)]
	for i in 6:
		pts.append(Vector3(randf_range(-0.6, 0.6), 12 - (i + 1) * 1.8, randf_range(-0.4, 0.4)))
	pts.append(Vector3(0, 1.25, 0))
	var m := AbilityModels.mat(Color(0.85, 0.75, 1.0), 0.2, 6.0)
	var holder := Node3D.new()
	add_child(holder)
	for i in pts.size() - 1:
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[i + 1]
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.04
		cyl.bottom_radius = 0.04
		cyl.height = a.distance_to(b)
		var seg := AbilityModels.mesh_node(cyl, m)
		holder.add_child(seg)
		seg.look_at_from_position((a + b) * 0.5, b, Vector3.RIGHT)
		seg.rotate_object_local(Vector3.RIGHT, PI / 2)
	var tw := create_tween()
	tw.tween_interval(0.25)
	tw.tween_callback(holder.queue_free)


func _finish() -> void:
	if _done:
		return
	_done = true
	GameState.mark_seen("opening")
	GameState.data["area"] = "ch1_atolye"
	GameState.data["checkpoint_id"] = "start"
	GameState.save(true)
	Scenes.go(NEXT)
