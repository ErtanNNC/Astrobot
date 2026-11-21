extends Control
## Bölüm sonu sonuç ekranı: pil, altın vida, süre. Bkz. GDD Core loop (Oturum).

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	var grad := GradientTexture2D.new()
	grad.gradient = Gradient.new()
	grad.gradient.set_color(0, Color(0.32, 0.62, 1.0))
	grad.gradient.set_color(1, Color(0.12, 0.18, 0.45))
	grad.fill_from = Vector2(0.5, 0.0)
	grad.fill_to = Vector2(0.5, 1.0)
	bg.texture = grad
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_confetti()
	var v := UIKit.panel(self, 820)
	var area: String = GameState.data.get("area", "ch1_patron")
	var ch := GameState.chapter_of(area)
	UIKit.title(v, "Bölüm %d Tamamlandı!" % ch, 44)
	UIKit.title(v, GameState.CHAPTER_NAMES.get(ch, ""), 30)
	var total := 0
	for a in GameState.CHAPTERS[ch]:
		total += GameState.area_battery_count(a["id"])
	var chapter_screws := 0
	for a in GameState.CHAPTERS[ch]:
		if GameState.has_screw(a["id"] + "_vida"):
			chapter_screws += 1
	var max_screws := 0
	for a in GameState.CHAPTERS[ch]:
		if not String(a["id"]).ends_with("patron"):
			max_screws += 1
	_stars(v, 1 + int(chapter_screws * 2 >= max_screws) + int(chapter_screws >= max_screws))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	v.add_child(grid)
	var mins := int(float(GameState.data.get("play_time", 0.0)) / 60.0)
	var stats := [
		["battery", "Pil", total, ""],
		["star", "Altın Vida", chapter_screws, " / %d" % max_screws],
		["trophy", "Çekirdek Pil", GameState.data.get("core_cells", []).size(), " / 4"],
		["medal1", "Kurtarılan robot", GameState.data.get("robots", []).size(), ""],
		["information", "Süre", mins, " dk"],
	]
	if GameState.data.get("game_complete", false):
		stats.append(["checkmark", "Tüm oyun pili", GameState.total_batteries(), ""])
	for i in stats.size():
		_stat(grid, stats[i], 0.25 + i * 0.12)
	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 14)
	v.add_child(btns)
	var b := UIKit.button(btns, "Atölye'ye dön", _home, UIKit.GREEN)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.grab_focus.call_deferred()
	Sfx.play("clear")
	# Sıradaki bölüm varsa Atölye kapısı oradan devam eder
	var nxt := GameState.first_area_of_next_chapter(area)
	if not nxt.is_empty():
		GameState.data["area"] = nxt["id"]
		GameState.note_progress(nxt["id"])
		GameState.data["chapter"] = ch + 1
		GameState.data["checkpoint_id"] = "start"
		GameState.data["checkpoint_ability"] = ""
		GameState.set_ability("")
		var b2 := UIKit.button(btns, "Bölüm %d: %s" % [ch + 1, GameState.CHAPTER_NAMES[ch + 1]], func(): Scenes.go(nxt["scene"]), UIKit.BLUE)
		b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	GameState.save(true)


func _home() -> void:
	load("res://scripts/ui/hub.gd").skip_title = true
	Scenes.go("res://scenes/ui/hub.tscn")



## Simgeli istatistik kartı: sayı sıfırdan sayarak gelir.
func _stat(parent: Node, st: Array, delay: float) -> void:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UIKit.inset_style())
	card.custom_minimum_size = Vector2(228, 0)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(52, 52)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if st[0] == "battery":
		icon.texture = load("res://assets/ui/kenney/icons/star.png")
		icon.modulate = Color(0.3, 0.8, 0.4)
	else:
		icon.texture = load("res://assets/ui/kenney/icons/%s.png" % st[0])
		icon.modulate = Color(0.95, 0.6, 0.15)
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", -6)
	row.add_child(col)
	var num := Label.new()
	num.add_theme_font_size_override("font_size", 40)
	num.text = "0" + st[3]
	col.add_child(num)
	var name_l := Label.new()
	name_l.text = st[1]
	name_l.add_theme_font_size_override("font_size", 20)
	name_l.add_theme_color_override("font_color", Color(0.6, 0.42, 0.25))
	col.add_child(name_l)
	parent.add_child(card)
	card.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(card, "modulate:a", 1.0, 0.2)
	var target := int(st[2])
	tw.tween_method(func(x: float): num.text = str(int(x)) + st[3], 0.0, float(target), clampf(target * 0.03, 0.2, 1.0))
	tw.tween_callback(func(): Sfx.play("pickup", -8.0, 1.3))


## Ekranın üstünden yavaşça düşen renkli konfeti.
func _confetti() -> void:
	var p := CPUParticles2D.new()
	p.amount = 60
	p.lifetime = 6.0
	p.position = Vector2(640, -20)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(700, 10)
	p.direction = Vector2(0, 1)
	p.spread = 20
	p.gravity = Vector2(0, 40)
	p.initial_velocity_min = 40
	p.initial_velocity_max = 90
	p.angular_velocity_min = -180
	p.angular_velocity_max = 180
	p.scale_amount_min = 6
	p.scale_amount_max = 11
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	g.colors = PackedColorArray([Color(1, 0.4, 0.45), Color(1, 0.85, 0.3), Color(0.4, 0.95, 0.5), Color(0.4, 0.8, 1.0), Color(0.8, 0.5, 1.0)])
	p.color_initial_ramp = g
	add_child(p)



## Üç yıldız: kazanılanlar sırayla "pat" diye büyüyerek gelir, kalanlar soluk.
func _stars(parent: Node, n: int) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	for i in 3:
		var t := TextureRect.new()
		t.texture = UIKit.gui("star")
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var sz := 80.0 if i == 1 else 62.0
		t.custom_minimum_size = Vector2(sz, sz)
		t.size_flags_vertical = Control.SIZE_SHRINK_END
		row.add_child(t)
		if i >= n:
			t.modulate = Color(0.55, 0.42, 0.3, 0.35)
			continue
		t.pivot_offset = Vector2(sz, sz) / 2.0
		t.scale = Vector2.ZERO
		var tw := t.create_tween()
		tw.tween_interval(0.35 + i * 0.3)
		tw.tween_callback(func(): Sfx.play("pickup", -4.0, 1.0 + i * 0.15))
		tw.tween_property(t, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
