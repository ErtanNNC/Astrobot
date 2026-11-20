extends Node
## Bölüm 4 testi: alanlar yükleniyor, Bip zeminde başlıyor, kontrol noktaları ve çıkışların altı dolu;
## her alanın ana geçişleri oynanabiliyor; Statik'in üç aşaması geçilebiliyor ve son Çekirdek Pil düşüyor.
## Çalıştırma: godot --headless --path . tests/ch4_test.tscn

var level: Node
var bip
var fails := 0


func _ready() -> void:
	await get_tree().process_frame
	for path in ["res://scenes/chapter4/d1_bulut_basamaklari.tscn", "res://scenes/chapter4/d2_kivilcim_kalesi.tscn",
			"res://scenes/chapter4/d3_patron.tscn"]:
		await _load(path)
		await _common(path.get_file())
		match path.get_file():
			"d1_bulut_basamaklari.tscn":
				await _d1()
			"d2_kivilcim_kalesi.tscn":
				await _d2()
			"d3_patron.tscn":
				await _d3()
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


# ---------- Bulut Basamakları ----------
func _d1() -> void:
	await place(Vector3(0, 0.1, -4.5), PI, "yay")
	var ok := await jump_forward(60, 40, 3.5)
	check("d1: Yay ile bulut kulesine (4 m)", ok and absf(bip.global_position.y - 4.0) < 0.2, str(bip.global_position))
	await place(Vector3(0, 4.1, -12.0), PI, "")
	Input.action_press("move_forward")
	var last_jump := -100
	for i in 260:
		await get_tree().physics_frame
		if bip.is_on_floor() and i - last_jump > 14:
			Input.action_press("jump")
			last_jump = i
		elif i - last_jump == 10:
			Input.action_release("jump")
		if bip.global_position.z < -28.0 and bip.is_on_floor():
			break
		if bip.global_position.y < -2:
			break
	Input.action_release("move_forward")
	Input.action_release("jump")
	await step(10)
	check("d1: kaybolan bulutlardan geçiş", bip.global_position.z < -27.0 and bip.global_position.y > 3.5, str(bip.global_position))
	await place(Vector3(0, 4.1, -34.3), PI, "balon")
	ok = await glide_to(-48.0, 0.5)
	check("d1: Balon ile 10 m süzülme", ok and bip.global_position.z < -45.0, str(bip.global_position))
	await place(Vector3(0, 1.1, -52.5), PI, "pervane")
	ok = await jump_forward(110, 100, 7.0, 300, 40)
	check("d1: Pervane ile 6,5 m yükseliş", ok and absf(bip.global_position.y - 7.5) < 0.2, str(bip.global_position))
	await place(Vector3(2.6, 7.6, -59.5), PI / 2, "pervane")
	ok = await jump_forward(110, 85, 10.5, 300, 50)
	check("d1: Altın Vida tablasına Pervane ile", ok and bip.global_position.y > 10.8, str(bip.global_position))
	# Gökkuşağı köprüsü: kemerin tepesindeki gizli sandığa Yay ile iki sıçrayış
	await place(Vector3(-1.2, 8.6, -80.5), -PI / 2, "yay")
	ok = await jump_forward(60, 40, 11.5)
	check("d1: kemere çıkış basamağına Yay ile", ok and absf(bip.global_position.y - 12.0) < 0.2, str(bip.global_position))
	await place(Vector3(-6.3, 12.1, -80.0), PI, "yay")
	ok = await jump_forward(60, 40, 16.0)
	check("d1: gökkuşağı kemerinin tepesine", ok and absf(bip.global_position.y - 16.5) < 0.2, str(bip.global_position))
	# Balon merdiveni: trambolinlerle yukarı, bitiş bulutuna
	await place(Vector3(3.0, 10.0, -107), PI, "")
	var top := 0.0
	for i in 120:
		await get_tree().physics_frame
		top = maxf(top, bip.global_position.y)
	check("d1: trambolin bulutu sıçratır", top > 13.0, "tepe %.1f" % top)
	# Gizli alt bulut: trambolinle başlangıca dönüş
	await place(Vector3(1.6, -4.5, 12.4), PI, "")
	Input.action_press("move_forward")
	for i in 240:
		await get_tree().physics_frame
		if i > 40 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(10)
	check("d1: gizli alt buluttan başlangıca dönüş", bip.global_position.y > -0.3 and bip.global_position.z < 8.5, str(bip.global_position))
	await place(Vector3(0, 7.6, -61.5), PI, "")
	ok = await jump_forward(30, 40, 7.0)
	check("d1: varış bulutuna", ok and bip.global_position.z < -65.0, str(bip.global_position))


