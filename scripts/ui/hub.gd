extends Node3D
## Giriş ekranı + Atölye (oynanabilir ana menü). Bkz. docs/features/ana-menu/design.md
## Giriş: gece, Bip şarj istasyonunda uyuyor; dokununca uyanır ve kamera Atölye'ye kayar.
## Atölye: Bip yürüyüp nesnelere gider (kapı = oyna, kapsüller = kayıt yuvaları, TV = ayarlar,
## vitrin = koleksiyon, oyuncak kutusu = yetenek deneme, şalter = çıkış). ≡ her zaman açık.

const OPENING := "res://scenes/story/opening.tscn"

static var skip_title := false   ## oyundan "Atölye'ye dön" ile gelinince giriş atlanır

var bip: Bip
var cam
var hud
var touch
var pause_menu
var ui: CanvasLayer
var _state := "title"
var _title_root: Control
var _tap_label: Label
var _overlay: Control
var _quick_btn: Button
var _idle := 0.0
var _env: Environment
var _t := 0.0


func _ready() -> void:
	var rig := $GameRig
	Settings.apply_graphics.call_deferred()
	bip = rig.get_node("Bip")
	cam = rig.get_node("FollowCamera")
	hud = rig.get_node("UI/HUD")
	touch = rig.get_node("UI/TouchControls")
	pause_menu = rig.get_node("UI/PauseMenu")
	ui = rig.get_node("UI")
	hud.visible = false
	GameState.safe_mode = true
	if GameState.data.is_empty():
		GameState.data = GameState.new_data()
	GameState.set_ability("")
	_env = ($WorldEnvironment as WorldEnvironment).environment
	var start := get_node_or_null("Start") as Node3D
	if start:
		bip.reset_state(start.global_position)
		bip.facing_yaw = start.global_rotation.y
		bip.rotation.y = bip.facing_yaw
	cam.snap_to_target()
	touch.pause_pressed.connect(open_quick_menu)
	touch.tapped.connect(_on_screen_tap)
	_refresh_capsules()
	_refresh_toybox()
	_spawn_rescued_robots()
	if OS.has_feature("mobile"):
		var sw := find_child("Salter", true, false)
		if sw:
			sw.queue_free()
	_build_quick_button()
	var mp: AudioStreamPlayer = rig.get_node("Music")
	mp.stream = load("res://assets/audio/opengameart/happy_adventure_loop.mp3")
	mp.stream.loop = true
	if skip_title:
		skip_title = false
		_enter_hub(false)
	else:
		_enter_title()
	mp.play()


# ---------- Giriş ekranı ----------

