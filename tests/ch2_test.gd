extends Node
## Bölüm 2 alan testi: doğma, kontrol noktası/çıkış altında zemin, her alanın ana mekaniği.
## Çalıştırma: godot --headless --path . tests/ch2_test.tscn

var level: Node
var bip
var fails := 0


func _ready() -> void:
	await get_tree().process_frame
	for path in ["res://scenes/chapter2/b1_rihtim.tscn", "res://scenes/chapter2/b2_fener.tscn",
			"res://scenes/chapter2/b3_gemi_mezarligi.tscn", "res://scenes/chapter2/b4_patron.tscn"]:
		await _load(path)
		await _common(path.get_file())
		match path.get_file():
			"b1_rihtim.tscn":
				await _b1()
			"b2_fener.tscn":
				await _b2()
			"b3_gemi_mezarligi.tscn":
				await _b3()
			"b4_patron.tscn":
				await _b4()
		level.queue_free()
		await get_tree().process_frame
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)


func _load(path: String) -> void:
	GameState.data = GameState.new_data()
	GameState.slot = -1
	level = load(path).instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = level
	bip = level.get_node("GameRig/Bip")
	await step(20)


func step(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1


func place(p: Vector3, yaw := PI, ability := "") -> void:
	await step(35)   # önceki düşüşün yeniden doğma perdesi bitsin
	GameState.set_ability(ability)
	bip.reset_state(p)
	bip.facing_yaw = yaw
	bip.rotation.y = yaw
	bip.invuln = 30.0
	level.cam.snap_to_target()
	await step(8)


func floor_under(p: Vector3) -> bool:
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 0.6, p + Vector3.DOWN * 1.5, 1, [bip.get_rid()])
	return not space.intersect_ray(q).is_empty()


func _common(n: String) -> void:
	check("%s: doğma zeminde" % n, bip.is_on_floor(), str(bip.global_position))
	var bad := []
	for cp in get_tree().get_nodes_in_group("checkpoint"):
		if not floor_under(cp.global_position):
			bad.append(cp.checkpoint_id)
	for e in level.find_children("Exit*", "", true, false):
		if not floor_under(e.global_position):
			bad.append(String(e.name))
	check("%s: kontrol noktaları ve çıkış zeminde" % n, bad.is_empty(), str(bad))


## Zıpla (+ basılı tut), ileri git; y_min üstünde yere inince dur.
func jump_forward(hold_frames: int, fwd_frames: int, y_min: float, max_frames := 300, fwd_start := 0) -> bool:
	Input.action_press("jump")
	if fwd_start == 0:
		Input.action_press("move_forward")
	for i in max_frames:
		await get_tree().physics_frame
		if i == fwd_start and fwd_start > 0:
			Input.action_press("move_forward")
		if i == hold_frames:
			Input.action_release("jump")
		if i == fwd_frames:
			Input.action_release("move_forward")
		if i > 10 and bip.is_on_floor() and bip.global_position.y > y_min:
			break
		if bip.global_position.y < -5.5:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	return bip.is_on_floor() and bip.global_position.y > y_min


func tap(action: String, frames := 2) -> void:
	Input.action_press(action)
	await step(frames)
	Input.action_release(action)


func _b1() -> void:
	await place(Vector3(0, 0.1, -8.5), PI, "pervane")
	var ok := await jump_forward(110, 90, 5.0)
	check("b1: Pervane ile 5,5 m'lik iskeleye", ok and absf(bip.global_position.y - 5.5) < 0.2, str(bip.global_position))
	await place(Vector3(0, 0.1, -8.5), PI, "yay")
	ok = await jump_forward(60, 60, 5.0, 150)
	check("b1: Yay ile iskeleye çıkılamaz", not ok, str(bip.global_position))
	await place(Vector3(0, 4.1, -80.5), PI, "pervane")
	ok = await jump_forward(110, 50, 2.5)
	check("b1: ada → deniz geçişi", ok and bip.global_position.z < -86.2, str(bip.global_position))
	await place(Vector3(0, 3.1, -89), PI, "pervane")
	ok = await jump_forward(110, 95, 5.5, 300, 25)
	check("b1: 3 m yukarı + geçiş", ok and bip.global_position.z < -95.5, str(bip.global_position))
	await place(Vector3(-3.4, 4.1, -77), -PI / 2, "pervane")   # adanın batı kenarı
	ok = await jump_forward(110, 80, 8.5, 300, 45)
	check("b1: Altın Vida direğine Pervane ile", ok, str(bip.global_position))
	await place(Vector3(0, 2.6, -107), PI, "pervane")
	ok = await jump_forward(110, 70, 3.0, 300, 20)
	check("b1: son geçiş varış rıhtımına", ok and bip.global_position.z < -112, str(bip.global_position))


