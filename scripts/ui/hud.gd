extends Control
## Ekran göstergeleri: can (kalpler), pil sayısı, altın vidalar, taşınan yetenek,
## kayıt simgesi, alan adı ve "alan tamam" yazısı. Yazısız: çoğu şey simgeyle.

const HEART := Color(1.0, 0.35, 0.42)
const OUTLINE := Color(0.32, 0.17, 0.08, 0.9)   ## krem/kahve tema (UIKit)

var _lives := 3
var _batteries := 0
var _shown_batteries := 0.0
var _screws := 0
var _screw_slots := 5


func _on_lives(n: int) -> void:
	_lives = n
	_heart_pop = 1.0
	queue_redraw()


func _on_batteries(n: int) -> void:
	_batteries = n
	_batt_pop = 1.0


func _on_screws(_n: int) -> void:
	_refresh_screws()
	queue_redraw()


func _on_ability(a: String) -> void:
	_ability = a
	queue_redraw()


func _on_saving() -> void:
	_save_t = 1.2


## Bu bölümün Altın Vidaları: yuva sayısı = bölümdeki (patron dışı) alan sayısı.
func _refresh_screws() -> void:
	var area: String = GameState.data.get("area", "ch1_atolye")
	var ch := GameState.chapter_of(area)
	_screw_slots = 0
	_screws = 0
	for a in GameState.CHAPTERS[ch]:
		if a["id"].ends_with("_patron"):
			continue
		_screw_slots += 1
		if GameState.has_screw(a["id"] + "_vida"):
			_screws += 1
var _ability := ""
var _save_t := 0.0
var _heart_pop := 0.0
var _batt_pop := 0.0
var _t := 0.0
var _banner: Label
var _sub: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# Yöntemlere bağlanır (lambda değil): sahne kapanınca bağlantı kendiliğinden kopar
	GameState.lives_changed.connect(_on_lives)
	GameState.batteries_changed.connect(_on_batteries)
	GameState.screws_changed.connect(_on_screws)
	GameState.ability_changed.connect(_on_ability)
	GameState.saving.connect(_on_saving)
	_lives = GameState.lives
	_batteries = GameState.total_batteries()
	_shown_batteries = _batteries
	_refresh_screws()
	_ability = GameState.ability
	_banner = _make_label(64)
	_banner.add_theme_color_override("font_color", Color(1.0, 0.87, 0.3))
	_banner.add_theme_constant_override("outline_size", 16)
	_banner.add_theme_color_override("font_outline_color", Color(0.6, 0.1, 0.12))
	_sub = _make_label(30)
	_sub.add_theme_color_override("font_color", UIKit.BROWN)
	_sub.add_theme_constant_override("outline_size", 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.94, 0.76, 0.95)
	sb.border_color = Color.WHITE
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(24)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 4
	sb.content_margin_bottom = 6
	_sub.add_theme_stylebox_override("normal", sb)
	_banner.modulate.a = 0.0
	_sub.modulate.a = 0.0


func _make_label(size: int) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", 12)
	l.set_anchors_preset(Control.PRESET_CENTER_TOP)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


## Büyük başlık (alan adı, "Tamam!" vb.)
func banner(text: String, sub := "", hold := 2.0) -> void:
	var k := size.y / 720.0
	_banner.text = text
	_sub.text = sub
	_banner.position = Vector2(size.x / 2 - 600, 150 * k)
	_banner.size = Vector2(1200, 80)
	_sub.visible = sub != ""
	_sub.size = Vector2.ZERO
	var sw := _sub.get_combined_minimum_size().x
	_sub.position = Vector2((size.x - sw) / 2.0, 232 * k)
	for l: Label in [_banner, _sub]:
		l.pivot_offset = l.size / 2.0
		if _banner_tweens.has(l) and _banner_tweens[l].is_valid():
			_banner_tweens[l].kill()   # önceki yazının sönmesi yenisini silmesin
		var tw: Tween = l.create_tween()
		_banner_tweens[l] = tw
		l.modulate.a = 0.0
		l.scale = Vector2(0.4, 0.4) if l == _banner else Vector2(1, 0.2)
		tw.set_parallel(true)
		tw.tween_property(l, "modulate:a", 1.0, 0.2)
		tw.tween_property(l, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.0 if l == _banner else 0.12)
		tw.chain().tween_interval(hold)
		tw.chain().tween_property(l, "modulate:a", 0.0, 0.5)


