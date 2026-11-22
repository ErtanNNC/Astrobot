extends Node
## Ayarlar penceresi: ayar değiştikçe pencere ekranın içinde kalır, "Geri" düğmesine hep ulaşılır.
## (Geliştirici testi 2026-11-22: bir ayar değişince pencere büyüyor, Geri düğmesi ekran dışına çıkıyordu.)
var fails := 0

func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1

func back_button(pm: Node) -> Button:
	for b in pm._settings.find_children("*", "Button", true, false):
		if (b as Button).text in ["Geri", "Back"]:
			return b
	return null

func inside(pm: Node) -> bool:
	var view: Rect2 = get_viewport().get_visible_rect()
	var b := back_button(pm)
	return b != null and view.encloses(b.get_global_rect()) and view.grow(2.0).encloses((pm._panel as Control).get_global_rect())

func _ready() -> void:
	await get_tree().process_frame
	var keep := [Settings.vibration, Settings.ui_big, Settings.language, Settings.quality]
	Settings.language = "tr"; Settings.apply_language()
	GameState.data = GameState.new_data()
	var level = load("res://scenes/chapter1/a1_yay_bahcesi.tscn").instantiate()
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	for i in 20: await get_tree().process_frame
	var pm = level.pause_menu
	pm.open()
	pm._show_settings()
	for i in 40: await get_tree().process_frame
	check("açılışta pencere ve Geri ekranın içinde", inside(pm))
	for key in ["vibration", "quality", "ui_big", "language", "vibration", "ui_big", "language"]:
		pm._toggle(key)
		for i in 12: await get_tree().process_frame
		check("'%s' değişince pencere ve Geri ekranın içinde" % key, inside(pm), str(back_button(pm).get_global_rect()) if back_button(pm) else "düğme yok")
	Settings.vibration = keep[0]; Settings.ui_big = keep[1]; Settings.language = keep[2]; Settings.quality = keep[3]
	Settings.apply(); Settings.apply_language(); Settings.save_settings()
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
