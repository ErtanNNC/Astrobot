extends Node
## Pervane ve Buz testi (deneme alanında).
var level: Node
var bip
var fails := 0

func _ready() -> void:
	GameState.data = GameState.new_data()
	level = load("res://scenes/levels/sandbox.tscn").instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = level
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
	await step(10)

func _run() -> void:
	await step(5)
	# Pervane: zıplama basılı tutunca normalden çok daha yükseğe
	GameState.set_ability("pervane")
	await place(Vector3(0, 0.1, 5))
	var y0: float = bip.global_position.y
	Input.action_press("jump")
	var peak := y0
	for i in 150:
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
	Input.action_release("jump")
	check("Pervane ile yükseliş > 6 m", peak - y0 > 6.0, "%.2f m" % (peak - y0))
	await step(80)
	# Pervane atılma: havada Yetenek ile ileri
	await place(Vector3(0, 0.1, 5))
	Input.action_press("jump")
	await step(10)
	Input.action_release("jump")
	var z0: float = bip.global_position.z
	Input.action_press("ability")
	await step(2)
	Input.action_release("ability")
	await step(16)
	check("Pervane atılması ileri götürür", z0 - bip.global_position.z > 2.0, "%.2f m" % (z0 - bip.global_position.z))
	await step(60)
	# Buz: suyun üstünde yürüme
	GameState.set_ability("buz")
	await place(Vector3(0, 0.1, -14))
	Input.action_press("move_forward")
	await step(150)
	Input.action_release("move_forward")
	check("Buz ile su üstünde yürüyüş", bip.global_position.y > -0.5 and bip.global_position.z < -30, str(bip.global_position))
	# Buz: düşmanı dondur, üstüne çık
	var e := level.find_child("Enemy_1", true, false)
	await place(e.global_position + Vector3(0, 0.1, 2.5))
	Input.action_press("ability")
	await step(2)
	Input.action_release("ability")
	await step(5)
	check("Düşman dondu", e._frozen > 0.0)
	bip.invuln = 0.0
	await place(e.global_position + Vector3(0, 2.0, 0))
	await step(40)
	check("Donmuş düşmanın üstünde durulur", bip.is_on_floor() and bip.global_position.y > 1.0 and GameState.lives == 3, str(bip.global_position))
	# Normal Bip suda yüzer, Kaya batar
	GameState.set_ability("")
	await place(Vector3(4.5, 0.5, -22))
	await step(120)
	check("Bip suda yüzer", bip.global_position.y > -1.2, str(bip.global_position))
	GameState.set_ability("kaya")
	await step(150)
	check("Kaya suda batar", bip.global_position.y < -1.5, str(bip.global_position))
