extends Node
## Bölüm 5 (bonus) testi: Oyuncak Kasabası'nın ana geçişleri ve gizli köşeleri.
## Çalıştırma: godot --headless --path . tests/ch5_test.tscn

const LAVA_TEST_Y := 0.2
var level: Node
var bip
var fails := 0


func _ready() -> void:
	await get_tree().process_frame
	for path in ["res://scenes/chapter5/e1_oyuncak_kasabasi.tscn", "res://scenes/chapter5/e2_yildiz_gozlemevi.tscn",
			"res://scenes/chapter5/e3_volkan_adasi.tscn", "res://scenes/chapter5/e4_sampiyon_yolu.tscn"]:
		await _load(path)
		await _common(path.get_file())
		match path.get_file():
			"e1_oyuncak_kasabasi.tscn":
				await _e1()
			"e2_yildiz_gozlemevi.tscn":
				await _e2()
			"e3_volkan_adasi.tscn":
				await _e3()
			"e4_sampiyon_yolu.tscn":
				await _e4()
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
	var screws := 0
	for c in level.find_children("Screw*", "", true, false):
		screws += 1
	check("%s: altın vida sayısı" % n, screws == (0 if n.begins_with("d3") else 1), str(screws))


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
		if bip.global_position.y < y_min - 8.0:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	return bip.is_on_floor() and bip.global_position.y > y_min


func tap(action: String, frames := 2) -> void:
	Input.action_press(action)
	await step(frames)
	Input.action_release(action)


## Balon: zıpla ve süzül; z_stop'u geçince ileri bırak (oyuncu da böyle yönlendirir).
func glide_to(z_stop: float, y_min: float) -> bool:
	Input.action_press("jump")
	Input.action_press("move_forward")
	for i in 360:
		await get_tree().physics_frame
		if bip.global_position.z < z_stop:
			Input.action_release("move_forward")
		if i > 10 and bip.is_on_floor():
			break
		if bip.global_position.y < y_min - 8.0:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	return bip.is_on_floor() and bip.global_position.y > y_min


## Pervane: önce yüksel, hedef yüksekliği geçince ileri git, z_stop'u geçince bırak.
func rise_to(y_target: float, z_stop: float) -> bool:
	Input.action_press("jump")
	for i in 300:
		await get_tree().physics_frame
		if bip.global_position.y > y_target + 0.8 and bip.global_position.z > z_stop:
			Input.action_press("move_forward")
		if bip.global_position.z < z_stop:
			Input.action_release("move_forward")
		if i > 10 and bip.is_on_floor():
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	return bip.is_on_floor() and bip.global_position.y > y_target


func magnet_pull() -> bool:
	await tap("ability")
	for i in 90:
		await get_tree().physics_frame
		if bip.magnet_state == 2:
			return true
	return false


func climb_up() -> void:
	await tap("jump", 3)
	for i in 90:
		await get_tree().physics_frame
		if bip.is_on_floor() and i > 5:
			break
	await step(5)