func _enter_title() -> void:
	_state = "title"
	bip.controls_enabled = false
	touch.visible = false
	_quick_btn.visible = false
	_env.ambient_light_energy = 0.25
	($Sun as DirectionalLight3D).light_energy = 0.15
	var anim: AnimationPlayer = bip.get_node("Visual/Model/AnimationPlayer")
	anim.play("RobotArmature|Robot_Sitting")
	anim.seek(0.4, true)
	anim.pause()
	_title_root = Control.new()
	_title_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_title_root)
	var logo := Label.new()
	logo.text = "BİP"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.set_anchors_preset(Control.PRESET_TOP_WIDE)
	logo.position.y = 40
	logo.add_theme_font_size_override("font_size", 150)
	logo.add_theme_color_override("font_color", Color(1.0, 0.75, 0.25))
	logo.add_theme_color_override("font_outline_color", Color(0.12, 0.15, 0.35))
	logo.add_theme_constant_override("outline_size", 36)
	logo.add_theme_color_override("font_shadow_color", Color(0.3, 0.9, 1.0, 0.6))
	logo.add_theme_constant_override("shadow_offset_y", 8)
	_title_root.add_child(logo)
	var sub := Label.new()
	sub.text = "Kopyalayan Robot"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.position.y = 225
	sub.add_theme_font_size_override("font_size", 34)
	sub.add_theme_color_override("font_outline_color", Color(0.12, 0.15, 0.35))
	sub.add_theme_constant_override("outline_size", 12)
	_title_root.add_child(sub)
	_tap_label = Label.new()
	_tap_label.text = "Başlamak için dokun" if (OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()) else "Başlamak için bir tuşa bas"
	_tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tap_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_tap_label.position.y = -110
	_tap_label.add_theme_font_size_override("font_size", 36)
	_tap_label.add_theme_color_override("font_outline_color", Color(0.12, 0.15, 0.35))
	_tap_label.add_theme_constant_override("outline_size", 12)
	_title_root.add_child(_tap_label)
	_tap_label.size.x = 1280
	logo.size.x = 1280
	sub.size.x = 1280
	# Logo hafifçe süzülür ve sallanır (canlı başlık)
	logo.pivot_offset = Vector2(640, 90)
	var ltw := logo.create_tween().set_loops()
	ltw.tween_property(logo, "rotation", 0.04, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ltw.tween_property(logo, "rotation", -0.04, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var stw := sub.create_tween().set_loops()
	stw.tween_property(sub, "position:y", 232.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	stw.tween_property(sub, "position:y", 225.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	sub.add_theme_color_override("font_color", Color(0.55, 0.95, 1.0))
	_tap_label.pivot_offset = Vector2(640, 25)
	var ttw := _tap_label.create_tween().set_loops()
	ttw.tween_property(_tap_label, "scale", Vector2(1.08, 1.08), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ttw.tween_property(_tap_label, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cam.face_target(4.2, 6.0)


func _wake() -> void:
	_state = "waking"
	Sfx.play("wake")
	Haptics.vibrate(60)
	var anim: AnimationPlayer = bip.get_node("Visual/Model/AnimationPlayer")
	anim.play("RobotArmature|Robot_Standing")
	cam.release_front()
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_env, "ambient_light_energy", 1.3, 1.5)
	tw.tween_property($Sun, "light_energy", 1.0, 1.5)
	tw.tween_property(_title_root, "modulate:a", 0.0, 0.8)
	await get_tree().create_timer(1.5).timeout
	_title_root.queue_free()
	_enter_hub(true)


func _enter_hub(_animated: bool) -> void:
	_state = "hub"
	_env.ambient_light_energy = 1.3
	($Sun as DirectionalLight3D).light_energy = 1.0
	bip.controls_enabled = true
	touch.visible = touch._active
	_quick_btn.visible = true
	var anim: AnimationPlayer = bip.get_node("Visual/Model/AnimationPlayer")
	anim.play("RobotArmature|Robot_Wave")
	anim.queue("RobotArmature|Robot_Idle")
	_announce_bonus.call_deferred()


## Final bittiyse bonus bölümü bir kez duyur (oyuncu Gizli Adalar'ın açıldığını bilsin).
func _announce_bonus() -> void:
	var d := GameState.data
	if d.is_empty() or not d.get("game_complete", false) or d.get("seen_cutscenes", []).has("bonus_intro"):
		return
	if GameState.chapter_of(d.get("area", "ch1_atolye")) != 5:
		return
	GameState.mark_seen("bonus_intro")
	GameState.save(true)
	await get_tree().create_timer(1.2).timeout
	var v := _new_overlay(560)
	UIKit.title(v, "Gizli Adalar açıldı!")
	var l := UIKit.title(v, "Ada kurtuldu ama Pırıl haritada dört gizli ada buldu: Oyuncak Kasabası, Yıldız Gözlemevi, Volkan Adası ve Şampiyon Yolu. Kapıdan çıkınca yolculuk Bölüm 5 ile sürer!", 24)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(500, 0)
	Sfx.play("secret")
	UIKit.button(v, "Harika!", _close_overlay, UIKit.GREEN)
	_focus_first(v)


func _physics_process(_delta: float) -> void:
	# Atölye'den düşülemez (ana menü edge case): duvarı aşan Bip başa döner
	if bip and bip.global_position.y < -4.0:
		var start := get_node_or_null("Start") as Node3D
		bip.reset_state(start.global_position if start else Vector3(0, 0.4, 0))
		cam.snap_to_target()
		Sfx.play("fall", -6.0)


func _process(delta: float) -> void:
	_t += delta
	# Yetenek tuşu/butonu: telefondaki buton giriş olayı üretmez, tuş durumunu her karede kontrol et
	if _state == "hub" and _overlay == null and Input.is_action_just_pressed("ability"):
		for m in get_tree().get_nodes_in_group("menu_object"):
			if m.near:
				_activate(m)
				break
	if _state == "title":
		_tap_label.modulate.a = 0.55 + 0.45 * sin(_t * 2.2)
		_idle += delta
		if _idle > 20.0:
			_idle = 0.0
			Sfx.play("glass", -8.0)  # Pırıl antene konup kıvılcım çıkarır
			bip.get_node("Visual")._tip_mat.emission_energy_multiplier = 8.0


func _unhandled_input(event: InputEvent) -> void:
	if _state == "title":
		var pressed: bool = (event is InputEventScreenTouch and event.pressed) or (event is InputEventKey and event.pressed and not event.echo) \
				or (event is InputEventJoypadButton and event.pressed) or (event is InputEventMouseButton and event.pressed)
		if pressed:
			get_viewport().set_input_as_handled()
			_wake()
		return
	if _state != "hub" or _overlay != null:
		return
	if event.is_action_pressed("pause"):
		open_quick_menu()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT \
			and not DisplayServer.is_touchscreen_available():
		_tap_object(event.position)


func _on_screen_tap(pos: Vector2) -> void:
	if _state == "hub" and _overlay == null:
		_tap_object(pos)


## Telefonda nesneye dokunmak: Bip'i oraya yürütmeye gerek kalmadan seçer.
func _tap_object(screen_pos: Vector2) -> void:
	var c: Camera3D = get_viewport().get_camera_3d()
	# Önce görünen simgeye (ya da nesnenin kendisine) yakın dokunuş
	var k := get_viewport().get_visible_rect().size.y / 720.0
	var best: Node = null
	var best_d := 110.0 * k
	for m in get_tree().get_nodes_in_group("menu_object"):
		for p in [m.icon_world_position(), m.global_position + Vector3.UP * 1.2]:
			if c.is_position_behind(p):
				continue
			var d := c.unproject_position(p).distance_to(screen_pos)
			if d < best_d:
				best_d = d
				best = m
	if best:
		_activate(best)
		return
	var from := c.project_ray_origin(screen_pos)
	var to := from + c.project_ray_normal(screen_pos) * 60.0
	var q := PhysicsRayQueryParameters3D.create(from, to, 8)
	q.collide_with_areas = true
	q.collide_with_bodies = false
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit and hit.collider.is_in_group("menu_object"):
		_activate(hit.collider)


func _activate(m: Node) -> void:
	Sfx.play("select")
	Haptics.vibrate(20)
	match m.action:
		"play":
			_play_pressed()
		"slot":
			_open_slot(int(m.arg))
		"settings":
			_open_tv()
		"collection":
			_open_collection()
		"quit":
			get_tree().quit()
		"toybox":
			pass
		"wardrobe":
			_open_wardrobe()


# ---------- Oyna / yuvalar ----------

func _play_pressed() -> void:
	var last := GameState.last_played_slot()
	if last < 0:
		_start_game(0, true)
		return
	var d := GameState.slot_summary(last)
	var unlocked := _unlocked_areas(d)
	if unlocked.size() <= 1 and not d.get("game_complete", false):
		_start_game(last, false)
		return
	# Oynanmış alanları yeniden seçme (kaçırılan Altın Vidalar için)
	var v := _new_overlay(700)
	UIKit.title(v, "Nereye gidelim?")
	if not d.get("game_complete", false):
		UIKit.button(v, tr("Devam: ") + tr(GameState.area_info(d.get("area", "ch1_atolye"))["name"]), func(): _start_game(last, false), UIKit.GREEN)
		var fur: String = d.get("furthest", "")
		if fur != "" and fur != d.get("area", ""):
			UIKit.button(v, tr("En ileri nokta: ") + tr(GameState.area_info(fur)["name"]), func(): _start_area(last, GameState.area_info(fur)), UIKit.GREEN)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	for a in unlocked:
		var has_screw: bool = d.get("golden_screws", []).has(a["id"] + "_vida")
		var label: String = tr(a["name"]) + ("  ✓" if has_screw else "")
		var b := UIKit.button(grid, label, func(): _start_area(last, a))
		b.custom_minimum_size = Vector2(320, 56)
		b.add_theme_font_size_override("font_size", 22)
	UIKit.button(v, "Geri", _close_overlay)
	_focus_first(v)


## Kayıttaki ilerlemeye göre açılmış alanlar (bölüm sırasıyla).
func _unlocked_areas(d: Dictionary) -> Array:
	var out := []
	var cur: String = d.get("furthest", d.get("area", "ch1_atolye"))
	var done: bool = d.get("game_complete", false)
	for ch in GameState.CHAPTERS:
		for a in GameState.CHAPTERS[ch]:
			if not ResourceLoader.exists(a["scene"]):
				continue
			out.append(a)
			if a["id"] == cur and not done:
				return out
	return out


func _start_area(slot: int, a: Dictionary) -> void:
	_close_overlay()
	bip.controls_enabled = false
	GameState.start_slot(slot, false)
	GameState.data["area"] = a["id"]
	GameState.data["checkpoint_id"] = "start"
	GameState.data["checkpoint_ability"] = ""
	GameState.set_ability("")
	Scenes.go(a["scene"])


func _start_game(slot: int, fresh: bool) -> void:
	_close_overlay()
	bip.controls_enabled = false
	GameState.start_slot(slot, fresh)
	if fresh or not GameState.data.get("seen_cutscenes", []).has("opening"):
		Scenes.go(OPENING)
	else:
		Scenes.go(GameState.area_info(GameState.data.get("area", "ch1_atolye"))["scene"])


func _slot_text(i: int) -> String:
	var d := GameState.slot_summary(i)
	if d.is_empty():
		return tr("Yuva %d · Boş") % (i + 1)
	var saved_slot := GameState.slot
	var saved := GameState.data
	GameState.data = GameState._migrate(d.duplicate(true))
	var pct := GameState.percent_complete()
	var batt := GameState.total_batteries()
	GameState.data = saved
	GameState.slot = saved_slot
	var info := GameState.area_info(d.get("area", "ch1_atolye"))
	var mins := int(float(d.get("play_time", 0)) / 60.0)
	return tr("Yuva %d · %%%d\n%s · Pil %d · Vida %d/%d · %d dk") % [i + 1, pct, tr(info["name"]), batt, d.get("golden_screws", []).size(), GameState.screw_total(), mins]


func _refresh_capsules() -> void:
	for m in get_tree().get_nodes_in_group("menu_object"):
		if m.kind == "capsule":
			var d := GameState.slot_summary(int(m.arg))
			if d.is_empty():
				m.set_hologram(tr("Boş"))
			else:
				var saved := GameState.data
				GameState.data = GameState._migrate(d.duplicate(true))
				m.set_hologram("%%%d" % GameState.percent_complete())
				GameState.data = saved
		elif m.kind == "showcase":
			var best := 0
			for i in GameState.SLOT_COUNT:
				best = maxi(best, GameState.slot_summary(i).get("golden_screws", []).size())
			m.set_hologram(tr("Vida %d/%d") % [best, GameState.screw_total()])


## Kurtarılan robotlar Atölye'de dans eder (en çok robot kurtarılan yuvadan, en fazla 24).
func _spawn_rescued_robots() -> void:
	var best: Array = []
	for i in GameState.SLOT_COUNT:
		var r: Array = GameState.slot_summary(i).get("robots", [])
		if r.size() > best.size():
			best = r
	var lr := load("res://scripts/entities/lost_robot.gd")
	var anims := ["RobotArmature|Robot_Dance", "RobotArmature|Robot_Wave", "RobotArmature|Robot_Yes", "RobotArmature|Robot_Idle"]
	for i in mini(best.size(), 24):
		var m: Node3D = lr.tinted_robot(best[i], 0.13)
		# İlk 12 robot: kameranın gördüğü tarafta, istasyonun solunda üç sıra; fazlası kapının önünde
		if i < 12:
			m.position = Vector3(-5.6 + (i % 4) * 1.25, 0, 3.4 + (i / 4) * 1.3)
		else:
			m.position = Vector3(-4.9 + ((i - 12) % 6) * 1.6, 0, -6.2 + ((i - 12) / 6) * 1.4)
		m.rotation.y = PI + randf_range(-0.4, 0.4)
		add_child(m)
		var ap: AnimationPlayer = m.find_child("AnimationPlayer", true, false)
		var n: String = anims[absi(String(best[i]).hash()) % anims.size()]
		ap.get_animation(n).loop_mode = Animation.LOOP_LINEAR
		ap.play(n)
		ap.seek(randf() * 1.5, true)


## Oyuncak kutusu: yalnızca açılmış yetenekler denenebilir.
func _refresh_toybox() -> void:
	var unlocked := []
	for i in GameState.SLOT_COUNT:
		for a in GameState.slot_summary(i).get("unlocked_abilities", []):
			if not unlocked.has(a):
				unlocked.append(a)
	for src in get_tree().get_nodes_in_group("toy"):
		var on: bool = unlocked.has(src.ability)
		src.visible = on
		src.monitoring = on
		src.process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED


func _open_slot(i: int) -> void:
	var v := _new_overlay()
	UIKit.title(v, _slot_text(i), 30)
	var empty := GameState.slot_summary(i).is_empty()
	if empty:
		UIKit.button(v, "Yeni Oyun", func(): _start_game(i, true), UIKit.GREEN)
	else:
		UIKit.button(v, "Devam", func(): _start_game(i, false), UIKit.GREEN)
		UIKit.button(v, "Alan Seç", func(): _open_area_select(i))
		UIKit.button(v, "Yeni Oyun", func(): _confirm("Bu yuvadaki kayıt silinip yeni oyun başlasın mı?", func(): _start_game(i, true)))
		UIKit.button(v, "Sil", func(): _confirm(tr("Yuva %d silinsin mi?") % (i + 1), func(): _confirm("Emin misin? Bu geri alınamaz.", func(): _delete(i))), UIKit.RED)
	UIKit.button(v, "Geri", _close_overlay)
	_focus_first(v)


## Ulaşılan alanlardan birini yeniden oyna (Astro Bot'taki gibi). Ayarlardaki test seçeneği hepsini açar.
func _open_area_select(i: int, ch := 0) -> void:
	var d := GameState.slot_summary(i)
	var furthest := GameState.global_index(d.get("furthest", d.get("area", "ch1_atolye")))
	var v := _new_overlay(620 if ch == 0 else 820)
	if ch == 0:
		UIKit.title(v, "Alan Seç")
		for c in GameState.CHAPTERS:
			var first := GameState.global_index(GameState.CHAPTERS[c][0]["id"])
			var open := Settings.all_areas_open() or first <= furthest
			var b := UIKit.button(v, tr("Bölüm %d · %s") % [c, tr(GameState.CHAPTER_NAMES[c])], func(): _open_area_select(i, c))
			b.disabled = not open
	else:
		UIKit.title(v, tr("Bölüm %d · %s") % [ch, tr(GameState.CHAPTER_NAMES[ch])], 32)
		_area_map(v, i, ch, d, furthest)
	UIKit.button(v, "Geri", func(): _open_area_select(i) if ch != 0 else _open_slot(i))
	_focus_first(v)


## Alan haritası: bölümün alanları kıvrılan bir yol üstünde yuvarlak duraklar olarak dizilir. Her durağın altında adı,
## üç yıldızı ve rekor süresi; kilitli duraklar soluk. Dokununca alan açılır. (docs/features/ana-menu/design.md)
func _area_map(v: Node, slot_i: int, ch: int, d: Dictionary, furthest: int) -> void:
	var areas: Array = GameState.CHAPTERS[ch]
	var n := areas.size()
	var w := 760.0
	var h := 350.0
	var map := Control.new()
	map.custom_minimum_size = Vector2(w, h)
	v.add_child(map)
	var pts: Array[Vector2] = []
	for k in n:
		var x := 70.0 + (w - 140.0) * (k / float(maxi(n - 1, 1)))
		pts.append(Vector2(x, 92.0 if k % 2 == 0 else 212.0))
	var line := Line2D.new()
	line.width = 12.0
	line.default_color = Color(0.85, 0.7, 0.45)
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	for k in n:
		line.add_point(pts[k])
	map.add_child(line)
	var star: Texture2D = load("res://assets/ui/kenney/icons/star.png")
	for k in n:
		var a: Dictionary = areas[k]
		var id: String = a["id"]
		var open := Settings.all_areas_open() or GameState.global_index(id) <= furthest
		var boss := id.ends_with("patron")
		var b := Button.new()
		b.text = "!" if boss else str(k + 1)
		b.add_theme_font_size_override("font_size", 30)
		var r := 92.0 if boss else 82.0
		b.custom_minimum_size = Vector2(r, r)
		b.size = Vector2(r, r)
		b.position = pts[k] - Vector2(r, r) / 2.0
		UIKit.style_button(b, UIKit.RED if boss else (UIKit.GREEN if not d.get("best", {}).get(id, {}).is_empty() else UIKit.BLUE), true)
		b.disabled = not open
		b.tooltip_text = tr(a["name"])
		b.pressed.connect(func(): Sfx.play("click", -4.0))
		b.pressed.connect(func(): _play_area(slot_i, id))
		map.add_child(b)
		var name_l := Label.new()
		name_l.text = tr(a["name"])
		name_l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_l.add_theme_font_size_override("font_size", 17)
		name_l.add_theme_color_override("font_color", Color(0.3, 0.2, 0.12) if open else Color(0.3, 0.2, 0.12, 0.45))
		name_l.size = Vector2(150, 44)
		name_l.position = pts[k] + Vector2(-75, r / 2.0 + 2.0)
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		map.add_child(name_l)
		var best: Dictionary = d.get("best", {}).get(id, {})
		if open:
			for sidx in 3:
				var st := TextureRect.new()
				st.texture = star
				st.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				st.size = Vector2(22, 22)
				st.position = pts[k] + Vector2(-35 + sidx * 24, -r / 2.0 - 26.0)
				st.modulate = Color(1.0, 0.8, 0.15) if sidx < int(best.get("stars", 0)) else Color(0.3, 0.2, 0.12, 0.25)
				st.mouse_filter = Control.MOUSE_FILTER_IGNORE
				map.add_child(st)
		if not best.is_empty():
			var tl := Label.new()
			tl.text = GameState.time_text(float(best.get("time", 0.0)))
			tl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tl.add_theme_font_size_override("font_size", 15)
			tl.add_theme_color_override("font_color", Color(0.45, 0.3, 0.15))
			tl.size = Vector2(150, 20)
			tl.position = pts[k] + Vector2(-75, r / 2.0 + 44.0)
			tl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			map.add_child(tl)


## Alan düğmesinin sağ ucunda: üç yıldız simgesi (kazanılanlar altın) ve rekor süre.
func _area_badge(b: Button, stars: int, best_time: float) -> void:
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 2)
	row.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	row.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	row.grow_vertical = Control.GROW_DIRECTION_BOTH
	row.offset_right = -18
	var tex: Texture2D = load("res://assets/ui/kenney/icons/star.png")
	for k in 3:
		var st := TextureRect.new()
		st.texture = tex
		st.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		st.custom_minimum_size = Vector2(30, 30)
		st.modulate = Color(1.0, 0.85, 0.2) if k < stars else Color(0.1, 0.15, 0.3, 0.35)
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(st)
	var tl := Label.new()
	tl.text = "  " + GameState.time_text(best_time)
	tl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	tl.add_theme_font_size_override("font_size", 20)
	tl.add_theme_color_override("font_color", Color.WHITE)
	tl.add_theme_color_override("font_outline_color", Color(0.1, 0.2, 0.4))
	tl.add_theme_constant_override("outline_size", 6)
	row.add_child(tl)
	b.add_child(row)


func _play_area(i: int, id: String) -> void:
	_close_overlay()
	bip.controls_enabled = false
	GameState.start_slot(i, false)
	GameState.data["area"] = id
	GameState.data["chapter"] = GameState.chapter_of(id)
	GameState.data["checkpoint_id"] = "start"
	GameState.data["checkpoint_ability"] = ""
	GameState.set_ability("")
	Scenes.go(GameState.area_info(id)["scene"])


func _delete(i: int) -> void:
	GameState.delete_slot(i)
	Sfx.play("back")
	_close_overlay()
	_refresh_capsules()


func _confirm(text: String, yes: Callable) -> void:
	var v := _new_overlay()
	UIKit.title(v, text, 30)
	UIKit.button(v, "Evet", yes, UIKit.RED)
	UIKit.button(v, "Hayır", _close_overlay, UIKit.GREEN)
	_focus_first(v)


func _open_slots_list() -> void:
	var v := _new_overlay(620)
	UIKit.title(v, "Kayıtlar")
	for i in GameState.SLOT_COUNT:
		var b := UIKit.button(v, _slot_text(i).replace("\n", "  "), func(): _open_slot(i))
		b.add_theme_font_size_override("font_size", 22)
	UIKit.button(v, "Geri", _close_overlay)
	_focus_first(v)


func _open_collection() -> void:
	var best := -1
	var best_n := -1
	for i in GameState.SLOT_COUNT:
		var n: int = GameState.slot_summary(i).get("golden_screws", []).size()
		if n > best_n:
			best_n = n
			best = i
	var v := _new_overlay(600)
	UIKit.title(v, "Koleksiyon")
	if best < 0 or GameState.slot_summary(best).is_empty():
		UIKit.title(v, "Henüz bir şey yok. Kapıdan çıkıp maceraya başla!", 24)
	else:
		var d := GameState.slot_summary(best)
		var pil := 0
		for k in d.get("batteries", {}):
			pil += d["batteries"][k].size()
		UIKit.title(v, tr("Altın Vida %d/%d  ·  Çekirdek Pil %d/4\nGizli Köşe %d/%d  ·  Pil %d") % [d.get("golden_screws", []).size(), GameState.screw_total(),
				d.get("core_cells", []).size(), d.get("secrets", []).size(), GameState.SECRET_TOTAL, pil], 24)
		var stars := 0
		var areas := 0
		for k in d.get("best", {}):
			stars += int(d["best"][k].get("stars", 0))
		for c in GameState.CHAPTERS:
			areas += GameState.CHAPTERS[c].size()
		UIKit.title(v, tr("Yıldız %d/%d") % [stars, areas * 3], 24)
	Achievements.refresh()
	UIKit.button(v, tr("Başarımlar  %d/%d") % [Achievements.count(), Achievements.LIST.size()], _open_achievements, UIKit.YELLOW)
	# Gardırop: kostümler minik Bip'ler olarak; dokunan seçer
	UIKit.title(v, "Kostüm Dolabı", 26)
	SkinCards.build(v, func(id: String): _pick_skin(id, true))
	UIKit.button(v, "Geri", _close_overlay)
	_focus_first_card(v)


func _open_achievements() -> void:
	var v := _new_overlay(760)
	UIKit.title(v, "Başarımlar")
	UIKit.title(v, tr("Her başarım %d bonus pil verir") % Achievements.REWARD, 18)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(720, 380)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 10)
	sc.add_child(grid)
	for a in Achievements.LIST:
		var got := Achievements.has(a[0])
		var l := Label.new()
		l.custom_minimum_size = Vector2(340, 0)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		l.text = tr(a[1]) + "\n" + tr(a[2])
		l.add_theme_font_size_override("font_size", 18)
		l.add_theme_color_override("font_color", Color(0.15, 0.45, 0.15) if got else Color(0.45, 0.4, 0.35, 0.75))
		grid.add_child(l)
	UIKit.button(v, "Geri", _open_collection)
	_focus_first(v)


## Kostüm dolabı: kostümler minik 3B Bip'ler olarak dizilir, dokunan seçer (SkinCards).
func _open_wardrobe(from_collection := false) -> void:
	var v := _new_overlay(600)
	UIKit.title(v, "Kostüm Dolabı")
	SkinCards.build(v, func(id: String): _pick_skin(id, from_collection))
	# Koşu izi: pille açılır (GameState.TRAILS)
	UIKit.title(v, tr("Koşu izi  ·  pilin: %d") % GameState.best_batteries(), 20)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	v.add_child(row)
	# Şapka: yıldızla açılır (GameState.HATS)
	UIKit.title(v, tr("Şapka  ·  yıldızın: %d") % GameState.best_stars(), 20)
	var hrow := HBoxContainer.new()
	hrow.alignment = BoxContainer.ALIGNMENT_CENTER
	hrow.add_theme_constant_override("separation", 8)
	v.add_child(hrow)
	for h in GameState.HATS:
		var hid: String = h["id"]
		var hopen := GameState.hat_unlocked(hid)
		var hb := UIKit.button(hrow, tr(h["name"]) if hopen else tr("%d yıldız") % int(h["need"]),
				func(): Settings.set_value("hat", hid); Sfx.play("select"); _open_wardrobe(from_collection),
				UIKit.GREEN if Settings.hat == hid else UIKit.BLUE)
		hb.add_theme_font_size_override("font_size", 16)
		hb.custom_minimum_size = Vector2(104, 52)
		hb.disabled = not hopen
	for t in GameState.TRAILS:
		var tid: String = t["id"]
		var open := GameState.trail_unlocked(tid)
		var tb := UIKit.button(row, tr(t["name"]) if open else tr("%d pil") % int(t["need"]),
				func(): Settings.set_value("trail", tid); Sfx.play("select"); _open_wardrobe(from_collection),
				UIKit.GREEN if Settings.trail == tid else UIKit.BLUE)
		tb.add_theme_font_size_override("font_size", 18)
		tb.custom_minimum_size = Vector2(104, 52)
		tb.disabled = not open
	UIKit.button(v, "Geri", _open_collection if from_collection else _close_overlay)
	_focus_first_card(v)


func _pick_skin(id: String, from_collection: bool) -> void:
	Settings.set_value("skin", id)
	Sfx.play("select")
	Haptics.vibrate(20)
	if from_collection:
		_open_collection()
	else:
		_open_wardrobe()


func _focus_first_card(v: Node) -> void:
	for b in v.find_children("*", "Button", true, false):
		if not (b as Button).disabled:
			(b as Button).grab_focus.call_deferred()
			return


## Eski televizyon: Ayarlar ve izlenen ara sahneler (hikaye kural 4).
func _open_tv() -> void:
	var v := _new_overlay()
	UIKit.title(v, "Televizyon")
	UIKit.button(v, "Ayarlar", func(): _close_overlay(); _open_settings())
	var seen := []
	for i in GameState.SLOT_COUNT:
		for c in GameState.slot_summary(i).get("seen_cutscenes", []):
			if not seen.has(c):
				seen.append(c)
	if seen.has("opening"):
		UIKit.button(v, "Sahne: Fırtına Gecesi", func():
			load("res://scripts/story/opening.gd").replay = true
			Scenes.go("res://scenes/story/opening.tscn"), UIKit.GREEN)
	if seen.has("closing_ch1") or seen.has("closing_ch2") or seen.has("closing_ch3"):
		UIKit.button(v, "Sahne: Işıklar Geri Geldi", func():
			load("res://scripts/story/closing.gd").replay = true
			Scenes.go("res://scenes/story/closing.tscn"), UIKit.GREEN)
	UIKit.button(v, "Geri", _close_overlay)
	_focus_first(v)


func _open_settings() -> void:
	touch.release_all()
	pause_menu.open_settings_only()


# ---------- Hızlı Menü (≡) ----------

func _build_quick_button() -> void:
	_quick_btn = Button.new()
	_quick_btn.text = "≡"
	_quick_btn.add_theme_font_size_override("font_size", 40)
	_quick_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_quick_btn.position = Vector2(-96, 20)
	_quick_btn.size = Vector2(76, 68)
	_quick_btn.custom_minimum_size = Vector2(76, 68)
	_quick_btn.text = ""
	_quick_btn.icon = load("res://assets/ui/kenney/icons/menuList.png")
	_quick_btn.expand_icon = true
	_quick_btn.position = Vector2(-100, 18)
	_quick_btn.size = Vector2(82, 82)
	_quick_btn.custom_minimum_size = Vector2(82, 82)
	UIKit.style_button(_quick_btn, UIKit.YELLOW, true)
	_quick_btn.pressed.connect(open_quick_menu)
	ui.add_child(_quick_btn)
	# Telefonda dokunmatik Duraklat düğmesi zaten sol üstte; Atölye'de o da hızlı menüyü açar.


func open_quick_menu() -> void:
	if _state != "hub":
		return
	touch.release_all()
	var v := _new_overlay()
	UIKit.title(v, "Atölye")
	var dl := UIKit.title(v, Daily.line(), 20)
	dl.add_theme_color_override("font_color", Color(0.25, 0.5, 0.2) if Settings.daily_done else Color(0.35, 0.3, 0.25))
	var has := GameState.has_any_save()
	if has:
		UIKit.button(v, "Devam", func(): _start_game(GameState.last_played_slot(), false), UIKit.GREEN)
	UIKit.button(v, "Yeni Oyun", _new_game_pick, UIKit.GREEN if not has else UIKit.BLUE)
	UIKit.button(v, "Kayıtlar", _open_slots_list)
	UIKit.button(v, "Ayarlar", func(): _close_overlay(); _open_settings())
	UIKit.button(v, "Koleksiyon", _open_collection)
	UIKit.button(v, "Kostümler", func(): _open_wardrobe())
	if not OS.has_feature("mobile"):
		UIKit.button(v, "Çıkış", func(): get_tree().quit(), UIKit.RED)
	UIKit.button(v, "Kapat", _close_overlay)
	_focus_first(v)


func _new_game_pick() -> void:
	for i in GameState.SLOT_COUNT:
		if GameState.slot_summary(i).is_empty():
			_start_game(i, true)
			return
	_open_slots_list()


func _new_overlay(width := 460.0) -> VBoxContainer:
	_close_overlay()
	bip.controls_enabled = false
	touch.release_all()
	_overlay = Control.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(_overlay)
	UIKit.dim(_overlay)
	return UIKit.panel(_overlay, width)


func _close_overlay() -> void:
	if _overlay:
		_overlay.queue_free()
		_overlay = null
	if _state == "hub":
		bip.controls_enabled = true


func _focus_first(v: Node) -> void:
	for c in v.get_children():
		if c is Button:
			c.grab_focus.call_deferred()
			return


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _overlay:
			_close_overlay()
		elif _state == "hub":
			open_quick_menu()


func _input(event: InputEvent) -> void:
	if _overlay and event.is_action_pressed("ui_cancel"):
		_close_overlay()
		get_viewport().set_input_as_handled()
