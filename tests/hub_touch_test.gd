extends Node
## Atölye'de dokunmatik etkileşim testi: nesneye dokunma ve Yetenek butonu.
var fails := 0

func _ready() -> void:
	Settings.language = "tr"   # testler düğmeleri Türkçe metinle arar
	Settings.apply_language()
	for i in GameState.SLOT_COUNT:
		GameState.delete_slot(i)
	load("res://scripts/ui/hub.gd").skip_title = true
	var hub = load("res://scenes/ui/hub.tscn").instantiate()
	get_tree().root.add_child.call_deferred(hub)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = hub
	var touch = hub.get_node("GameRig/UI/TouchControls")
	touch.set_process_input(true)
	touch._active = true
	for i in 30: await get_tree().process_frame
	var cam: Camera3D = hub.get_node("GameRig/FollowCamera/Pitch/SpringArm3D/Camera3D")
	# 1) Ekranda görünen bir kapsüle dokun
	var tapped_ok := false
	for name in ["Menu_2", "Menu_3", "Menu_4"]:
		var cap: Node3D = hub.find_child(name, true, false)
		var sp := cam.unproject_position(cap.global_position + Vector3.UP * 1.2)
		var vr := get_viewport().get_visible_rect()
		if cam.is_position_behind(cap.global_position) or not vr.has_point(sp):
			continue
		_touch(4, sp, true)
		await get_tree().process_frame
		_touch(4, sp, false)
		for i in 5: await get_tree().process_frame
		tapped_ok = hub._overlay != null
		print("  dokunulan ", name, " ekran ", sp)
		break
	_check("Kapsüle dokununca yuva paneli açıldı", tapped_ok)
	# Paneldeki "Geri" butonuna parmakla dokun
	var geri: Button = null
	for b in hub._overlay.find_children("*", "Button", true, false):
		if b.text == "Geri":
			geri = b
	var gp := geri.get_global_rect().get_center()
	_touch(5, gp, true)
	await get_tree().process_frame
	_touch(5, gp, false)
	for i in 5: await get_tree().process_frame
	_check("Menü butonuna dokunma çalışıyor (Geri)", hub._overlay == null)
	hub._close_overlay()
	for i in 5: await get_tree().process_frame
	# 2) Kapının önünde Yetenek butonu
	var bip = hub.get_node("GameRig/Bip")
	var door: Node3D = hub.find_child("Menu_1", true, false)
	bip.reset_state(door.global_position + Vector3(0, 0.1, 1.6))
	for i in 10: await get_tree().physics_frame
	var ac: Vector2 = touch._ability_center()
	_touch(3, ac, true)
	await get_tree().process_frame
	await get_tree().process_frame
	_touch(3, ac, false)
	for i in 5: await get_tree().process_frame
	_check("Yetenek butonu kapıyı açtı (yeni oyun başladı)", GameState.slot == 0, "yuva %d" % GameState.slot)
	await get_tree().create_timer(1.0).timeout
	GameState.delete_slot(0)
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)

func _touch(idx: int, pos: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = pos
	e.pressed = pressed
	Input.parse_input_event(e)

func _check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1
