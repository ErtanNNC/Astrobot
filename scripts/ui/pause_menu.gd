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
	_row("language", "Dil")
	_row("button_size", "Buton boyutu")
	_row("left_handed", "Sol el modu")
	_row("vibration", "Titreşim")
	_row("hints_on", "Pırıl ipuçları")
	_row("easy_mode", "Kolay mod")
	_row("shake_on", "Ekran sarsıntısı")
	_row("quality", "Görüntü kalitesi")
	_row("shadows_on", "Gölgeler")
	_row("ghost_on", "Rekor hayaleti")
	_row("show_fps", "Kare hızını göster")
	if Settings.dev_mode():
		_row("dev_all_areas", "Tüm alanlar açık (test)")
	_slider("master_vol", "Genel ses")
	_slider("music_vol", "Müzik")
	_slider("sfx_vol", "Efektler")
	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_CENTER
	foot.add_theme_constant_override("separation", 14)
	_settings.add_child(foot)
	_button(foot, "Lisanslar", _show_licenses).custom_minimum_size = Vector2(288, 62)
	_button(foot, "Geri", _show_main, UIKit.GREEN).custom_minimum_size = Vector2(288, 62)
	_settings.visible = false
	_licenses = _column(stack)
	_licenses.custom_minimum_size.x = 900
	_licenses.visible = false
	_refresh()


func open() -> void:
	if visible:
		return
	_settings_only = false
	visible = true
	get_tree().paused = true
	_duck_music(true)
	_show_main()
	UIKit.pop_in(_panel)


## Atölye'deki televizyon: yalnızca ayarlar; "Geri" menüyü kapatır.
func open_settings_only() -> void:
	_settings_only = true
	visible = true
	get_tree().paused = true
	_show_settings()
	UIKit.pop_in(_panel)


## Duraklatınca müzik kısılır (oyun "bekliyor" hissi), devam edince geri gelir.
func _duck_music(on: bool) -> void:
	for mp in get_tree().get_nodes_in_group("music"):
		if on and not mp.has_meta("duck"):
			mp.set_meta("duck", mp.volume_db)
			mp.volume_db -= 9.0
		elif not on and mp.has_meta("duck"):
			mp.volume_db = mp.get_meta("duck")
			mp.remove_meta("duck")


func resume() -> void:
	visible = false
	get_tree().paused = false
	_duck_music(false)
	resumed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		if _settings.visible:
			_show_main()
		else:
			resume()
		get_viewport().set_input_as_handled()


var _licenses: VBoxContainer


## Lisanslar: motorun ve içindeki kitaplıkların yasal bildirimleri + asset kaynakları (mağaza şartı).
func _show_licenses() -> void:
	_settings.visible = false
	_licenses.visible = true
	if _licenses.get_child_count() == 0:
		_title(_licenses, "Lisanslar")
		var sc := ScrollContainer.new()
		sc.custom_minimum_size = Vector2(880, 380)
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		_licenses.add_child(sc)
		var l := Label.new()
		l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 850
		l.add_theme_font_size_override("font_size", 16)
		l.text = _license_text()
		sc.add_child(l)
		_button(_licenses, "Geri", func(): _licenses.visible = false; _show_settings(), UIKit.GREEN)
	_fit_panel()


func _license_text() -> String:
	var t := "Godot Engine\n\n" + Engine.get_license_text() + "\n\n"
	t += "Models: Quaternius (CC0), Kay Lousberg KayKit (CC0), Kenney (CC0), Pixabay (Pixabay Content License).\n"
	t += "Animations: Mixamo (Adobe). Audio: Kenney (CC0), OpenGameArt contributors (CC0). Font: Nunito (SIL OFL 1.1).\n\n"
	t += "Third-party components in Godot Engine:\n"
	for c in Engine.get_copyright_info():
		var who := ""
		for part in c.get("parts", []):
			for cp in part.get("copyright", []):
				who = String(cp)
				break
			break
		var lic := ""
		if c.get("parts", []).size() > 0:
			lic = String(c["parts"][0].get("license", ""))
		t += "• %s — %s (%s)\n" % [c.get("name", ""), who, lic]
	return t


func _show_settings() -> void:
	_main.visible = false
	_settings.visible = true
	if _licenses:
		_licenses.visible = false
	_refresh()
	_grid.get_child(0).grab_focus()
	_fit_panel()


## Ayarlar listesi uzadıkça kısa ekrana sığsın (ana duraklatma menüsünde ölçek 1'e döner).
func _fit_panel() -> void:
	_panel.scale = Vector2.ONE
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(_panel):
		_panel.scale = Vector2.ONE * UIKit.fit_scale(_panel)


func _show_main() -> void:
	if _settings_only:
		resume()
		return
	_settings.visible = false
	_main.visible = true
	_main.get_child(1).grab_focus()
	_fit_panel()


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
	if key == "language":
		Settings.set_value("language", "en" if Settings.current_language() == "tr" else "tr")
		Settings.apply_language()
	elif key == "button_size" or key == "quality":
		Settings.set_value(key, (Settings.get(key) + 1) % 3)
	else:
		Settings.set_value(key, not Settings.get(key))
	_refresh()


func _refresh() -> void:
	for key in _rows:
		var b: Button = _rows[key][0]
		var value: String
		if key == "language":
			value = "Türkçe" if Settings.current_language() == "tr" else "English"
		elif key == "button_size":
			value = ["Küçük", "Orta", "Büyük"][Settings.button_size]
		elif key == "quality":
			value = ["Düşük", "Orta", "Yüksek"][Settings.quality]
		else:
			value = "Açık" if Settings.get(key) else "Kapalı"
		b.text = "%s:  %s" % [tr(_rows[key][1]), tr(value)]
		var col := UIKit.BLUE
		if value == "Açık":
			col = UIKit.GREEN
		elif value == "Kapalı":
			col = UIKit.GREY
		UIKit.style_button(b, col)
