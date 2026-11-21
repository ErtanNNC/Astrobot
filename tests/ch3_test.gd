extends Node
## Bölüm 3 testi: her alan yükleniyor, Bip zeminde başlıyor, kontrol noktaları ve çıkışın altı dolu;
## her alanın ana mekaniği gerçekten oynanabiliyor; Kardan Dev'in üç aşaması geçilebiliyor.
## Çalıştırma: godot --headless --path . tests/ch3_test.tscn

var level: Node
var bip
var fails := 0


func _ready() -> void:
	GameState.data = GameState.new_data()
	await _area1()
	await _area2()
	await _area3()
	await _boss()
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)


func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1


func step(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func load_area(path: String) -> void:
	if level:
		level.queue_free()
		await get_tree().process_frame
	GameState.data = GameState.new_data()
	level = load(path).instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = level
	bip = level.get_node("GameRig/Bip")
	await step(20)
	check("%s: başlangıç zeminde" % level.area_id, bip.is_on_floor(), str(bip.global_position))
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	var nodes := get_tree().get_nodes_in_group("checkpoint")
	for n in level.find_children("*", "Area3D", true, false):
		if n.get_script() and String(n.get_script().resource_path).ends_with("area_exit.gd"):
			nodes.append(n)
	for n in nodes:
		var p: Vector3 = n.global_position
		var q := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 0.8, p + Vector3.DOWN * 1.0)
		q.exclude = [bip.get_rid()]
		var hit := space.intersect_ray(q)
		check("%s: %s altı dolu" % [level.area_id, n.name], not hit.is_empty(), str(p))


func place(p: Vector3, yaw := PI, ability := "") -> void:
	GameState.set_ability(ability)
	bip.reset_state(p)
	bip.facing_yaw = yaw
	bip.rotation.y = yaw
	bip.invuln = 30.0
	level.cam._look_time = 0.0
	level.cam.snap_to_target()
	await step(8)


func tap(action: String, frames := 2) -> void:
	Input.action_press(action)
	await step(frames)
	Input.action_release(action)


func run_until(cond: Callable, max_frames: int) -> void:
	for i in max_frames:
		await get_tree().physics_frame
		if cond.call():
			return


# ---------------------------------------------------------------- Buz Mağarası
func _area1() -> void:
	await load_area("res://scenes/chapter3/c1_buz_magarasi.tscn")
	# Buz ile havuzu yürüyerek geç
	await place(Vector3(0, 0.1, -8), PI, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.z < -18.6, 240)
	await tap("jump", 25)
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 2.0, 90)
	Input.action_release("move_forward")
	await step(10)
	check("Mağara: Buz ile havuz 1 geçildi", bip.is_on_floor() and absf(bip.global_position.y - 2.15) < 0.2, str(bip.global_position))
	# Buz olmadan uzak kıyıya yüzerek çıkılamaz
	await place(Vector3(-4, -0.2, -18.5), PI, "")
	await step(40)
	Input.action_press("move_forward")
	Input.action_press("jump")
	await step(60)
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(30)
	check("Mağara: yüzerek kıyıya çıkılamaz", bip.global_position.y < 1.0, str(bip.global_position))
	# Düşmanı dondur, buz kütlesinden 3,2 m çıkıntıya çık
	var e := level.find_child("Enemy_1", true, false)
	await place(e.global_position + Vector3(0, 0.1, 2.2), PI, "buz")
	await tap("ability")
	await step(5)
	check("Mağara: düşman dondu", e._frozen > 0.0)
	await place(e.global_position + Vector3(0, 1.8, 0), PI, "buz")
	await step(20)
	var y_block: float = bip.global_position.y
	Input.action_press("jump")
	Input.action_press("move_forward")
	await step(30)
	Input.action_release("jump")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 5.0, 90)
	Input.action_release("move_forward")
	await step(15)
	check("Mağara: buz kütlesinden çıkıntıya çıkıldı", absf(bip.global_position.y - 5.35) < 0.2, "kütle %.2f → %s" % [y_block, bip.global_position])
	# Gizli kristal adacık: havuz 2'de Buz ile yürü, sağa zıpla
	await place(Vector3(0, 5.6, -51), PI / 2, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.x > 1.6, 120)
	await tap("jump", 12)
	await run_until(func(): return bip.global_position.x > 3.6, 60)
	Input.action_release("move_forward")
	await run_until(func(): return bip.is_on_floor(), 90)
	await step(10)
	check("Mağara: gizli kristal adacık", bip.global_position.y > 6.0 and bip.global_position.x > 2.8, str(bip.global_position))