func _b2() -> void:
	await place(Vector3(0, 0.1, 9.5), PI, "yay")
	var ok := await jump_forward(40, 20, 3.0)
	check("b2: Yay ile ilk basamak (3,5 m)", ok and absf(bip.global_position.y - 3.5) < 0.2, str(bip.global_position))
	# balkon → y 20,5 basamağı (Pervane)
	var bx := cos(deg_to_rad(-45.0)) * 7.2
	var bz := sin(deg_to_rad(-45.0)) * 7.2
	var target := Vector3(0, 20.5, -6.5)
	var from := Vector3(bx, 14.1, bz)
	var yaw := atan2(target.x - from.x, target.z - from.z)
	await place(from, yaw, "pervane")
	ok = await jump_forward(110, 90, 19.0, 300, 40)
	check("b2: Pervane ile 6,5 m'lik basamak", ok and bip.global_position.y > 20.3, str(bip.global_position))
	# y 27 basamağından rüzgâra, galeriye
	var s27 := Vector3(cos(deg_to_rad(-135.0)) * 6.5, 27.1, sin(deg_to_rad(-135.0)) * 6.5)
	var col := Vector3(-6.5, 27, 0)
	await place(s27, atan2(col.x - s27.x, col.z - s27.z), "pervane")
	Input.action_press("jump")
	Input.action_press("move_forward")
	await step(30)
	Input.action_release("move_forward")
	var peak := 0.0
	for i in 260:
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
		if bip.global_position.y > 37.5:
			break
	# Galeriye doğru (+z) sürüklen
	bip.facing_yaw = 0.0
	level.cam.snap_to_target()
	Input.action_press("move_forward")
	for i in 200:
		await get_tree().physics_frame
		if bip.global_position.z > 3.2:
			Input.action_release("move_forward")
		if bip.is_on_floor():
			break
	Input.action_release("move_forward")
	Input.action_release("jump")
	await step(10)
	check("b2: rüzgâr Pervane'yi galeriye taşır", bip.is_on_floor() and bip.global_position.y > 35.5, "tepe %.1f, %s" % [peak, bip.global_position])


func _b3() -> void:
	# Mıknatıs zinciri: kumsaldan M1'e
	await place(Vector3(0, 0.1, -5), PI, "miknatis")
	await tap("ability")
	for i in 90:
		await get_tree().physics_frame
		if bip.magnet_state == 2:
			break
	check("b3: Mıknatıs ile ilk metal gövdeye", bip.magnet_state == 2, str(bip.global_position))
	var reached := []
	for k in 3:
		await tap("jump", 3)           # üstüne tırman
		for i in 90:
			await get_tree().physics_frame
			if bip.is_on_floor() and i > 5:
				break
		await tap("ability")           # sıradaki metale çekil
		for i in 90:
			await get_tree().physics_frame
			if bip.magnet_state == 2:
				break
		reached.append(snappedf(bip.global_position.z, 0.1))
		if bip.global_position.z < -23.0:
			break
	check("b3: gövde zinciri ile gemiye (z < -23)", bip.magnet_state == 2 and bip.global_position.z < -23, str(reached))
	await tap("jump", 3)
	for i in 90:
		await get_tree().physics_frame
		if bip.is_on_floor() and i > 5:
			break
	await step(10)
	check("b3: gemi güvertesine çıkıldı", bip.is_on_floor() and absf(bip.global_position.y - 2.0) < 0.3, str(bip.global_position))
	# Kaya ile çatlak güverteyi kır
	await place(Vector3(0, 4.5, -43.5), PI, "kaya")
	await step(4)
	await tap("ability")
	await step(60)
	check("b3: Kaya ile ambara inildi", bip.global_position.y < 0.0 and bip.is_on_floor(), str(bip.global_position))
	# Su altı yolu: Kaya ile duvarın altından geç, merdivenden çık
	await place(Vector3(0, -0.9, -51.5), PI, "kaya")
	Input.action_press("move_forward")
	for i in 900:
		await get_tree().physics_frame
		if i % 30 == 0:
			Input.action_press("jump")
		elif i % 30 == 20:
			Input.action_release("jump")
		if bip.global_position.z < -71.0:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	check("b3: Kaya ile su altından iskeleye", bip.global_position.z < -70.5 and bip.global_position.y > -0.3, str(bip.global_position))
	# Normal Bip duvarı geçemez
	await place(Vector3(0, -0.9, -51.5), PI, "")
	Input.action_press("move_forward")
	await step(300)
	Input.action_release("move_forward")
	check("b3: Kayasız su üstünden geçilemez", bip.global_position.z > -60.7, str(bip.global_position))
	# Balon: Yay basamağından 12 m süzülme
	await place(Vector3(0, 4.6, -81.5), PI, "balon")
	var ok := await jump_forward(250, 250, 2.5)
	check("b3: Balon ile 12 m'lik boşluk", ok and bip.global_position.z < -93.5, str(bip.global_position))
	# Mıknatıs ile mavi platformun metal yüzüne, üstüne çık
	await place(Vector3(0, 3.1, -99.5), PI, "miknatis")
	await tap("ability")
	for i in 90:
		await get_tree().physics_frame
		if bip.magnet_state == 2:
			break
	var stuck: bool = bip.magnet_state == 2
	Input.action_press("move_forward")
	await tap("jump", 12)
	for i in 90:
		await get_tree().physics_frame
		if bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(5)
	check("b3: metal yüzden mavi platforma", stuck and absf(bip.global_position.y - 3.0) < 0.3 and bip.global_position.z < -106, str(bip.global_position))
	# Kaya ile alt iskeleye, Pervane ile son güverteye
	await place(Vector3(0, 4.5, -111.3), PI, "kaya")
	await step(4)
	await tap("ability")
	await step(60)
	check("b3: çatlaktan alt iskeleye", absf(bip.global_position.y + 1.0) < 0.3, str(bip.global_position))
	await place(Vector3(0, -0.9, -124.5), PI, "pervane")
	var ok2 := await jump_forward(110, 100, 5.0, 300, 45)
	check("b3: Pervane ile son güverte (6,5 m)", ok2 and absf(bip.global_position.y - 5.5) < 0.3, str(bip.global_position))



