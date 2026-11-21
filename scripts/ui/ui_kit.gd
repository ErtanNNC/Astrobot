class_name UIKit
extends RefCounted
## Menülerde ortak görünüş: pzUH "Free Game GUI" (CC0) — krem renkli pencereler, kırmızı
## kurdeleli başlıklar, parlak jöle butonlar, yıldızlar. Yazı tipi Nunito (OFL).
## Butonların içindeki küçük beyaz simgeler Kenney Game Icons (CC0).
## Bkz. docs/features/arayuz/design.md

const BTN_HEIGHT := 84.0
const FONT_SIZE := 30
const BLUE := Color(0.25, 0.45, 0.8)
const GREEN := Color(0.3, 0.75, 0.4)
const RED := Color(0.85, 0.3, 0.3)
const YELLOW := Color(1.0, 0.78, 0.2)
const PURPLE := Color(0.55, 0.4, 0.75)
const GREY := Color(0.6, 0.62, 0.68)

const NAVY := Color(0.1, 0.13, 0.3)
const BROWN := Color(0.45, 0.26, 0.12)        ## krem pencere üstündeki yazı
const OUTLINE := Color(0.3, 0.16, 0.08)       ## HUD ve 3B yazıların dış çizgisi
const RIBBON_TEXT := Color(0.55, 0.06, 0.1)   ## kurdele yazısının dış çizgisi
const DIM := Color(0.08, 0.06, 0.15, 0.5)

const GUI := "res://assets/ui/pzuh/"
const ICON_DIR := "res://assets/ui/kenney/icons/"

## Buton yazısına göre simge (yazının başı eşleşirse)
const ICONS := {
	"Devam": "right", "Oyna": "right", "Başla": "right", "Bölüm": "right",
	"Yeni Oyun": "plus", "Kayıtlar": "save", "Ayarlar": "gear", "Koleksiyon": "trophy",
	"Çıkış": "exit", "Kapat": "cross", "Geri": "arrowLeft", "Vazgeç": "cross",
	"Atölye": "home", "Kontrol noktası": "return", "Sil": "cross", "Evet": "checkmark",
	"Hayır": "cross", "Emeği": "star", "Sahneler": "menuList", "Açılış": "menuList",
}
## Jöle butonun rengine göre yazı dış çizgisi
const BTN_OUTLINE := {
	"blue": Color(0.02, 0.35, 0.6), "green": Color(0.22, 0.42, 0.02),
	"red": Color(0.55, 0.08, 0.14), "grey": Color(0.32, 0.33, 0.38), "purple": Color(0.32, 0.16, 0.5),
}

static var _theme: Theme
static var _panel_theme: Theme
static var _tex_cache := {}


static func font() -> Font:
	return load("res://assets/fonts/bip_font.tres")