## Küçük bildirim (başarım, ödül): ekranın altında kayarak gelir, sıraya girer, oyunu kapatmaz.
var _toast_n := 0


func toast(text: String) -> void:
	var k := size.y / 720.0
	var l := Label.new()
	l.text = text
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.add_theme_font_size_override("font_size", int(26 * k))
	l.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	l.add_theme_color_override("font_outline_color", OUTLINE)
	l.add_theme_constant_override("outline_size", 10)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size = Vector2(size.x, 40 * k)
	l.position = Vector2(0, size.y)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var delay := _toast_n * 1.6
	_toast_n += 1
	var tw := l.create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(func(): Sfx.play("secret", -6.0, 1.2))
	tw.tween_property(l, "position:y", size.y - 150 * k, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.4)
	tw.tween_property(l, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): _toast_n = maxi(_toast_n - 1, 0); l.queue_free())


## Alan sonu: üç yıldız yuvası; kazanılanlar sırayla, sesle patlayarak dolar (docs/features/geri-donme/design.md).
func show_stars(won: int) -> void:
	var k := size.y / 720.0
	var tex: Texture2D = load("res://assets/ui/kenney/icons/star.png")
	var px := 92.0 * k
	for i in 3:
		var slot := TextureRect.new()
		slot.texture = tex
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.size = Vector2(px, px)
		slot.pivot_offset = slot.size / 2.0
		slot.position = Vector2(size.x / 2.0 + (i - 1) * px * 1.15 - px / 2.0, 285.0 * k + (0.0 if i == 1 else 14.0 * k))
		slot.modulate = Color(0.25, 0.2, 0.15, 0.55)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)
		var tw := slot.create_tween()
		tw.tween_property(slot, "scale", Vector2.ONE, 0.25).from(Vector2.ZERO).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if i < won:
			tw.tween_interval(0.35 + i * 0.4)
			tw.tween_callback(func():
				slot.modulate = Color(1.0, 0.82, 0.2)
				Sfx.play("pickup", 0.0, 1.0 + i * 0.2, 0.0)
				Haptics.vibrate(25))
			tw.tween_property(slot, "scale", Vector2.ONE, 0.35).from(Vector2(1.7, 1.7)).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tw.tween_interval(2.6)
		tw.tween_property(slot, "modulate:a", 0.0, 0.4)
		tw.tween_callback(slot.queue_free)


var _fps: Label
var _fps_t := 0.0
var _fps_min := 999.0


## Kare hızı göstergesi (Ayarlar → "Kare hızını göster"): anlık FPS ve son yarım saniyenin en düşüğü.
func _update_fps(delta: float) -> void:
	if not Settings.show_fps:
		if _fps:
			_fps.visible = false
		return
	if _fps == null:
		_fps = Label.new()
		_fps.add_theme_font_size_override("font_size", 20)
		_fps.add_theme_color_override("font_color", Color.WHITE)
		_fps.add_theme_color_override("font_outline_color", Color.BLACK)
		_fps.add_theme_constant_override("outline_size", 6)
		_fps.set_anchors_preset(Control.PRESET_CENTER_TOP)
		_fps.position.y = 6
		_fps.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_fps)
	_fps.visible = true
	_fps_min = minf(_fps_min, 1.0 / maxf(delta, 0.0001))
	_fps_t += delta
	if _fps_t >= 0.5:
		_fps.text = tr("%d FPS (en düşük %d)") % [Engine.get_frames_per_second(), int(_fps_min)]
		_fps_t = 0.0
		_fps_min = 999.0