func _e1() -> void:
	# Hediye kulesi: Yay ile üç kutu
	await place(Vector3(0, 0.1, -6.2), PI, "yay")
	var ok := await jump_forward(60, 40, 3.5)
	check("e1: Yay ile 1. hediye kutusu", ok and absf(bip.global_position.y - 4.0) < 0.2, str(bip.global_position))
	await place(Vector3(0, 4.1, -10.0), PI, "yay")
	ok = await jump_forward(60, 40, 7.5)
	check("e1: Yay ile 2. kutu", ok and absf(bip.global_position.y - 8.0) < 0.2, str(bip.global_position))
	await place(Vector3(0, 8.1, -13.6), PI, "yay")
	ok = await jump_forward(60, 40, 11.5)
	check("e1: Yay ile 3. kutu", ok and absf(bip.global_position.y - 12.0) < 0.2, str(bip.global_position))
	# Gizli şeker kamışı: yeşil kutudan doğuya Yay ile
	await place(Vector3(1.2, 12.1, -16.2), PI / 2, "yay")
	ok = await jump_forward(60, 40, 15.0)
	check("e1: şeker kamışı sütununa (Altın Vida)", ok and absf(bip.global_position.y - 15.5) < 0.2, str(bip.global_position))
	# Tren: vagon rafın ucuna gelince bin, diğer rafa in
	var tr := level.find_child("Platform_1", true, false)
	await place(Vector3(0, 12.1, -29.3), PI, "")
	for i in 400:
		await get_tree().physics_frame
		if tr.global_position.z > -33.8:
			break
	Input.action_press("move_forward")
	for i in 600:
		await get_tree().physics_frame
		if bip.global_position.z < -46.5 and bip.is_on_floor():
			break
		if bip.global_position.y < 6.0:
			break
		if bip.is_on_floor() and bip.global_position.z < -30.0 and tr.global_position.z > -42.0 and bip.global_position.z < tr.global_position.z - 2.0:
			Input.action_release("move_forward")       # vagonun ön ucunda bekle
		elif tr.global_position.z < -42.5:
			Input.action_press("move_forward")
	Input.action_release("move_forward")
	await step(10)
	check("e1: trenle ikinci rafa", bip.global_position.z < -46.0 and absf(bip.global_position.y - 12.0) < 0.3, str(bip.global_position))
	# Balon ile kaleye
	await place(Vector3(0, 12.1, -55.6), PI, "balon")
	ok = await glide_to(-65.5, 8.5)
	check("e1: Balon ile kale avlusuna", ok and absf(bip.global_position.y - 9.0) < 0.3, str(bip.global_position))
	# Mıknatıs levhaları
	await place(Vector3(0, 9.1, -73.4), PI, "miknatis")
	for k in 3:
		await tap("ability")
		await step(40)
	await tap("jump", 3)
	await step(90)
	check("e1: Mıknatıs levhalarıyla kuleye", bip.global_position.y > 15.8, str(bip.global_position))
	# Gizli top havuzundan dönüş
	await place(Vector3(2.4, -2.0, 10.4), PI, "")
	Input.action_press("move_forward")
	for i in 240:
		await get_tree().physics_frame
		if i > 40 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(10)
	check("e1: top havuzundan trambolinle dönüş", bip.global_position.y > -0.3, str(bip.global_position))
	# Gizli raf (trenin altı) ve trambolinle rafa dönüş
	await place(Vector3(-4.6, 9.5, -36.4), 0.0, "")
	Input.action_press("move_forward")
	for i in 240:
		await get_tree().physics_frame
		if i > 40 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(10)
	check("e1: gizli raftan trambolinle dönüş", bip.global_position.y > 11.7, str(bip.global_position))
	# Pervane ile şapkaya (en sonda: çıkışa çok yakın iner, alan biter)
	await place(Vector3(0, 16.1, -84.6), PI, "pervane")
	ok = await jump_forward(110, 100, 22.0, 300, 40)
	check("e1: Pervane ile Fındıkkıran'ın şapkasına", ok and absf(bip.global_position.y - 22.5) < 0.2, str(bip.global_position))


func run_until(cond: Callable, max_frames: int) -> void:
	for i in max_frames:
		await get_tree().physics_frame
		if cond.call():
			return


func _e2() -> void:
	# Buz ile gölü yürüyerek geç, uzak kıyıya zıpla
	await place(Vector3(0, 0.1, -5.5), PI, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.z < -19.6, 300)
	await tap("jump", 25)
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 2.0, 90)
	Input.action_release("move_forward")
	await step(10)
	check("e2: Buz ile Yıldız Gölü", bip.is_on_floor() and absf(bip.global_position.y - 2.15) < 0.2, str(bip.global_position))
	# Gizli adacık
	await place(Vector3(0, 0.3, -15), PI / 2, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.x > 2.0, 120)
	await tap("jump", 12)
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 0.6, 90)
	Input.action_release("move_forward")
	await step(10)
	check("e2: göldeki gizli adacık", bip.global_position.y > 0.6 and bip.global_position.x > 2.8, str(bip.global_position))
	# Kaya ile cam zemini kır, tünelden geç, trambolinle C kıyısına
	await place(Vector3(0, 2.3, -33.5), PI, "kaya")
	await tap("jump", 3)
	await step(10)
	await tap("ability")
	await step(120)
	check("e2: Kaya cam zemini kırdı", bip.global_position.y < -3.0, str(bip.global_position))
	Input.action_press("move_forward")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 2.0 and bip.global_position.z < -52.0, 600)
	Input.action_release("move_forward")
	await step(10)
	check("e2: tünel ve trambolinle C kıyısına", bip.global_position.z < -52.0 and absf(bip.global_position.y - 2.15) < 0.3, str(bip.global_position))
	# Gizli oyuk (Altın Vida)
	await place(Vector3(0, -3.9, -44), PI / 2, "")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.x > 3.6, 120)
	Input.action_release("move_forward")
	await step(10)
	check("e2: tünelin gizli oyuğuna girildi", bip.global_position.x > 3.4, str(bip.global_position))
	# Kayan yıldız tablası: trambolinden doğuya
	await place(Vector3(5.0, 3.5, -59.5), PI / 2, "")
	Input.action_press("move_forward")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 8.0, 240)
	Input.action_release("move_forward")
	await step(10)
	check("e2: kayan yıldız tablasına", absf(bip.global_position.y - 9.0) < 0.3, str(bip.global_position))
	# Teleskop rüzgârı: Balon ile yüksel, kubbe terasına süzül (en sonda: çıkışa yakın)
	await place(Vector3(0, 12.0, -100.5), PI, "balon")
	Input.action_press("jump")
	var going := false
	for i in 900:
		await get_tree().physics_frame
		if i == 2:
			Input.action_release("jump")
		if i == 12:
			Input.action_press("jump")
		if not going and bip.global_position.y > 21.0:
			going = true
			Input.action_press("move_forward")
		if going and bip.global_position.z < -106.0:
			Input.action_release("move_forward")
			Input.action_release("jump")
		if going and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	Input.action_release("jump")
	await step(10)
	check("e2: teleskop rüzgârıyla kubbe terasına", absf(bip.global_position.y - 20.0) < 0.3, str(bip.global_position))


