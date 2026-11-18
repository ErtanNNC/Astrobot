extends Node
## Oyun akışı testi: üç bölümün tüm alanları sırayla açılıyor mu; patron → kapanış → sonuç ekranı →
## sonraki bölüm.
var fails := 0

func _ready() -> void:
	GameState.delete_slot(2)
	GameState.start_slot(2, true)
	var first = load("res://scenes/chapter1/a0_atolye.tscn").instantiate()
	get_tree().root.add_child.call_deferred(first)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = first
	for ch in [1, 2, 3]:
		for a in GameState.CHAPTERS[ch]:
			var cur := get_tree().current_scene
			var ok: bool = cur != null and cur.name == a["id"]
			_check("alan açıldı: " + a["id"], ok, str(cur.name) if cur else "yok")
			if not ok:
				_finish()
				return
			if a["id"].ends_with("_patron"):
				cur.boss_defeated(cur.get_node("GameRig/Bip").global_position + Vector3(0, 0.5, 0))
			else:
				cur.complete_area()
			await get_tree().create_timer(5.5).timeout
		await get_tree().create_timer(18.0).timeout
		var res := get_tree().current_scene
		_check("bölüm %d sonuç ekranı" % ch, res != null and res.name == "Results", str(res.name) if res else "yok")
		if ch < 3:
			# Sonuç ekranındaki "Bölüm N" butonuna bas
			var pressed := false
			for b in res.find_children("*", "Button", true, false):
				if b.text.begins_with("Bölüm %d" % (ch + 1)):
					b.pressed.emit()
					pressed = true
			_check("bölüm %d butonu" % (ch + 1), pressed)
			await get_tree().create_timer(2.0).timeout
	_check("3 çekirdek pil", GameState.data["core_cells"].size() == 3, str(GameState.data["core_cells"]))
	_finish()


func _check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1


func _finish() -> void:
	GameState.delete_slot(2)
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