# ---------- Kıvılcım Kalesi ----------
func _d2() -> void:
	# Metal sur: Mıknatısla tutamağa yapış, üstüne tırman
	await place(Vector3(0, 0.1, -4.5), PI, "miknatis")
	var stuck := await magnet_pull()
	await climb_up()
	check("d2: Mıknatıs ile sura tırmanış", stuck and bip.global_position.y > 5.8, "yapıştı %s, %s" % [stuck, bip.global_position])
	# Ağır buton → kalıcı kapı
	var gate1: Node3D = level.find_child("Kapi1", true, false)
	var y0 := gate1.global_position.y
	await place(Vector3(-5.5, 2.3, -27), PI, "")
	await step(30)
	check("d2: Kayasız buton açmaz", absf(gate1.global_position.y - y0) < 0.05)
	await place(Vector3(-5.5, 2.3, -27), PI, "kaya")
	await step(60)
	check("d2: Kaya ile kapı açıldı", gate1.global_position.y < y0 - 3.0, str(gate1.global_position))
	# Buz: Hurda Goblin'i dondur, buz kütlesinden çıkıntıya
	var goblin: Node3D = null
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.kind == "hurdaci":
			goblin = e
			break
	goblin.global_position = Vector3(0, 2.1, -45.0)
	await step(5)
	await place(Vector3(0, 2.1, -42.6), PI, "buz")
	await tap("ability")
	await step(10)
	check("d2: Goblin dondu", goblin._frozen > 0.0)
	await place(goblin.global_position + Vector3(0, 1.6, 0), PI, "buz")
	ok_ledge = await jump_forward(40, 40, 5.0)
	check("d2: buz kütlesinden çıkıntıya (3,2 m)", ok_ledge and absf(bip.global_position.y - 5.2) < 0.2, str(bip.global_position))
	# Zamanlı kapı
	var gate2: Node3D = level.find_child("Kapi2", true, false)
	var y2 := gate2.global_position.y
	await place(Vector3(0, 5.4, -50), PI, "kaya")
	await step(50)
	var opened := gate2.global_position.y < y2 - 3.0
	await place(Vector3(-5.5, 5.4, -47), PI, "")
	await step(420)
	check("d2: zamanlı kapı açılır, sonra kapanır", opened and absf(gate2.global_position.y - y2) < 0.1, "%s %s" % [opened, gate2.global_position])
	# Final: altı yetenek
	await place(Vector3(0, 5.3, -56.5), PI, "yay")
	var ok := await jump_forward(60, 40, 9.0)
	check("d2 final 1: Yay", ok and absf(bip.global_position.y - 9.5) < 0.2, str(bip.global_position))
	await place(Vector3(0, 9.6, -62.0), PI, "balon")
	ok = await glide_to(-73.5, 6.5)
	check("d2 final 2: Balon", ok and absf(bip.global_position.y - 7.0) < 0.2 and bip.global_position.z < -71.5, str(bip.global_position))
	await place(Vector3(0, 7.1, -75.0), PI, "pervane")
	ok = await jump_forward(110, 95, 12.5, 300, 45)
	check("d2 final 3: Pervane", ok and absf(bip.global_position.y - 13.0) < 0.2, str(bip.global_position))
	await place(Vector3(0, 13.1, -81.0), PI, "miknatis")
	stuck = await magnet_pull()
	await climb_up()
	var on_block: bool = bip.global_position.y > 12.8 and bip.global_position.z < -86.0
	ok = await jump_forward(30, 40, 12.5)
	check("d2 final 4: Mıknatıs", stuck and on_block and ok and bip.global_position.z < -92.0, "%s %s %s" % [stuck, on_block, bip.global_position])
	await place(Vector3(0, 16.0, -96.5), PI, "kaya")
	await step(2)
	await tap("ability")
	await step(60)
	check("d2 final 5: Kaya ile alt odaya", absf(bip.global_position.y - 9.0) < 0.3, str(bip.global_position))
	await place(Vector3(0, 9.1, -105.0), PI, "buz")
	Input.action_press("move_forward")
	for i in 240:
		await get_tree().physics_frame
		if bip.global_position.z < -114.8 and bip.is_on_floor():
			Input.action_press("jump")
		if bip.global_position.y > 11.0 and bip.is_on_floor():
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	check("d2 final 6: Buz ile havuzdan varışa", bip.global_position.y > 11.0 and bip.global_position.z < -117.0, str(bip.global_position))
	await place(Vector3(7.0, 2.1, -38), PI / 2, "miknatis")
	stuck = await magnet_pull()
	await climb_up()
	Input.action_press("move_forward")
	await step(20)
	Input.action_release("move_forward")
	check("d2: Altın Vida kulesine Mıknatıs ile", stuck and bip.global_position.y > 8.8, str(bip.global_position))