static func _tex(path: String) -> Texture2D:
	if not _tex_cache.has(path):
		_tex_cache[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex_cache[path]


static func gui(name: String) -> Texture2D:
	return _tex(GUI + name + ".png")


static func _color_name(col: Color) -> String:
	if col.is_equal_approx(PURPLE):
		return "purple"
	var best := "blue"
	var best_d := INF
	var table := {"blue": BLUE, "green": GREEN, "red": RED, "grey": GREY, "yellow": YELLOW}
	for n in table:
		var c: Color = table[n]
		var d := Vector3(c.r - col.r, c.g - col.g, c.b - col.b).length()
		if d < best_d:
			best_d = d
			best = n
	if best == "yellow":
		best = "green"
	return best


static func _tex_box(tex: Texture2D, m: Vector4, tint := Color.WHITE) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = tex
	s.modulate_color = tint
	s.texture_margin_left = m.x
	s.texture_margin_top = m.y
	s.texture_margin_right = m.z
	s.texture_margin_bottom = m.w
	return s


## Jöle buton: üstüne gelince parlar, basılınca koyulaşır ve yazı aşağı iner.
## round = kare jöle buton (simge butonları için).
static func button_styles(col: Color, round := false) -> Dictionary:
	var cn := _color_name(col)
	var tint := Color.WHITE
	var file := cn
	if cn == "purple":
		file = "grey"
		tint = Color(0.85, 0.65, 1.15)
	var tex := gui(("square_" if round else "button_") + file)
	var m := Vector4(34, 30, 34, 36) if not round else Vector4(28, 28, 28, 32)
	var normal := _tex_box(tex, m, tint)
	normal.content_margin_left = 30
	normal.content_margin_right = 30
	normal.content_margin_top = 8
	normal.content_margin_bottom = 18
	var hover: StyleBoxTexture = normal.duplicate()
	hover.modulate_color = tint * Color(1.1, 1.1, 1.1)
	var pressed: StyleBoxTexture = normal.duplicate()
	pressed.modulate_color = tint * Color(0.85, 0.85, 0.88)
	pressed.content_margin_top = 14
	pressed.content_margin_bottom = 12
	var disabled: StyleBoxTexture = normal.duplicate()
	disabled.texture = gui("square_grey" if round else "button_grey")
	disabled.modulate_color = Color(1, 1, 1, 0.7)
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color(1, 0.95, 0.5, 0.95)
	focus.set_border_width_all(4)
	focus.set_corner_radius_all(26)
	focus.set_expand_margin_all(4)
	return {"normal": normal, "hover": hover, "pressed": pressed, "disabled": disabled, "focus": focus,
			"hover_pressed": pressed}


## Krem pencere (9 parçalı doku): beyaz kenar, köşelerde parlama kabarcıkları.
static func card_style() -> StyleBoxTexture:
	var s := _tex_box(gui("panel"), Vector4(44, 44, 44, 52))
	s.content_margin_left = 34
	s.content_margin_right = 34
	s.content_margin_top = 26
	s.content_margin_bottom = 40
	return s


## Pencere içindeki gömme kutu (istatistik, ayar satırı).
static func inset_style() -> StyleBoxTexture:
	var s := _tex_box(gui("inset"), Vector4(26, 26, 26, 26))
	s.set_content_margin_all(14)
	return s


## Krem pencere içindeki yazılar kahverengi, dış çizgisiz.
static func panel_theme() -> Theme:
	if _panel_theme:
		return _panel_theme
	var t := Theme.new()
	t.set_color("font_color", "Label", BROWN)
	t.set_constant("outline_size", "Label", 0)
	t.set_color("font_shadow_color", "Label", Color(1, 1, 1, 0.5))
	t.set_constant("shadow_offset_y", "Label", 2)
	_panel_theme = t
	return t


## Tüm oyuna uygulanan tema: yazı tipi, dış çizgili beyaz yazılar, butonlar, kaydırıcılar.
static func make_theme() -> Theme:
	if _theme:
		return _theme
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = 28
	for type in ["Label", "Button", "CheckBox", "CheckButton", "LinkButton", "RichTextLabel"]:
		t.set_color("font_outline_color", type, OUTLINE)
		t.set_constant("outline_size", type, 9)
	t.set_color("font_color", "Label", Color.WHITE)
	t.set_color("font_shadow_color", "Label", Color(0.1, 0.05, 0, 0.25))
	t.set_constant("shadow_offset_y", "Label", 3)
	t.set_constant("shadow_offset_x", "Label", 0)
	var bs := button_styles(BLUE)
	for st in bs:
		t.set_stylebox(st, "Button", bs[st])
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		t.set_color(c, "Button", Color.WHITE)
	t.set_color("font_outline_color", "Button", BTN_OUTLINE["blue"])
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.7))
	t.set_constant("icon_max_width", "Button", 40)
	t.set_constant("h_separation", "Button", 12)
	t.set_stylebox("panel", "PanelContainer", card_style())
	# Kaydırıcı: gri iz, pembe dolgu, yıldız tutamak
	var track := _tex_box(gui("bar_grey"), Vector4(14, 10, 14, 10))
	track.content_margin_top = 12
	track.content_margin_bottom = 12
	var fill := _tex_box(gui("bar_pink"), Vector4(14, 10, 14, 10))
	t.set_stylebox("slider", "HSlider", track)
	t.set_stylebox("grabber_area", "HSlider", fill)
	t.set_stylebox("grabber_area_highlight", "HSlider", fill)
	var star := gui("star")
	if star:
		var img := star.get_image()
		img.resize(60, 58, Image.INTERPOLATE_LANCZOS)
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
		if text.begins_with(k) or text.begins_with(TranslationServer.translate(k)):   # çevrilmiş metinde de simge
			return icon(ICONS[k], 40)
	return null


