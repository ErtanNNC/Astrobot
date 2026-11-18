class_name UIKit
extends RefCounted
## Menülerde ortak görünüş (Astro Bot gibi neşeli, tok): Kenney UI Pack butonları (CC0),
## Nunito yazı tipi (OFL), krem renkli yuvarlak kartlar, açılış ve basma animasyonları.
## Bkz. docs/features/arayuz/design.md

const BTN_HEIGHT := 80.0
const FONT_SIZE := 30
const BLUE := Color(0.25, 0.45, 0.8)
const GREEN := Color(0.3, 0.75, 0.4)
const RED := Color(0.85, 0.3, 0.3)
const YELLOW := Color(1.0, 0.78, 0.2)
const PURPLE := Color(0.55, 0.4, 0.75)
const GREY := Color(0.6, 0.62, 0.68)

const NAVY := Color(0.1, 0.13, 0.3)          ## yazı dış çizgisi, koyu metin
const DIM := Color(0.06, 0.1, 0.25, 0.55)

const BTN_DIR := "res://assets/ui/kenney/buttons/"
const ICON_DIR := "res://assets/ui/kenney/icons/"

## Buton yazısına göre simge (yazının başı eşleşirse)
const ICONS := {
	"Devam": "right", "Oyna": "right", "Başla": "right", "Bölüm": "right",
	"Yeni Oyun": "plus", "Kayıtlar": "save", "Ayarlar": "gear", "Koleksiyon": "trophy",
	"Çıkış": "exit", "Kapat": "cross", "Geri": "arrowLeft", "Vazgeç": "cross",
	"Atölye": "home", "Kontrol noktası": "return", "Sil": "cross", "Evet": "checkmark",
	"Hayır": "cross", "Emeği": "star", "Sahneler": "menuList", "Açılış": "menuList",
}

static var _theme: Theme
static var _tex_cache := {}


static func font() -> Font:
	return load("res://assets/fonts/bip_font.tres")


static func _tex(path: String) -> Texture2D:
	if not _tex_cache.has(path):
		_tex_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex_cache[path]


static func _color_name(col: Color) -> String:
	var best := "blue"
	var best_d := INF
	var table := {"blue": BLUE, "green": GREEN, "red": RED, "yellow": YELLOW, "grey": GREY}
	for n in table:
		var c: Color = table[n]
		var d := Vector3(c.r - col.r, c.g - col.g, c.b - col.b).length()
		if d < best_d:
			best_d = d
			best = n
	return best


## Kenney butonu: normalde "derinlikli", basılınca derinlik kaybolur (içeri gömülür).
static func button_styles(col: Color, round := false) -> Dictionary:
	var cn := _color_name(col)
	var tint := Color.WHITE
	if cn == "grey":
		tint = Color(0.62, 0.66, 0.78)
	if col.is_equal_approx(PURPLE):
		cn = "grey"
		tint = Color(0.78, 0.62, 1.0)
	var shape := "round" if round else "rectangle"
	var normal := StyleBoxTexture.new()
	normal.texture = _tex(BTN_DIR + "%s_button_%s_depth_gradient.png" % [cn, shape])
	normal.modulate_color = tint
	var m := 22.0 if not round else 30.0
	normal.texture_margin_left = m
	normal.texture_margin_right = m
	normal.texture_margin_top = m
	normal.texture_margin_bottom = m + 6.0
	normal.content_margin_left = 22
	normal.content_margin_right = 22
	normal.content_margin_top = 8
	normal.content_margin_bottom = 16
	var hover: StyleBoxTexture = normal.duplicate()
	hover.modulate_color = tint.lightened(0.0) * Color(1.12, 1.12, 1.12)
	var pressed := StyleBoxTexture.new()
	pressed.texture = _tex(BTN_DIR + "%s_button_%s_gradient.png" % [cn, shape])
	pressed.modulate_color = tint * Color(0.92, 0.92, 0.92)
	pressed.texture_margin_left = m
	pressed.texture_margin_right = m
	pressed.texture_margin_top = m
	pressed.texture_margin_bottom = m
	pressed.content_margin_left = 22
	pressed.content_margin_right = 22
	pressed.content_margin_top = 14
	pressed.content_margin_bottom = 10
	pressed.expand_margin_top = -10.0   # basılınca buton aşağı iner
	var disabled: StyleBoxTexture = normal.duplicate()
	disabled.texture = _tex(BTN_DIR + "grey_button_%s_depth_gradient.png" % shape)
	disabled.modulate_color = Color(0.8, 0.8, 0.85, 0.8)
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color(1, 1, 1, 0.95)
	focus.set_border_width_all(4)
	focus.set_corner_radius_all(32 if round else 22)
	focus.set_expand_margin_all(5)
	return {"normal": normal, "hover": hover, "pressed": pressed, "disabled": disabled, "focus": focus,
			"hover_pressed": pressed}


static func card_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.16, 0.24, 0.5, 0.96)
	sb.set_corner_radius_all(36)
	sb.set_content_margin_all(30)
	sb.content_margin_top = 26
	sb.border_color = Color(0.55, 0.78, 1.0, 0.9)
	sb.set_border_width_all(5)
	sb.border_width_bottom = 9
	sb.shadow_color = Color(0, 0.02, 0.1, 0.4)
	sb.shadow_size = 16
	sb.shadow_offset = Vector2(0, 10)
	return sb