var ok_ledge := false


# ---------- Patron: Statik ----------
func _d3() -> void:
	var boss := level.find_child("Statik", true, false)
	await place(Vector3(0, 0.1, 19), PI)
	Input.action_press("move_forward")
	await step(40)
	Input.action_release("move_forward")
	check("d3: patron başladı", boss.phase == 1, "aşama %d" % boss.phase)
	await step(170)   # giriş kamerası bitsin
	# Aşama 1: paratonerleri Kaya ile çak
	for r in get_tree().get_nodes_in_group("boss_rod").duplicate():
		if not is_instance_valid(r):
			continue
		await place(r.global_position + Vector3(0, 3.0, 0), PI, "kaya")
		await tap("ability")
		await step(50)
	await step(20)
	check("d3: aşama 1, paratonerler çakıldı", boss.phase >= 2, "aşama %d" % boss.phase)
	if boss.phase < 2:
		boss._hit()
	await step(60)
	# Aşama 2: Pervane ile basamak 1 (5 m), basamak 2 (11 m), Balon ile şalter bulutuna
	await place(Vector3(9.5, 0.1, 6.6), PI, "pervane")
	var ok := await rise_to(4.5, 3.6)
	check("d3: aşama 2, Pervane ile 5 m basamağa", ok and absf(bip.global_position.y - 5.0) < 0.2, str(bip.global_position))
	await place(Vector3(8.5, 5.1, 1.8), PI, "pervane")
	ok = await jump_forward(110, 100, 10.5, 300, 45)
	check("d3: aşama 2, Pervane ile 11 m basamağa", ok and absf(bip.global_position.y - 11.0) < 0.2, str(bip.global_position))
	await place(Vector3(6.2, 11.1, -5.0), -PI / 2, "balon")
	Input.action_press("jump")
	Input.action_press("move_forward")
	for i in 300:
		await get_tree().physics_frame
		if bip.global_position.x < -2.0:
			Input.action_release("move_forward")
		if boss.phase >= 3 or bip.global_position.y < 2.0:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	check("d3: aşama 2, Balon ile şaltere", boss.phase >= 3, "aşama %d, %s" % [boss.phase, bip.global_position])
	if boss.phase < 3:
		boss._hit()
	await step(120)   # Statik alçalsın
	# Aşama 3: Mıknatıs ile taca, Yetenek = enerji ver
	await place(Vector3(0, 0.1, 5.5), PI, "miknatis")
	var stuck := await magnet_pull()
	await climb_up()
	var top: Vector3 = boss.crown_top()
	var on_crown: bool = absf(bip.global_position.y - top.y) < 0.6
	check("d3: aşama 3, Mıknatıs ile tacın üstüne", stuck and on_crown, "%s %s taç %s" % [stuck, bip.global_position, top])
	await tap("ability")
	await step(150)
	check("d3: aşama 3, enerji verildi, Statik sakinleşti", boss.phase >= 4, "aşama %d" % boss.phase)
	await step(60)
	var cells := 0
	for c in level.get_children():
		if c.get_script() and String(c.get_script().resource_path).ends_with("core_cell.gd"):
			cells += 1
	check("d3: son Çekirdek Pil düştü", cells == 1)