# ---------------------------------------------------------------- Donmuş Göl
func _area2() -> void:
	await load_area("res://scenes/chapter3/c2_donmus_gol.tscn")
	# Kaya ile çatlak buzu kır, tünelden geç, trambolinle çık
	await place(Vector3(0, 2.25, -36.5), PI, "kaya")
	await tap("jump", 3)
	await step(10)
	await tap("ability")
	await step(120)
	check("Göl: Kaya buzu kırıp dibe battı", bip.global_position.y < -3.0, str(bip.global_position))
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.y > 2.0 and bip.is_on_floor() and bip.global_position.z < -50.0, 600)
	Input.action_release("move_forward")
	await step(20)
	check("Göl: tünel ve trambolinle duvarın ötesine çıkıldı", bip.global_position.z < -50.0 and bip.global_position.y > 1.5, str(bip.global_position))
	# Balon ile kaybolan buz kütleleri üzerinden süzül
	await place(Vector3(0, 2.25, -61.5), PI, "balon")
	Input.action_press("move_forward")
	Input.action_press("jump")
	for i in 400:
		await get_tree().physics_frame
		if bip.global_position.z < -78.2 and bip.is_on_floor() and bip.global_position.y > 2.0:
			break
		if bip.is_on_floor() and i % 10 == 0:   # platformda yeniden zıpla
			Input.action_release("jump")
			await get_tree().physics_frame
			Input.action_press("jump")
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	check("Göl: Balon ile göl 2 geçildi", bip.global_position.z < -76.0 and bip.global_position.y > 2.0, str(bip.global_position))
	# Pervane ile adacıktan yüksek kıyıya
	await place(Vector3(0, 2.25, -109), PI, "pervane")
	Input.action_press("move_forward")
	Input.action_press("jump")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 5.5, 240)
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	check("Göl: Pervane ile kıyıya (6 m) çıkıldı", absf(bip.global_position.y - 6.0) < 0.2, str(bip.global_position))
	# Gizli buz sütunu: Balonla rüzgârda yüksel, doğuya süzül
	await place(Vector3(6, 3.0, -73), PI, "balon")
	var turn: float = level.cam.auto_turn_speed
	level.cam.auto_turn_speed = 0.0
	Input.action_press("jump")
	var going := false
	for i in 500:
		await get_tree().physics_frame
		if i == 2:
			Input.action_release("jump")
		if i == 6:
			Input.action_press("jump")
		if not going and bip.global_position.y > 6.6:
			going = true
			Input.action_press("move_right")
		if going and bip.global_position.x > 11.0:
			Input.action_release("move_right")
			Input.action_release("jump")
		if going and bip.is_on_floor():
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	await step(10)
	level.cam.auto_turn_speed = turn
	check("Göl: gizli buz sütununa rüzgâr + Balon", absf(bip.global_position.y - 6.5) < 0.3, str(bip.global_position))


# ---------------------------------------------------------------- Kar Zirvesi
func _area3() -> void:
	await load_area("res://scenes/chapter3/c3_zirve.tscn")
	# Yay ile tepeler
	await place(Vector3(0, 0.1, -6.0), PI, "yay")
	Input.action_press("move_forward")
	Input.action_press("jump")
	await step(28)
	Input.action_release("move_forward")
	await run_until(func(): return bip.is_on_floor(), 120)
	Input.action_release("jump")
	await step(5)
	check("Zirve: Yay ile tepe 1", absf(bip.global_position.y - 4.5) < 0.2, str(bip.global_position))
	# Mıknatıs ile teleferik direkleri
	await place(Vector3(0, 13.6, -27.2), PI, "miknatis")
	var heights := []
	await tap("ability")
	for k in 4:
		await run_until(func(): return bip.magnet_state == 2, 90)
		heights.append(snappedf(bip.global_position.z, 0.1))
		if k == 3:
			Input.action_press("move_forward")
		await tap("jump", 3)
		await step(8)
		if k < 3:
			await tap("ability")
	await run_until(func(): return bip.is_on_floor(), 120)
	Input.action_release("move_forward")
	await step(10)
	check("Zirve: Mıknatıs ile direklerden inişe", bip.global_position.z < -51.5 and absf(bip.global_position.y - 16.0) < 0.3, "direkler %s → %s" % [heights, bip.global_position])
	# Parkur: Balon boşluğu
	await place(Vector3(0, 15.6, -101.0), PI, "balon")
	Input.action_press("move_forward")
	Input.action_press("jump")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.z < -113.0, 300)
	Input.action_release("jump")
	await step(6)
	Input.action_release("move_forward")
	check("Zirve: Balon ile 12 m boşluk", absf(bip.global_position.y - 13.0) < 0.2 and bip.global_position.z < -113.0, str(bip.global_position))
	# Parkur: Kaya ile çatlak buz → alt geçit
	await place(Vector3(0, 11.6, -139.5), PI, "kaya")
	await tap("jump", 3)
	await step(10)
	await tap("ability")
	await step(80)
	check("Zirve: Kaya ile alt geçide inildi", absf(bip.global_position.y - 7.0) < 0.2, str(bip.global_position))
	# Parkur: Buz ile havuz
	await place(Vector3(0, 7.1, -148.5), PI, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.z < -159.0, 200)
	await tap("jump", 20)
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 9.0, 90)
	Input.action_release("move_forward")
	check("Zirve: Buz ile havuz geçildi", absf(bip.global_position.y - 9.15) < 0.2, str(bip.global_position))
	# Parkur: Pervane ile zirve
	await place(Vector3(0, 9.25, -170.5), PI, "pervane")
	Input.action_press("move_forward")
	Input.action_press("jump")
	await run_until(func(): return bip.is_on_floor() and bip.global_position.y > 14.0, 240)
	Input.action_release("jump")
	Input.action_release("move_forward")
	check("Zirve: Pervane ile zirveye çıkıldı", absf(bip.global_position.y - 15.0) < 0.2, str(bip.global_position))