## Balonla rüzgârda yüksel, 'rise' üstünde 'dir' yönüne git, hedefin üstünde bırak.
func ride_wind(at: Vector3, dir: String, rise: float, target: Vector3) -> Vector3:
	await place(at, PI, "balon")
	var turn: float = level.cam.auto_turn_speed
	level.cam.auto_turn_speed = 0.0
	Input.action_press("jump")
	var going := false
	for i in 900:
		await get_tree().physics_frame
		if i == 2:
			Input.action_release("jump")
		if i == 12:
			Input.action_press("jump")
		if not going and bip.global_position.y > rise:
			going = true
			Input.action_press(dir)
		var d := Vector2(bip.global_position.x - target.x, bip.global_position.z - target.z)
		if going and d.length() < 1.0:
			Input.action_release(dir)
			Input.action_release("jump")
		if going and bip.is_on_floor():
			break
	Input.action_release(dir)
	Input.action_release("jump")
	await step(10)
	level.cam.auto_turn_speed = turn
	return bip.global_position


func _e3() -> void:
	# Buzsuz lava giren yanar (son kontrol noktasına döner)
	await place(Vector3(0, 0.1, -5.5), PI, "")
	var cp := level.find_child("Checkpoint_1", true, false)
	Input.action_press("move_forward")
	var burned := false
	for i in 240:
		await get_tree().physics_frame
		if bip.global_position.z > -2.0 and i > 60:
			burned = true
			break
	Input.action_release("move_forward")
	await step(30)
	check("e3: buzsuz lav yakar, geri döner", burned or bip.global_position.z > -6.0, str(bip.global_position))
	# Buz ile lav nehri
	await place(Vector3(0, 0.1, -5.5), PI, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.z < -24.5, 400)
	Input.action_release("move_forward")
	await step(10)
	check("e3: Buz ile lav nehri geçildi", bip.global_position.z < -24.0 and absf(bip.global_position.y) < 0.3, str(bip.global_position))
	# Gizli adacık
	await place(Vector3(0, LAVA_TEST_Y, -15), PI / 2, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.x > 2.2, 120)
	await tap("jump", 12)
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 0.3, 90)
	Input.action_release("move_forward")
	await step(10)
	check("e3: nehirdeki gizli adacık", bip.global_position.y > 0.3 and bip.global_position.x > 2.8, str(bip.global_position))
	# Bazalt basamakları: her taşın ucunda zıpla (oyuncu gibi)
	await place(Vector3(0, 0.1, -34.5), PI, "")
	Input.action_press("move_forward")
	var edges := [-35.4, -40.6, -45.1, -49.6]
	var ei := 0
	var held := 0
	for i in 400:
		await get_tree().physics_frame
		if held > 0:
			held -= 1
			if held == 0:
				Input.action_release("jump")
		if ei < edges.size() and bip.is_on_floor() and bip.global_position.z < edges[ei]:
			Input.action_press("jump")
			held = 14
			ei += 1
		if bip.global_position.z < -53.5 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	Input.action_release("jump")
	await step(10)
	check("e3: bazalt basamaklarından C'ye", bip.global_position.z < -53.0 and absf(bip.global_position.y) < 0.3, str(bip.global_position))
	# Gayzer: Balon ile D'ye
	var p := await ride_wind(Vector3(0, 2.5, -68.5), "move_forward", 9.5, Vector3(0, 0, -77))
	check("e3: gayzerle platoya", absf(p.y - 8.0) < 0.3, str(p))
	p = await ride_wind(Vector3(5.0, 2.5, -68.5), "move_right", 12.6, Vector3(9.6, 0, -68.5))
	check("e3: gizli gayzer çıkıntısı", absf(p.y - 12.0) < 0.3, str(p))
	# Magma zinciri
	await place(Vector3(0, 8.1, -84.3), PI, "miknatis")
	var reached := []
	for k in 5:
		var stuck := await magnet_pull()
		await climb_up()
		reached.append(snappedf(bip.global_position.z, 0.1))
		if bip.global_position.z < -111.5 and bip.is_on_floor():
			break
		if not stuck:
			break
	Input.action_press("move_forward"); await step(20); Input.action_release("move_forward"); await step(10)
	check("e3: magma zinciriyle E'ye", bip.global_position.z < -111.5 and bip.global_position.y > 7.8, str(reached))
	# Gizli niş (F'nin doğusu)
	await place(Vector3(3.5, 14.6, -126), PI / 2, "pervane")
	var ok := await jump_forward(110, 60, 15.5, 300, 30)
	check("e3: krater kenarındaki gizli niş", ok and absf(bip.global_position.y - 16.0) < 0.3, str(bip.global_position))
	# Pervane ile krater kenarına (en sonda: çıkış)
	await place(Vector3(0, 8.1, -119.6), PI, "pervane")
	ok = await jump_forward(110, 100, 14.0, 300, 40)
	check("e3: Pervane ile krater kenarına", ok and absf(bip.global_position.y - 14.5) < 0.2, str(bip.global_position))