func _process(delta: float) -> void:
	_update_fps(delta)
	_t += delta
	_save_t = maxf(_save_t - delta, 0.0)
	_heart_pop = maxf(_heart_pop - delta * 3.0, 0.0)
	_batt_pop = maxf(_batt_pop - delta * 4.0, 0.0)
	_shown_batteries = move_toward(_shown_batteries, _batteries, maxf(delta * 30.0, absf(_batteries - _shown_batteries) * delta * 6.0))
	queue_redraw()


var _pill: StyleBoxFlat
var _banner_tweens := {}


## Göstergelerin arkasındaki yarı saydam yuvarlak hap zemin
func _draw_pill(r: Rect2) -> void:
	if _pill == null:
		_pill = StyleBoxFlat.new()
		_pill.bg_color = Color(1.0, 0.93, 0.74, 0.88)
		_pill.border_color = Color(1, 1, 1, 0.95)
		_pill.shadow_color = Color(0.3, 0.15, 0.05, 0.3)
		_pill.shadow_size = 4
		_pill.shadow_offset = Vector2(0, 3)
		_pill.set_border_width_all(3)
		_pill.border_width_bottom = 5
	_pill.set_corner_radius_all(int(r.size.y / 2))
	draw_style_box(_pill, r)


func _draw() -> void:
	var k := size.y / 720.0
	var font := get_theme_default_font()
	_draw_pill(Rect2(Vector2(100, 28) * k, Vector2(GameState.MAX_LIVES * 46 + 16 + (60 if _ability != "" else 0), 58) * k))
	_draw_pill(Rect2(Vector2(size.x - 222 * k, 26 * k), Vector2(178, 60) * k))
	# --- Kalpler (sol üst, duraklat düğmesinin sağında) ---
	for i in GameState.MAX_LIVES:
		var c := Vector2(130 + i * 46, 56) * k
		var full := i < _lives
		var s := 17.0 * k * (1.0 + (0.25 * _heart_pop if i == _lives else 0.0))
		s *= 1.0 + 0.06 * sin(_t * 3.0 + i * 0.8) if full else 1.0   # hafif nefes alma
		_heart(c, s + 3.5 * k, OUTLINE)
		_heart(c, s, HEART if full else Color(1, 1, 1, 0.25))
		if full:
			draw_circle(c + Vector2(-0.55, -0.45) * s, 0.2 * s, Color(1, 1, 1, 0.75))  # parlama
	# --- Taşınan yetenek ---
	if _ability != "":
		var ac := Vector2(130 + 3 * 46 + 30, 56) * k
		draw_circle(ac, 27 * k, OUTLINE)
		draw_circle(ac, 24 * k, AbilityModels.color(_ability))
		_ability_glyph(ac, 15 * k, _ability)
		var bip := get_tree().get_first_node_in_group("player")
		if bip:
			var f: float = bip.drop_fraction()
			if f > 0.0:
				draw_arc(ac, 31 * k, -PI / 2, -PI / 2 + TAU * f, 32, Color(1, 1, 1, 0.9), 5 * k, true)
	# --- Pil sayacı (sağ üst) ---
	var bp := Vector2(size.x - 190 * k, 56 * k)
	if _batt_pop > 0.0:
		draw_circle(bp, 34 * k * (1.0 + (1.0 - _batt_pop) * 0.6), Color(0.5, 1.0, 0.6, 0.35 * _batt_pop))
	var bs := 1.0 + _batt_pop * 0.3
	_battery_icon(bp, 20 * k * bs)
	var txt := str(int(round(_shown_batteries)))
	var fs := int(40 * k * bs)
	draw_string_outline(font, bp + Vector2(30, 14) * k, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, int(12 * k), OUTLINE)
	draw_string(font, bp + Vector2(30, 14) * k, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	# --- Altın vidalar (5 yuva) ---
	for i in _screw_slots:
		var sc := Vector2(size.x - 190 * k + i * 30 * k, 98 * k)
		draw_circle(sc, 11 * k, OUTLINE)
		draw_circle(sc, 9 * k, Color(1, 0.8, 0.2) if i < _screws else Color(1, 1, 1, 0.2))
		if i < _screws:
			draw_line(sc - Vector2(5, 0) * k, sc + Vector2(5, 0) * k, Color(0.5, 0.35, 0.05), 2 * k)
	# --- Kayıt simgesi: dönen anten ---
	if _save_t > 0.0:
		var sv := Vector2(size.x - 50 * k, 140 * k)
		var a := clampf(_save_t * 2.0, 0.0, 1.0)
		var r := 14 * k
		var ang := _t * 6.0
		draw_line(sv, sv + Vector2(cos(ang), sin(ang)) * r, Color(1, 1, 1, a), 3 * k)
		draw_circle(sv + Vector2(cos(ang), sin(ang)) * r, 5 * k, Color(0.4, 0.95, 1.0, a))
		draw_circle(sv, 4 * k, Color(1, 1, 1, a))


func _heart(c: Vector2, s: float, col: Color) -> void:
	draw_circle(c + Vector2(-0.5, -0.25) * s, 0.55 * s, col)
	draw_circle(c + Vector2(0.5, -0.25) * s, 0.55 * s, col)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-1.03, -0.05) * s, c + Vector2(1.03, -0.05) * s, c + Vector2(0, 1.05) * s]), col)