# ---------------------------------------------------------------- Kardan Dev
func _boss() -> void:
	await load_area("res://scenes/chapter3/c4_patron.tscn")
	var boss := level.find_child("KardanDev", true, false)
	await place(Vector3(-1, 0.1, 14), PI, "")
	Input.action_press("move_forward")
	await step(30)
	Input.action_release("move_forward")
	check("Dev: dövüş başladı", boss.phase == 1, "aşama %d" % boss.phase)
	# Aşama 1: Zıpzıp'ı yumruğun yanında dondur, kütleden yumruğa çık
	var e: Node3D = null
	for n in get_tree().get_nodes_in_group("enemy"):
		if not n._dead:
			e = n
			break
	for n in get_tree().get_nodes_in_group("enemy"):
		if n != e and not n._dead:
			n.global_position = Vector3(-8, 0.1, 20)
			n._hop_timer = 99.0
	e.global_position = Vector3(4.6, 0.05, 2.3)
	e.velocity = Vector3.ZERO
	e._hop_timer = 99.0
	await place(Vector3(4.6, 0.1, 4.6), PI, "buz")
	await tap("ability")
	await step(5)
	check("Dev: Zıpzıp dondu", e._frozen > 0.0)
	await place(e.global_position + Vector3(0, 1.8, 0), PI, "buz")
	await step(20)
	Input.action_press("jump")
	Input.action_press("move_forward")
	await step(16)
	Input.action_release("move_forward")
	await run_until(func(): return boss.phase >= 2, 90)
	Input.action_release("jump")
	check("Dev aşama 1: buz kütlesinden yumruğa çıkıldı", boss.phase == 2, "aşama %d, bip %s" % [boss.phase, bip.global_position])
	if boss.phase < 2:
		boss._hit()
	await step(40)
	# Aşama 2: Buz ile göl üstünde şalter adasına
	await place(Vector3(7.5, 0.1, 0), PI / 2, "buz")
	Input.action_press("move_forward")
	await run_until(func(): return bip.global_position.x > 20.8, 240)
	await tap("jump", 20)
	await run_until(func(): return boss.phase >= 3, 120)
	Input.action_release("move_forward")
	check("Dev aşama 2: Buz ile şaltere ulaşıldı", boss.phase == 3, "aşama %d, bip %s" % [boss.phase, bip.global_position])
	if boss.phase < 3:
		boss._hit()
	await step(30)
	# Aşama 3: yumruktan Pervane ile tüneğe
	var perch := Vector3(0, 10.2, -3.0)
	var start := Vector3(3.5, 5.1, -4.0)
	var d := perch - start
	await place(start, atan2(d.x, d.z), "pervane")
	Input.action_press("jump")
	var ys := []
	for i in 150:
		await get_tree().physics_frame
		if i % 15 == 0:
			ys.append(snappedf(bip.global_position.y, 0.1))
		if bip.global_position.y > 10.6:
			break
	Input.action_press("move_forward")
	await run_until(func(): return Vector2(bip.global_position.x - perch.x, bip.global_position.z - perch.z).length() < 0.6 or (bip.is_on_floor() and bip.global_position.y > 9.5), 200)
	Input.action_release("move_forward")
	await run_until(func(): return bip.is_on_floor(), 120)
	Input.action_release("jump")
	await step(5)
	check("Dev aşama 3: Pervane ile tüneğe çıkıldı", absf(bip.global_position.y - 10.2) < 0.25, str(bip.global_position))
	# Tünekte Kaya kopyala, başa çakıl
	bip.global_position = Vector3(0, 10.3, -2.4)
	await step(5)
	await tap("ability")
	await step(5)
	check("Dev: tünekte Kaya kopyalandı", GameState.ability == "kaya", GameState.ability)
	bip.facing_yaw = 0.0
	bip.rotation.y = 0.0
	level.cam.snap_to_target()
	Input.action_press("move_forward")
	await tap("jump", 3)
	await step(14)
	Input.action_release("move_forward")
	await tap("ability")
	await step(40)
	check("Dev aşama 3: başa çakılınca yenildi", boss.phase >= 4, "aşama %d, bip %s" % [boss.phase, bip.global_position])
	await step(150)
	var cells := 0
	for c in level.get_children():
		if c.get_script() and String(c.get_script().resource_path).ends_with("core_cell.gd"):
			cells += 1
	check("Dev: Çekirdek Pil düştü", cells == 1)
