extends Control
## Ekran göstergeleri: can (kalpler), pil sayısı, altın vidalar, taşınan yetenek,
## kayıt simgesi, alan adı ve "alan tamam" yazısı. Yazısız: çoğu şey simgeyle.

const HEART := Color(1.0, 0.35, 0.42)
const OUTLINE := Color(0.08, 0.1, 0.25, 0.85)

var _lives := 3
var _batteries := 0
var _shown_batteries := 0.0
var _screws := 0
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
	GameState.lives_changed.connect(func(n): _lives = n; _heart_pop = 1.0; queue_redraw())
	GameState.batteries_changed.connect(func(n): _batteries = n; _batt_pop = 1.0)
	GameState.screws_changed.connect(func(n): _screws = n; queue_redraw())
	GameState.ability_changed.connect(func(a): _ability = a; queue_redraw())
	GameState.saving.connect(func(): _save_t = 1.2)
	_lives = GameState.lives
	_batteries = GameState.total_batteries()
	_shown_batteries = _batteries
	_screws = GameState.data.get("golden_screws", []).size()
	_ability = GameState.ability
	_banner = _make_label(56)
	_sub = _make_label(28)
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
	_sub.position = Vector2(size.x / 2 - 600, 225 * k)
	_sub.size = Vector2(1200, 40)
	for l: Label in [_banner, _sub]:
		var tw: Tween = l.create_tween()
		l.modulate.a = 0.0
		l.scale = Vector2.ONE
		tw.tween_property(l, "modulate:a", 1.0, 0.25)
		tw.tween_interval(hold)
		tw.tween_property(l, "modulate:a", 0.0, 0.5)


func _process(delta: float) -> void:
	_t += delta
	_save_t = maxf(_save_t - delta, 0.0)
	_heart_pop = maxf(_heart_pop - delta * 3.0, 0.0)
	_batt_pop = maxf(_batt_pop - delta * 4.0, 0.0)
	_shown_batteries = move_toward(_shown_batteries, _batteries, maxf(delta * 30.0, absf(_batteries - _shown_batteries) * delta * 6.0))
	queue_redraw()


func _draw() -> void:
	var k := size.y / 720.0
	var font := get_theme_default_font()
	# --- Kalpler (sol üst, duraklat düğmesinin sağında) ---
	for i in GameState.MAX_LIVES:
		var c := Vector2(130 + i * 46, 56) * k
		var full := i < _lives
		var s := 17.0 * k * (1.0 + (0.25 * _heart_pop if i == _lives else 0.0))
		_heart(c, s + 3 * k, OUTLINE)
		_heart(c, s, HEART if full else Color(1, 1, 1, 0.25))
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
	var bs := 1.0 + _batt_pop * 0.3
	_battery_icon(bp, 20 * k * bs)
	var txt := str(int(round(_shown_batteries)))
	draw_string_outline(font, bp + Vector2(28, 13) * k, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, int(36 * k), int(10 * k), OUTLINE)
	draw_string(font, bp + Vector2(28, 13) * k, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, int(36 * k), Color.WHITE)
	# --- Altın vidalar (5 yuva) ---
	for i in 5:
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