func _e4() -> void:
	await place(Vector3(0, 0.1, -5.5), PI, "yay")
	var ok := await jump_forward(60, 40, 3.5)
	check("e4: Yay terası 1", ok and absf(bip.global_position.y - 4.0) < 0.2, str(bip.global_position))
	await place(Vector3(0, 4.1, -11.5), PI, "yay")
	ok = await jump_forward(60, 40, 7.5)
	check("e4: Yay terası 2", ok and absf(bip.global_position.y - 8.0) < 0.2, str(bip.global_position))
	await place(Vector3(0, 8.1, -17.6), PI, "balon")
	ok = await glide_to(-31.5, 4.5)
	check("e4: Balon ile P1", ok and absf(bip.global_position.y - 5.0) < 0.3, str(bip.global_position))
	# Mıknatıs zinciri
	await place(Vector3(0, 5.1, -38.2), PI, "miknatis")
	var reached := []
	for k in 5:
		var stuck := await magnet_pull()
		await climb_up()
		reached.append(snappedf(bip.global_position.z, 0.1))
		if bip.global_position.z < -65.5 and bip.is_on_floor():
			break
		if not stuck:
			break
	Input.action_press("move_forward"); await step(20); Input.action_release("move_forward"); await step(10)
	check("e4: Mıknatıs zinciriyle P2", bip.global_position.z < -65.5 and bip.global_position.y > 4.8, str(reached))
	# Kaya: cam zemin, tünel, trambolin
	await place(Vector3(0, 5.2, -77.0), PI, "kaya")
	await tap("jump", 3)
	await step(10)
	await tap("ability")
	await step(120)
	check("e4: Kaya cam zemini kırdı", bip.global_position.y < 0.0, str(bip.global_position))
	Input.action_press("move_forward")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 4.5 and bip.global_position.z < -95.5, 600)
	Input.action_release("move_forward")
	await step(10)
	check("e4: tünelden trambolinle C'ye", bip.global_position.z < -95.5 and absf(bip.global_position.y - 5.0) < 0.3, str(bip.global_position))
	# Buz ile havuz
	await place(Vector3(0, 5.1, -106.8), PI, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.z < -121.1, 300)
	await tap("jump", 25)
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 7.0, 90)
	Input.action_release("move_forward")
	await step(10)
	check("e4: Buz ile havuz", absf(bip.global_position.y - 7.15) < 0.2, str(bip.global_position))
	# Pervane
	await place(Vector3(0, 7.25, -133.0), PI, "pervane")
	ok = await jump_forward(110, 100, 13.0, 300, 40)
	check("e4: Pervane ile 6,5 m", ok and absf(bip.global_position.y - 13.65) < 0.2, str(bip.global_position))
	# Gizli Altın Vida adacığından trambolinle P1'e dönüş
	await place(Vector3(8.4, 2.5, -33.8), PI, "")
	var turn: float = level.cam.auto_turn_speed
	level.cam.auto_turn_speed = 0.0
	Input.action_press("move_left")
	for i in 240:
		await get_tree().physics_frame
		if i > 40 and bip.is_on_floor():
			break
	Input.action_release("move_left")
	level.cam.auto_turn_speed = turn
	await step(10)
	check("e4: vida adacığından trambolinle dönüş", bip.global_position.y > 4.8, str(bip.global_position))
	# Dev Yay ile kupaya (en sonda: çıkış)
	await place(Vector3(0, 15.5, -141.0), PI, "")
	Input.action_press("move_forward")
	for i in 300:
		await get_tree().physics_frame
		if i > 40 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(10)
	check("e4: Dev Yay ile kupa platformuna", absf(bip.global_position.y - 23.65) < 0.3, str(bip.global_position))