func _battery_icon(c: Vector2, s: float) -> void:
	var r := Rect2(c + Vector2(-0.5, -0.9) * s, Vector2(1.0, 1.8) * s)
	draw_rect(r.grow(3), OUTLINE)
	draw_rect(r, Color(0.3, 0.95, 0.45))
	draw_rect(Rect2(c + Vector2(-0.5, 0.4) * s, Vector2(1.0, 0.5) * s), Color(0.12, 0.14, 0.2))
	draw_rect(Rect2(c + Vector2(-0.22, -1.15) * s, Vector2(0.44, 0.25) * s), Color(0.95, 0.85, 0.3))


func _ability_glyph(c: Vector2, s: float, a: String) -> void:
	var w := Color.WHITE
	match a:
		"yay":
			var pts := PackedVector2Array()
			for i in 7:
				pts.append(c + Vector2((-0.6 if i % 2 == 0 else 0.6) * s, (0.8 - i * 0.27) * s))
			draw_polyline(pts, w, 3.0, true)
		"balon":
			draw_circle(c + Vector2(0, -0.2) * s, 0.6 * s, w)
			draw_line(c + Vector2(0, 0.4) * s, c + Vector2(0.1, 1.0) * s, w, 2.0)
		"miknatis":
			draw_arc(c + Vector2(0, 0.1) * s, 0.55 * s, 0, PI, 16, w, 4.0)
			draw_line(c + Vector2(-0.55, 0.1) * s, c + Vector2(-0.55, -0.7) * s, w, 4.0)
			draw_line(c + Vector2(0.55, 0.1) * s, c + Vector2(0.55, -0.7) * s, w, 4.0)
		"pervane":
			draw_line(c + Vector2(-0.9, -0.5) * s, c + Vector2(0.9, -0.5) * s, w, 4.0)
			draw_line(c + Vector2(0, -0.5) * s, c + Vector2(0, 0.1) * s, w, 3.0)
			draw_arc(c + Vector2(0, 0.6) * s, 0.5 * s, PI, TAU, 12, w, 4.0)
		"buz":
			for i in 3:
				var ang := i * PI / 3.0
				draw_line(c - Vector2(cos(ang), sin(ang)) * 0.85 * s, c + Vector2(cos(ang), sin(ang)) * 0.85 * s, w, 3.0)
		"kaya":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-0.8, 0.6) * s, c + Vector2(-0.5, -0.4) * s, c + Vector2(0.1, -0.8) * s,
				c + Vector2(0.75, -0.2) * s, c + Vector2(0.8, 0.6) * s]), w)