## Tüm oyuna uygulanan tema: yazı tipi, dış çizgili beyaz yazılar, butonlar, kaydırıcılar.
static func make_theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 28
	for type in ["Label", "Button", "CheckBox", "CheckButton", "LinkButton", "RichTextLabel"]:
		t.set_color("font_outline_color", type, NAVY)
		t.set_constant("outline_size", type, 9)
	t.set_color("font_color", "Label", Color.WHITE)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0.1, 0.25))
	t.set_constant("shadow_offset_y", "Label", 3)
	t.set_constant("shadow_offset_x", "Label", 0)
	var bs := button_styles(BLUE)
	for st in bs:
		t.set_stylebox(st, "Button", bs[st])
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(c, "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.6))
	t.set_constant("icon_max_width", "Button", 42)
	t.set_constant("h_separation", "Button", 12)
	t.set_stylebox("panel", "PanelContainer", card_style())
	# Kaydırıcı: kalın, yuvarlak iz ve parlak dolgu
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.05, 0.08, 0.22, 0.6)
	track.set_corner_radius_all(14)
	track.content_margin_top = 12
	track.content_margin_bottom = 12
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.35, 0.85, 1.0)
	fill.set_corner_radius_all(14)
	t.set_stylebox("slider", "HSlider", track)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	var grab := _tex(BTN_DIR + "yellow_button_round_depth_gradient.png")
	if grab:
		var img := grab.get_image()
		img.resize(52, 52, Image.INTERPOLATE_LANCZOS)
		var gt := ImageTexture.create_from_image(img)
		t.set_icon("grabber", "HSlider", gt)
		t.set_icon("grabber_highlight", "HSlider", gt)
	_theme = t
	return t


## Kalın, parmakla rahat tutulan kaydırıcı.
static func style_slider(sl: HSlider) -> void:
	var th := make_theme()
	for n in ["slider", "grabber_area", "grabber_area_highlight"]:
		sl.add_theme_stylebox_override(n, th.get_stylebox(n, "HSlider"))
	for n in ["grabber", "grabber_highlight"]:
		sl.add_theme_icon_override(n, th.get_icon(n, "HSlider"))


static func icon_for(text: String) -> Texture2D:
	for k in ICONS:
		if text.begins_with(k):
			return icon(ICONS[k], 40)
	return null


## Kenney simgesi, buton içi boyuta küçültülmüş (önbellekli).
static func icon(name: String, px := 40) -> Texture2D:
	var key := "%s@%d" % [name, px]
	if not _tex_cache.has(key):
		var t := _tex(ICON_DIR + name + ".png")
		if t == null:
			_tex_cache[key] = null
		else:
			var img := t.get_image()
			img.resize(px, px, Image.INTERPOLATE_LANCZOS)
			_tex_cache[key] = ImageTexture.create_from_image(img)
	return _tex_cache[key]


static func panel(parent: Node, min_width := 460.0) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", card_style())
	center.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.custom_minimum_size = Vector2(min_width, 0)
	pc.add_child(v)
	pop_in(pc)
	return v


## Kart açılırken küçükten büyüyerek "zıplar"; içindeki butonlar sırayla belirir.
static func pop_in(c: Control) -> void:
	if not c.is_inside_tree():
		c.ready.connect(pop_in.bind(c), CONNECT_ONE_SHOT)
		return
	c.modulate.a = 0.0
	c.scale = Vector2(0.82, 0.82)
	var go := func():
		if not is_instance_valid(c):
			return
		c.pivot_offset = c.size / 2.0
		var tw := c.create_tween().set_parallel(true)
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(c, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(c, "modulate:a", 1.0, 0.15)
	go.call_deferred()


static func title(parent: Node, text: String, size := 38) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	if size >= 36:
		l.add_theme_color_override("font_color", Color(1.0, 0.86, 0.3))
		l.add_theme_constant_override("outline_size", 12)
	parent.add_child(l)
	return l


static func button(parent: Node, text: String, cb: Callable, col := BLUE) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, BTN_HEIGHT)
	b.add_theme_font_size_override("font_size", FONT_SIZE)
	style_button(b, col)
	b.icon = icon_for(text)
	b.pressed.connect(func(): Sfx.play("click", -4.0))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


## Var olan bir butona renk ve basma animasyonu ver.
static func style_button(b: Button, col := BLUE, round := false) -> void:
	var st := button_styles(col, round)
	for s in st:
		b.add_theme_stylebox_override(s, st[s])
	if not b.has_meta("bouncy"):
		b.set_meta("bouncy", true)
		b.button_down.connect(_squash.bind(b, 0.94))
		b.button_up.connect(_squash.bind(b, 1.0))
		b.mouse_entered.connect(_squash.bind(b, 1.04))
		b.mouse_exited.connect(_squash.bind(b, 1.0))
		b.focus_entered.connect(_squash.bind(b, 1.04))
		b.focus_exited.connect(_squash.bind(b, 1.0))


static func _squash(b: Button, to: float) -> void:
	if not is_instance_valid(b) or not b.is_inside_tree():
		return
	b.pivot_offset = b.size / 2.0
	var tw := b.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(b, "scale", Vector2(to, to), 0.12 if to < 1.0 else 0.22) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func dim(parent: Node) -> ColorRect:
	var d := ColorRect.new()
	d.color = DIM
	d.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(d)
	return d
