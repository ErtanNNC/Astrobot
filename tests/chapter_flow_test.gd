extends Node
## Bölüm akışı testi: her alanın sonu bir sonrakini açıyor mu; patrondan kapanışa, sonuç ekranına.
var fails := 0

func _ready() -> void:
	GameState.delete_slot(2)
	GameState.start_slot(2, true)
	var first = load("res://scenes/chapter1/a0_atolye.tscn").instantiate()
	get_tree().root.add_child.call_deferred(first)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = first
	for a in GameState.CHAPTERS[1]:
		var cur := get_tree().current_scene
		var ok: bool = cur != null and cur.name == a["id"]
		print(("GEÇTİ  " if ok else "KALDI  ") + "alan açıldı: " + a["id"] + "  (sahne " + (str(cur.name) if cur else "yok") + ")")
		if not ok:
			fails += 1
			break
		if a["id"] == "ch1_patron":
			cur.boss_defeated(cur.get_node("GameRig/Bip").global_position + Vector3(0, 0.5, 0))
		else:
			cur.complete_area()
		await get_tree().create_timer(5.5).timeout
	# Kapanış sahnesinden sonuç ekranına
	await get_tree().create_timer(18.0).timeout
	var cur := get_tree().current_scene
	var ok := cur != null and cur.name == "Results"
	print(("GEÇTİ  " if ok else "KALDI  ") + "sonuç ekranı  (sahne " + (str(cur.name) if cur else "yok") + ")")
	if not ok:
		fails += 1
	print("çekirdek: ", GameState.data["core_cells"], " alan: ", GameState.data["area"])
	GameState.delete_slot(2)
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
