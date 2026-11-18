extends Control
## Duraklatma menüsü (telefonda sol üstteki düğme, PC'de Esc) ve hızlı ayarlar.
## Bkz. docs/features/ana-menu/design.md (Duraklatma menüsü) ve
## docs/features/mobil-kontroller/design.md (Ayarlar).

signal resumed
signal restart_requested
signal home_requested

var _settings_only := false

const BTN_HEIGHT := 78.0
const FONT_SIZE := 30

var _main: VBoxContainer
var _settings: VBoxContainer
var _rows := {}
var _grid: GridContainer
var _panel: PanelContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = UIKit.DIM
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIKit.card_style())
	panel.theme = UIKit.panel_theme()
	center.add_child(panel)
	_panel = panel

	var stack := VBoxContainer.new()
	panel.add_child(stack)

	_main = _column(stack)
	_title(_main, "Duraklatıldı")
	_button(_main, "Devam", resume, UIKit.GREEN)
	_button(_main, "Kontrol noktasından başla", func(): restart_requested.emit(); resume())
	_button(_main, "Ayarlar", _show_settings)
	_button(_main, "Atölye'ye dön", func(): resume(); home_requested.emit(), UIKit.PURPLE)

	_settings = _column(stack)
	_title(_settings, "Ayarlar")
	_settings.custom_minimum_size.x = 900
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	_settings.add_child(_grid)
	_row("button_size", "Buton boyutu")
	_row("left_handed", "Sol el modu")
	_row("vibration", "Titreşim")
	_row("hints_on", "Pırıl ipuçları")
	_row("shake_on", "Ekran sarsıntısı")
	_row("quality", "Görüntü kalitesi")
	_row("shadows_on", "Gölgeler")
	_slider("master_vol", "Genel ses")
	_slider("music_vol", "Müzik")
	_slider("sfx_vol", "Efektler")
	_button(_settings, "Geri", _show_main, UIKit.GREEN)
	_settings.visible = false
	_refresh()


func open() -> void:
	if visible:
		return
	_settings_only = false
	visible = true
	get_tree().paused = true
	_show_main()
	UIKit.pop_in(_panel)


## Atölye'deki televizyon: yalnızca ayarlar; "Geri" menüyü kapatır.
func open_settings_only() -> void:
	_settings_only = true
	visible = true
	get_tree().paused = true
	_show_settings()
	UIKit.pop_in(_panel)


func resume() -> void:
	visible = false
	get_tree().paused = false
	resumed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		if _settings.visible:
			_show_main()
		else:
			resume()
		get_viewport().set_input_as_handled()


func _show_settings() -> void:
	_main.visible = false
	_settings.visible = true
	_refresh()
	_grid.get_child(0).grab_focus()


func _show_main() -> void:
	if _settings_only:
		resume()
		return
	_settings.visible = false
	_main.visible = true
	_main.get_child(1).grab_focus()


# ---------- Yardımcılar ----------

func _column(parent: Node) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.custom_minimum_size = Vector2(460, 0)
	parent.add_child(v)
	return v


func _title(parent: Node, text: String) -> void:
	UIKit.title(parent, text, 42)


func _button(parent: Node, text: String, cb: Callable, col := UIKit.BLUE) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, BTN_HEIGHT)
	b.add_theme_font_size_override("font_size", FONT_SIZE)
	UIKit.style_button(b, col)
	b.icon = UIKit.icon_for(text)
	b.pressed.connect(func(): Sfx.play("click", -4.0))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


func _row(key: String, label: String) -> void:
	var b := _button(_grid, label, func(): _toggle(key))
	b.custom_minimum_size = Vector2(288, 62)
	b.add_theme_font_size_override("font_size", 21)
	_rows[key] = [b, label]


## Ses kaydırıcısı (0–100): büyük tutamak, telefonda parmakla rahat kayar.
func _slider(key: String, label: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(170, 0)
	l.add_theme_font_size_override("font_size", 26)
	row.add_child(l)
	var sl := HSlider.new()
	sl.min_value = 0
	sl.max_value = 100
	sl.step = 5
	sl.value = Settings.get(key) * 100.0
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.custom_minimum_size = Vector2(0, 50)
	UIKit.style_slider(sl)
	sl.value_changed.connect(_on_slider.bind(key))
	row.add_child(sl)
	_settings.add_child(row)


static var _grab_tex: Texture2D


static func _grabber_tex() -> Texture2D:
	if _grab_tex == null:
		var img := Image.create(40, 40, false, Image.FORMAT_RGBA8)
		for y in 40:
			for x in 40:
				var d := Vector2(x - 19.5, y - 19.5).length()
				var a := clampf(19.5 - d, 0.0, 1.0)
				var c := Color(1, 1, 1, a) if d < 16 else Color(0.25, 0.75, 0.95, a)
				img.set_pixel(x, y, c)
		_grab_tex = ImageTexture.create_from_image(img)
	return _grab_tex


func _on_slider(v: float, key: String) -> void:
	Settings.set_value(key, v / 100.0)
	if key == "sfx_vol":
		Sfx.play("pickup", -4.0)


func _toggle(key: String) -> void:
	if key == "button_size" or key == "quality":
		Settings.set_value(key, (Settings.get(key) + 1) % 3)
	else:
		Settings.set_value(key, not Settings.get(key))
	_refresh()


func _refresh() -> void:
	for key in _rows:
		var b: Button = _rows[key][0]
		var value: String
		if key == "button_size":
			value = ["Küçük", "Orta", "Büyük"][Settings.button_size]
		elif key == "quality":
			value = ["Düşük", "Orta", "Yüksek"][Settings.quality]
		else:
			value = "Açık" if Settings.get(key) else "Kapalı"
		b.text = "%s:  %s" % [_rows[key][1], value]
		var col := UIKit.BLUE
		if value == "Açık":
			col = UIKit.GREEN
		elif value == "Kapalı":
			col = UIKit.GREY
		UIKit.style_button(b, col)
