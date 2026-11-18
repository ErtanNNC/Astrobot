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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.08, 0.18, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.13, 0.2, 0.38, 0.95)
	sb.set_corner_radius_all(28)
	sb.set_content_margin_all(28)
	sb.border_color = Color(1, 1, 1, 0.25)
	sb.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var stack := VBoxContainer.new()
	panel.add_child(stack)

	_main = _column(stack)
	_title(_main, "Duraklatıldı")
	_button(_main, "Devam", resume, Color(0.3, 0.75, 0.4))
	_button(_main, "Kontrol noktasından başla", func(): restart_requested.emit(); resume())
	_button(_main, "Ayarlar", _show_settings)
	_button(_main, "Atölye'ye dön", func(): resume(); home_requested.emit(), Color(0.55, 0.4, 0.75))

	_settings = _column(stack)
	_title(_settings, "Ayarlar")
	_settings.custom_minimum_size.x = 820
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	_settings.add_child(_grid)
	_row("button_size", "Buton boyutu")
	_row("left_handed", "Sol el modu")
	_row("vibration", "Titreşim")
	_row("music_on", "Müzik")
	_row("sfx_on", "Efekt sesleri")
	_row("hints_on", "Pırıl ipuçları")
	_row("shake_on", "Ekran sarsıntısı")
	_row("quality", "Görüntü kalitesi")
	_row("shadows_on", "Gölgeler")
	_button(_settings, "Geri", _show_main, Color(0.3, 0.75, 0.4))
	_settings.visible = false
	_refresh()


func open() -> void:
	if visible:
		return
	_settings_only = false
	visible = true
	get_tree().paused = true
	_show_main()


## Atölye'deki televizyon: yalnızca ayarlar; "Geri" menüyü kapatır.
func open_settings_only() -> void:
	_settings_only = true
	visible = true
	get_tree().paused = true
	_show_settings()


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
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 38)
	parent.add_child(l)


func _button(parent: Node, text: String, cb: Callable, col := Color(0.25, 0.45, 0.8)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, BTN_HEIGHT)
	b.add_theme_font_size_override("font_size", FONT_SIZE)
	for state in ["normal", "hover", "pressed", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color = col.lightened(0.15) if state in ["hover", "focus"] else (col.darkened(0.2) if state == "pressed" else col)
		s.set_corner_radius_all(20)
		if state == "focus":
			s.border_color = Color.WHITE
			s.set_border_width_all(3)
		b.add_theme_stylebox_override(state, s)
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


func _row(key: String, label: String) -> void:
	var b := _button(_grid, label, func(): _toggle(key))
	b.custom_minimum_size = Vector2(395, 70)
	b.add_theme_font_size_override("font_size", 25)
	_rows[key] = [b, label]


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
