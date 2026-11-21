extends Node
## Kaybetme: üç can bitince "Pil bitti!" ekranı çıkar ve alan baştan başlar; kolay modda kontrol noktasından devam edilir.
var fails := 0

func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1

func step(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _ready() -> void:
	await get_tree().process_frame
	var keep_easy: bool = Settings.easy_mode
	Settings.language = "tr"; Settings.apply_language()
	GameState.delete_slot(1)
	GameState.start_slot(1, true)
	GameState.data["area"] = "ch1_yay"
	var level = load("res://scenes/chapter1/a1_yay_bahcesi.tscn").instantiate()
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	await step(30)
	var bip = level.get_node("GameRig/Bip")

	# 1) Kolay mod: son canla düşmek kaybettirmez
	Settings.easy_mode = true
	GameState.lives = 1
	bip.global_position.y = level.kill_height - 2.0
	await step(60)
	check("kolay mod: düşünce kaybetme yok, can gitmez", not level.is_game_over and GameState.lives == 1, "can %d" % GameState.lives)

	# 2) Normal: bir düşüş bir can; son can gidince kaybedilir
	Settings.easy_mode = false
	GameState.lives = 1
	var cp = level.find_child("Checkpoint*", true, false)
	cp._light_up(false)              # oyundaki gibi: nokta bir kez yanar, yeniden doğunca tekrar can vermez
	level.on_checkpoint(cp)
	check("yeni kontrol noktası bir can verdi", GameState.lives == 2, "can %d" % GameState.lives)
	bip.global_position.y = level.kill_height - 2.0
	await step(60)
	check("iki candan biri gitti, oyun sürüyor", GameState.lives == 1 and not level.is_game_over and bip.controls_enabled, "can %d" % GameState.lives)
	bip.global_position.y = level.kill_height - 2.0
	await step(60)
	check("son can gidince Pil bitti ekranı", level.is_game_over and not bip.controls_enabled and level._over_panel != null)
	var texts := []
	if level._over_panel:
		for b in level._over_panel.find_children("*", "Button", true, false):
			texts.append((b as Button).text)
	check("ekranda iki seçenek var", texts.has("Baştan dene") and texts.has("Atölye'ye dön"), str(texts))

	# 3) Baştan dene: alan en baştan, canlar dolu
	level.restart_area()
	await get_tree().create_timer(2.0).timeout
	var cur := get_tree().current_scene
	check("alan yeniden yüklendi", cur != null and cur != level and cur.get("area_id") == "ch1_yay", str(cur.name) if cur else "yok")
	check("baştan başladı ve canlar doldu", GameState.data.get("checkpoint_id", "") == "start" and GameState.lives == GameState.MAX_LIVES, "%s can %d" % [GameState.data.get("checkpoint_id", ""), GameState.lives])
	if cur and cur.get("is_game_over") != null:
		check("yeni turda oyun açık", not cur.is_game_over and cur.get_node("GameRig/Bip").controls_enabled)

	Settings.easy_mode = keep_easy
	GameState.delete_slot(1)
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
