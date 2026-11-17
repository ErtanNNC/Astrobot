extends Node
## Patron testi: üç aşama gerçekten oynanabiliyor mu?
var level: Node
var bip
var boss
var fails := 0

func _ready() -> void:
	GameState.data = GameState.new_data()
	level = load("res://scenes/chapter1/a5_patron.tscn").instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = level
	bip = level.get_node("GameRig/Bip")
	boss = level.find_child("HurdaciVinc", true, false)
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
	await step(10)

func tap(action: String, frames := 2) -> void:
	Input.action_press(action)
	await step(frames)
	Input.action_release(action)

func _run() -> void:
	await step(10)
	await place(Vector3(0, 0.1, 18))
	Input.action_press("move_forward")
	await step(40)
	Input.action_release("move_forward")
	check("Patron başladı", boss.phase == 1, "aşama %d" % boss.phase)
	# Aşama 1: kanca insin, Yay ile üstüne
	GameState.set_ability("yay")
	for i in 600:
		await get_tree().physics_frame
		if boss._hook_state == 2:
			break
	check("Kanca alçaldı", boss._hook_state == 2)
	var hp: Vector3 = boss._hook.global_position
	var side := Vector3(hp.x, 0.1, hp.z) + Vector3(3.6, 0, 0)
	await place(side, -PI / 2)   # kancaya bakıyor (-X)
	bip.invuln = 5.0
	Input.action_press("jump")
	Input.action_press("move_forward")
	await step(30)
	Input.action_release("move_forward")
	await step(10)
	Input.action_release("jump")
	for i in 80:
		await get_tree().physics_frame
		if boss.phase >= 2:
			break
	Input.action_release("move_forward")
	check("Aşama 1: Yay ile kancaya çıkıldı", boss.phase == 2, "aşama %d, bip %s, kanca %s" % [boss.phase, bip.global_position, boss._hook.global_position])
	if boss.phase < 2:
		boss._hit()
	await step(30)
	# Aşama 2: Balon ile şalter adasına süzül
	await place(Vector3(14.3, 4.6, 0), PI / 2)
	GameState.set_ability("balon")
	bip.invuln = 5.0
	Input.action_press("move_forward")
	Input.action_press("jump")
	for i in 300:
		await get_tree().physics_frame
		if bip.global_position.x > 26.0:
			Input.action_release("move_forward")
		if boss.phase >= 3 or bip.global_position.y < -3:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	check("Aşama 2: Balon ile şaltere ulaşıldı", boss.phase == 3, "aşama %d, bip %s" % [boss.phase, bip.global_position])
	if boss.phase < 3:
		boss._hit()
	await step(30)
	# Aşama 3: Mıknatısla tırman
	GameState.set_ability("miknatis")
	await place(Vector3(-5.5, 0.1, 2.5), 0.0)
	var heights := []
	for k in 5:
		await tap("ability")
		for i in 90:
			await get_tree().physics_frame
			if bip.magnet_state == 2:
				break
		heights.append(snappedf(bip.global_position.y, 0.1))
		if k < 4:
			await tap("jump", 3)
			await step(6)
	check("Aşama 3: Mıknatısla tüneğe tırmanıldı", bip.global_position.y > 17.5, "yükseklikler %s" % [heights])
	# Tünekte Kaya kopyala, kabine çakıl
	await place(Vector3(3.0, 19.6, 0.5), -PI / 2)
	GameState.set_ability("kaya")
	Input.action_press("move_forward")
	await step(4)
	await tap("jump", 3)
	await step(14)
	Input.action_release("move_forward")
	await tap("ability", 2)
	await step(90)
	check("Aşama 3: Kaya ile kabin kırıldı", boss.phase >= 4, "aşama %d, bip %s" % [boss.phase, bip.global_position])
	await step(120)
	var cells := []
	for c in level.get_children():
		if c.get_script() and String(c.get_script().resource_path).ends_with("core_cell.gd"):
			cells.append(c)
	check("Çekirdek Pil düştü", cells.size() == 1)