## Kenney beyaz simgesi, buton içi boyuta küçültülmüş (önbellekli).
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


## Krem pencere; içindeki yazılar kahverengi. Başlık için title() kurdele çizer.
static func panel(parent: Node, min_width := 460.0) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", card_style())
	pc.theme = panel_theme()
	center.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.custom_minimum_size = Vector2(min_width, 0)
	pc.add_child(v)
	pop_in(pc)
	return v


## Pencere açılırken küçükten büyüyerek "zıplar".
static func pop_in(c: Control) -> void:
	if not c.is_inside_tree():
		c.ready.connect(pop_in.bind(c), CONNECT_ONE_SHOT)
		return
	c.modulate.a = 0.0
	c.scale = Vector2(0.82, 0.82)
	var go := func():
		if not is_instance_valid(c):
			return
		await c.get_tree().process_frame      # düzen otursun (sarılan yazılar ilk karede çok uzun ölçülür)
		if not is_instance_valid(c):
			return
		await c.get_tree().process_frame
		if not is_instance_valid(c):
			return
		var fit := fit_scale(c)
		var tw := c.create_tween().set_parallel(true)
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(c, "scale", Vector2.ONE * fit, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(c, "modulate:a", 1.0, 0.15)
	go.call_deferred()


## Uzun pencereler (çok düğmeli menüler) kısa ekrana sığsın: gereken ölçeği döndürür ve dönme noktasını
## küçülünce ekranın ortasında kalacak yere koyar. Ölçeği çağıran uygular.
static func fit_scale(c: Control) -> float:
	var sz := c.size
	c.pivot_offset = sz / 2.0
	var vh := c.get_viewport_rect().size.y
	if sz.y <= vh * 0.94:
		return 1.0
	var fit := vh * 0.94 / sz.y
	var top0 := c.global_position.y - (c.pivot_offset.y * (1.0 - c.scale.y))   # ölçeksiz üst kenar
	c.pivot_offset.y = ((vh - sz.y * fit) / 2.0 - top0) / (1.0 - fit)
	return fit


## Büyük başlık (36 px ve üstü) kırmızı kurdele üstünde beyaz yazı; küçükler düz yazı.
static func title(parent: Node, text: String, size := 38) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	if size < 36:
		parent.add_child(l)
		return l
	var ribbon := TextureRect.new()
	ribbon.texture = gui("ribbon")
	ribbon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ribbon.stretch_mode = TextureRect.STRETCH_SCALE
	ribbon.custom_minimum_size = Vector2(0, size * 2.1)
	ribbon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", RIBBON_TEXT)
	l.add_theme_constant_override("outline_size", 10)
	l.add_theme_color_override("font_shadow_color", Color(0.3, 0, 0, 0.35))
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.offset_bottom = -size * 0.35   # kurdelenin şerit kısmına ortala
	ribbon.add_child(l)
	parent.add_child(ribbon)
	var fit := func():
		if is_instance_valid(ribbon) and is_instance_valid(l):
			var w := l.get_minimum_size().x
			var want := maxf(w + size * 4.5, 300.0)
			if parent is Control and (parent as Control).size.x > 0.0:
				want = minf(want, (parent as Control).size.x)
			ribbon.custom_minimum_size.x = want
	fit.call_deferred()
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
	b.add_theme_color_override("font_outline_color", BTN_OUTLINE[_color_name(col)])
	b.add_theme_constant_override("outline_size", 9)
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