func _b4() -> void:
	var boss := level.find_child("PasliKaptan", true, false)
	await place(Vector3(0, 0.1, 15), PI)
	Input.action_press("move_forward")
	await step(40)
	Input.action_release("move_forward")
	check("b4: patron başladı", boss.phase == 1, "aşama %d" % boss.phase)
	await step(170)   # giriş kamerası bitsin
	# Aşama 1: sandık yığınından Pervane ile direğin tepesine
	await place(Vector3(9.0, 2.1, -8), PI / 2, "pervane")
	Input.action_press("jump")
	for i in 300:
		await get_tree().physics_frame
		if bip.global_position.y > 9.2 and bip.global_position.x < 11.0:
			Input.action_press("move_forward")
		if bip.global_position.x > 11.2:
			Input.action_release("move_forward")
		if boss.phase >= 2:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	check("b4: aşama 1, direğe Pervane ile", boss.phase >= 2, "aşama %d, %s" % [boss.phase, bip.global_position])
	if boss.phase < 2:
		boss._hit()
	await step(80)
	# Aşama 2: fıçıları Kaya ile ez
	for b in boss._barrels.duplicate():
		if not is_instance_valid(b):
			continue
		await place(b.global_position + Vector3(0, 3.0, 0), PI, "kaya")
		await tap("ability")
		await step(50)
	await step(20)
	check("b4: aşama 2, fıçılar ezildi", boss.phase >= 3, "aşama %d" % boss.phase)
	if boss.phase < 3:
		boss._hit()
	await step(30)
	# Aşama 3: Mıknatıs ile şapkaya, üstünde Kaya, çakıl
	await place(Vector3(0, 0.1, 5.5), PI, "miknatis")
	await tap("ability")
	for i in 90:
		await get_tree().physics_frame
		if bip.magnet_state == 2:
			break
	var stuck: bool = bip.magnet_state == 2
	await tap("jump", 3)
	for i in 90:
		await get_tree().physics_frame
		if bip.is_on_floor() and i > 5:
			break
	check("b4: Mıknatıs ile şapkanın üstüne", stuck and bip.global_position.y > 5.5, str(bip.global_position))
	GameState.set_ability("kaya")
	Input.action_press("jump")
	await step(6)
	await tap("ability")
	Input.action_release("jump")
	await step(80)
	check("b4: aşama 3, Kaya ile şapkaya çakıldı", boss.phase >= 4, "aşama %d, %s" % [boss.phase, bip.global_position])
	await step(120)
	var cells := 0
	for c in level.get_children():
		if c.get_script() and String(c.get_script().resource_path).ends_with("core_cell.gd"):
			cells += 1
	check("b4: Çekirdek Pil düştü", cells == 1)
