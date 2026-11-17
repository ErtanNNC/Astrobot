extends Node
## M2 testi: kopyalama, Yay zıplaması, düşmana basma, hasarla yetenek kaybı, pil.
## Çalıştırma: godot --headless --path . tests/m2_test.tscn

var level: Node
var bip
var fails := 0


func _ready() -> void:
	GameState.data = GameState.new_data()
	level = load("res://scenes/chapter1/a0_atolye.tscn").instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	bip = level.get_node("GameRig/Bip")
	await _run()
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)


func step(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1


func place(p: Vector3, yaw := PI) -> void:
	bip.reset_state(p)
	bip.facing_yaw = yaw
	bip.rotation.y = yaw
	level.cam.snap_to_target()
	await step(15)


func peak_after_jump(hold_frames := 90) -> float:
	var y0: float = bip.global_position.y
	Input.action_press("jump")
	var peak := y0
	for i in hold_frames:
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
	Input.action_release("jump")
	await step(40)
	return peak - y0


func _run() -> void:
	await step(10)
	check("Başlangıç zeminde", bip.is_on_floor() and absf(bip.global_position.y) < 0.4, str(bip.global_position))

	# Yay olmadan çukurdan çıkış yok: normal zıplama 2,2 m < 4,5 m
	await place(Vector3(9, -3.9, -58.5))
	GameState.set_ability("")
	var h := await peak_after_jump()
	check("Yaysız zıplama çukurdan çıkamaz", h < 2.5, "%.2f m" % h)

	# Kopyalama
	await place(Vector3(9, -3.9, -53.6))
	check("Yay menzilde", bip.best_source() != null)
	Input.action_press("ability")
	await step(2)
	Input.action_release("ability")
	await step(5)
	check("Yay kopyalandı", GameState.ability == "yay", GameState.ability)

	# Yay zıplaması ~5 m
	await place(Vector3(6, -3.9, -57))
	h = await peak_after_jump()
	check("Yay zıplaması ~5 m", absf(h - 5.0) < 0.3, "%.2f m" % h)

	# Şarjlı zıplama ~6,5 m
	await place(Vector3(6, -3.9, -57))
	var y0: float = bip.global_position.y
	Input.action_press("ability")
	await step(40)
	Input.action_release("ability")
	var peak := y0
	for i in 90:
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
	check("Şarjlı Yay ~6,5 m", absf(peak - y0 - 6.5) < 0.35, "%.2f m" % (peak - y0))
	await step(40)

	# Çukurdan P1'e (0,5 m) Yay ile çık
	await place(Vector3(9, -3.9, -58.0))
	Input.action_press("move_forward")
	Input.action_press("jump")
	await step(45)
	Input.action_release("jump")
	for i in 120:
		await get_tree().physics_frame
		if bip.is_on_floor() and bip.global_position.y > 0.3:
			break
	Input.action_release("move_forward")
	await step(20)
	check("Yay ile çukurdan basamağa çıkıldı", absf(bip.global_position.y - 0.5) < 0.15, str(bip.global_position))

	# P1 → P2 (4 m yukarı)
	await place(Vector3(9, 0.6, -62.5))
	Input.action_press("move_forward")
	Input.action_press("jump")
	await step(50)
	Input.action_release("jump")
	for i in 120:
		await get_tree().physics_frame
		if bip.is_on_floor() and bip.global_position.y > 4.0:
			break
	Input.action_release("move_forward")
	await step(20)
	check("Yaylı basamak P1→P2", absf(bip.global_position.y - 4.5) < 0.15, str(bip.global_position))

	# Hasar: yetenek kaybolur, can gitmez
	var lives: int = GameState.lives
	var enemy := level.find_child("Enemy_1", true, false)
	await place(enemy.global_position + Vector3(-2.5, 0.2, 0), PI / 2)
	GameState.set_ability("yay")
	bip.invuln = 0.0
	Input.action_press("move_forward")
	for i in 90:
		await get_tree().physics_frame
		if GameState.ability == "":
			break
	Input.action_release("move_forward")
	check("Hasarla Yay kayboldu", GameState.ability == "", GameState.ability)
	check("Hasarda can gitmedi", GameState.lives == lives, "can %d" % GameState.lives)
	await step(100)

	# Düşmana üstten basma
	enemy = level.find_child("Enemy_1", true, false)
	if enemy:
		var before := level.get_tree().get_nodes_in_group("battery").size() + GameState.total_batteries()
		bip.invuln = 0.0
		await place(enemy.global_position + Vector3(0, 3.0, 0))
		bip.velocity = Vector3(0, -2, 0)
		await step(60)
		check("Düşman ezildi", not is_instance_valid(enemy) or enemy._dead, "")
		var after := level.get_tree().get_nodes_in_group("battery").size() + GameState.total_batteries()
		check("Düşmandan pil saçıldı", after > before, "%d → %d" % [before, after])
	else:
		check("Düşman bulundu", false)

	# Pil toplama
	var b0: int = GameState.total_batteries()
	await place(Vector3(0, 0.1, -6.5))
	Input.action_press("move_forward")
	await step(70)
	Input.action_release("move_forward")
	check("Koridorda pil toplandı", GameState.total_batteries() > b0, "%d → %d" % [b0, GameState.total_batteries()])
