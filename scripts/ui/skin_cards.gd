class_name SkinCards
## Kostüm dolabı: her kostüm minik, dönen bir 3B Bip olarak görünür (kendi küçük SubViewport'unda).
## Açık olana dokununca seçilir; kilitliler karanlık siluet ve gereken pil/vida sayısıyla durur.
## Kullananlar: Atölye'deki Kostüm Dolabı ve Koleksiyon (hub.gd). Bkz. docs/features/kostum/design.md

const MODEL := "res://assets/models/pixabay/bip/idle.fbx"
const ANIMS := "res://assets/models/pixabay/bip/bip_anims.res"
const SHADER := preload("res://assets/shaders/bip_skin.gdshader")
const CARD := Vector2(132, 178)


## parent içine kostüm kartlarını dizer. on_pick(id) seçilince çağrılır.
static func build(parent: Control, on_pick: Callable, columns := 4) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(grid)
	for sk in GameState.SKINS:
		grid.add_child(_card(sk, on_pick))
	return grid


static func _t(s: String) -> String:
	return TranslationServer.translate(s)


static func _card(sk: Dictionary, on_pick: Callable) -> Control:
	var id: String = sk["id"]
	var open := GameState.skin_unlocked(id)
	var chosen := Settings.skin == id
	var btn := Button.new()
	btn.custom_minimum_size = CARD
	btn.focus_mode = Control.FOCUS_ALL
	UIKit.style_button(btn, UIKit.GREEN if chosen else (UIKit.BLUE if open else Color(0.55, 0.55, 0.6)))
	btn.disabled = not open
	btn.pressed.connect(func(): on_pick.call(id))
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 6; vb.offset_right = -6; vb.offset_top = 4; vb.offset_bottom = -6
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 0)
	btn.add_child(vb)
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.custom_minimum_size = Vector2(110, 128)
	svc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(svc)
	var sv := SubViewport.new()
	sv.own_world_3d = true
	sv.transparent_bg = true
	sv.msaa_3d = Viewport.MSAA_2X
	svc.add_child(sv)
	_stage(sv, sk, open)
	var l := Label.new()
	l.text = _t(sk["name"]) if open else (_t("%d Altın Vida") % int(sk["need_screws"]) if sk.has("need_screws") else _t("%d pil") % int(sk["need"]))
	if chosen:
		l.text = "✓ " + l.text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.2, 0.35))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(l)
	return btn


## Minik sahne: ışık, kamera ve kostüm boyalı Bip (yavaşça döner, bekleme animasyonu).
static func _stage(sv: SubViewport, sk: Dictionary, open: bool) -> void:
	var root := Node3D.new()
	sv.add_child(root)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = env
	root.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 30, 0)
	sun.light_energy = 1.2
	root.add_child(sun)
	var cam := Camera3D.new()
	cam.fov = 32
	var cp := Vector3(0, 0.8, 2.95)
	cam.transform = Transform3D(Basis.looking_at(Vector3(0, 0.66, 0) - cp), cp)   # ağaçta değilken look_at çalışmaz
	root.add_child(cam)
	var m: Node3D = load(MODEL).instantiate()
	m.scale = Vector3.ONE * 120.0
	root.add_child(m)
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var mesh_i := mi as MeshInstance3D
		for i in mesh_i.mesh.get_surface_count():
			var mat := mesh_i.get_active_material(i) as StandardMaterial3D
			if mat == null or mat.albedo_texture == null:
				continue
			var sm := ShaderMaterial.new()
			sm.shader = SHADER
			sm.set_shader_parameter("albedo_tex", mat.albedo_texture)
			sm.set_shader_parameter("hue_shift", float(sk.get("hue", 0.0)))
			sm.set_shader_parameter("sat_mul", float(sk.get("sat", 1.0)) if open else 0.0)
			sm.set_shader_parameter("val_mul", float(sk.get("val", 1.0)) if open else 0.25)
			sm.set_shader_parameter("tint", Color.WHITE if open else Color(0.35, 0.35, 0.42))
			sm.set_shader_parameter("glow", Vector3(1.0, 0.8, 0.3) * float(sk.get("glow", 0.0)) if open else Vector3.ZERO)
			mesh_i.set_surface_override_material(i, sm)
	var ap := m.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if ap:
		for lib in ap.get_animation_library_list():
			ap.remove_animation_library(lib)
		var src: AnimationLibrary = load(ANIMS)
		ap.add_animation_library("", src)
		var a := "wave" if open and Settings.skin == sk["id"] else "idle"
		src.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
		ap.play(a)
		ap.seek(randf() * 1.0, true)
	m.rotation.y = 0.35
	if open:
		var tw := m.create_tween().set_loops()
		tw.tween_property(m, "rotation:y", 0.35 + TAU, 7.0).from(0.35)
