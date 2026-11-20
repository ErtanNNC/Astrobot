extends Node
## Bölüm 1 alanlarının testi: başlangıç, kontrol noktaları ve çıkışın altında zemin;
## her alanın ana mekaniği (Yay basamağı, süzülüş + rüzgâr, mıknatıs zinciri,
## ağır buton + kapı, yere çakılma, suda batma).
## Çalıştırma: godot --headless --path . tests/ch1_areas_test.tscn

const AREAS := [
	"res://scenes/chapter1/a1_yay_bahcesi.tscn",
	"res://scenes/chapter1/a2_balon_kanyonu.tscn",
	"res://scenes/chapter1/a3_miknatis_fabrikasi.tscn",
	"res://scenes/chapter1/a4_kaya_ocagi.tscn",
]

var level: Node
var bip
var fails := 0


func _ready() -> void:
	GameState.data = GameState.new_data()
	await get_tree().process_frame
	for path in AREAS:
		await _load(path)
		print("== ", path.get_file())
		await _common()
		match path.get_file():
			"a1_yay_bahcesi.tscn": await _test_yay()
			"a2_balon_kanyonu.tscn": await _test_balon()
			"a3_miknatis_fabrikasi.tscn": await _test_miknatis()
			"a4_kaya_ocagi.tscn": await _test_kaya()
		level.queue_free()
		await get_tree().process_frame
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)


func _load(path: String) -> void:
	GameState.data = GameState.new_data()
	GameState.ability = ""
	level = load(path).instantiate()
	get_tree().root.add_child(level)
	await get_tree().process_frame
	await get_tree().process_frame
	bip = level.get_node("GameRig/Bip")


func step(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1


func place(p: Vector3, yaw := PI, ability := "") -> void:
	GameState.set_ability(ability)
	bip.reset_state(p)
	bip.facing_yaw = yaw
	bip.rotation.y = yaw
	bip.invuln = 0.0
	level.cam.snap_to_target()
	await step(12)


func floor_under(p: Vector3) -> bool:
	var space: PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 1.0, p + Vector3.DOWN * 2.0)
	return not space.intersect_ray(q).is_empty()


func _common() -> void:
	await step(20)
	check("Başlangıçta zeminde", bip.is_on_floor(), str(bip.global_position))
	for cp in get_tree().get_nodes_in_group("checkpoint"):
		check("Kontrol noktası zeminde: " + cp.checkpoint_id, floor_under(cp.global_position))
	var ex := level.find_child("Exit_1", true, false)
	check("Çıkış var ve zeminde", ex != null and floor_under(ex.global_position))
	var screw := level.find_child("Screw_1", true, false)
	check("Altın vida var", screw != null)
	var n := get_tree().get_nodes_in_group("battery").size()
	check("Pil sayısı 20+", n >= 20, str(n))


## Zıpla + ileri; inene kadar bekle. Dönüş: iniş konumu.
func jump_forward(frames_hold := 30, max_frames := 240, glide := false) -> Vector3:
	Input.action_press("move_forward")
	Input.action_press("jump")
	var landed := false
	for i in max_frames:
		await get_tree().physics_frame
		if not glide and i == frames_hold:
			Input.action_release("jump")
		if i > 10 and bip.is_on_floor():
			landed = true
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(10)
	return bip.global_position


func _test_yay() -> void:
	# Yay ile 4 m'lik teraslar
	await place(Vector3(0, 0.1, -6.5), PI, "yay")
	var p := await jump_forward()
	check("Yay ile 4 m'lik terasa (T1) çıkış", absf(p.y - 4.0) < 0.2, str(p))
	await place(Vector3(-4, 4.1, -14.5), PI, "yay")
	p = await jump_forward()
	check("Yay ile ikinci terasa (T2) çıkış", absf(p.y - 8.0) < 0.2, str(p))
	# Basamak taşına normal zıplama
	await place(Vector3(0, 8.1, -20.0), PI, "")
	Input.action_press("move_forward")
	await step(12)   # koşarak gel
	p = await jump_forward(30, 240, false)
	check("T2'den ilk basamak taşına zıplama", absf(p.y - 8.0) < 0.2 and p.z < -25.5, str(p))
	# Gizli sütun: normal zıplama + kenara tutunma
	await place(Vector3(2.0, 4.1, -12.5), PI, "")
	var turn: float = level.cam.auto_turn_speed
	level.cam.auto_turn_speed = 0.0   # oyuncu yönünü tutar: kamera dönmesin
	Input.action_press("move_right")
	await step(10)
	Input.action_press("jump")
	var hung := false
	for i in 150:
		await get_tree().physics_frame
		hung = hung or bip.ledge_hanging
		if i == 25:
			Input.action_release("jump")
		if hung and bip.is_on_floor() and bip.global_position.y > 7.0:
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	await step(10)
	level.cam.auto_turn_speed = turn
	check("Gizli sütuna kenara tutunarak çıkış", hung and bip.global_position.y > 7.0, str(bip.global_position))
	# Gizli mağaradan trambolinle geri dönüş
	await place(Vector3(2.0, -3.0, 10.4), PI, "")
	Input.action_press("move_forward")
	for i in 200:
		await get_tree().physics_frame
		if i > 30 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(10)
	check("Mağaradan trambolinle başlangıç adasına dönüş", bip.global_position.y > -1.5, str(bip.global_position))
	# Trambolinli hareketli platform: üstüne düşünce yükseğe sıçrar
	var pa := level.find_child("Platform_3", true, false)
	await place(pa.global_position + Vector3(0, 2.0, 0), PI, "")
	var base_y: float = pa.global_position.y
	var peak: float = bip.global_position.y
	for i in 120:
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
	check("Hareketli trambolin sıçratır", peak > base_y + 4.5, "tepe %.1f" % peak)
	# Dev Yay: bitiş kulesine fırlatır
	await place(Vector3(-1, 32.0, -146.5), PI, "")
	Input.action_press("move_forward")
	var top := 0.0
	for i in 300:
		await get_tree().physics_frame
		top = maxf(top, bip.global_position.y)
		if i > 40 and bip.is_on_floor():
			break
	Input.action_release("move_forward")
	await step(10)
	check("Dev Yay bitiş kulesine çıkarır", absf(bip.global_position.y - 40.0) < 0.3, "%s tepe %.1f" % [bip.global_position, top])


func _test_balon() -> void:
	await place(Vector3(0, 20.1, 0), PI, "balon")
	var p := await jump_forward(30, 300, true)
	check("Başlangıçtan ilk mesaya süzülüş", p.z < -7.5 and absf(p.y - 19.0) < 0.3, str(p))
	await place(Vector3(5, 17.1, -28.3), PI, "balon")
	p = await jump_forward(30, 400, true)
	check("Balonla 12 m'lik boşluk", p.z < -40.8 and absf(p.y - 14.0) < 0.3, str(p))
	await place(Vector3(-3, 18.6, -86.3), PI, "balon")
	p = await jump_forward(30, 500, true)
	check("Rüzgârla yukarıdaki mesaya", p.z < -103.8 and absf(p.y - 23.0) < 0.3, str(p))
	await place(Vector3(-3, 18.6, -86.3), PI, "")
	p = await jump_forward(30, 300)
	check("Balonsuz rüzgâr kanyonu geçilemez", p.y < 10.0 or p.z > -89.0, str(p))
	# Gizli köşeler: rüzgârla yüksel, yana süzül
	p = await _ride_wind(Vector3(-9.3, 14.0, 1), "move_right", 22.0, Vector3(-4, 0, 1))
	check("Kayıp Balkon'dan rüzgârla başlangıca dönüş", absf(p.y - 20.0) < 0.3 and p.x > -7.2, str(p))
	p = await _ride_wind(Vector3(14, 8.0, -46), "move_left", 19.0, Vector3(7, 0, -46))
	check("Altın Vida çıkıntısından rüzgârla M3'e dönüş", absf(p.y - 14.0) < 0.3 and p.x < 10.2, str(p))
	p = await _ride_wind(Vector3(-3, 23.0, -98.5), "move_right", 24.5, Vector3(8, 0, -98.5))
	check("Rüzgârın tepesinden Kartal Yuvası'na", absf(p.y - 23.5) < 0.3, str(p))
	# Büyük Hortum: rüzgârda yüksel, Gün Batımı Kayası'na süzül
	p = await _ride_wind(Vector3(-3, 24.0, -148), "move_forward", 42.0, Vector3(-3, 0, -157))
	check("Büyük Hortum bitiş kayasına çıkarır", absf(p.y - 40.0) < 0.3, str(p))


## Balonla rüzgârın içinde süzül; 'rise' yüksekliğine çıkınca 'dir' yönüne git, hedefin üstüne
## gelince (oyuncu gibi) zıplamayı bırakıp in.
func _ride_wind(at: Vector3, dir: String, rise: float, target: Vector3) -> Vector3:
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


func _test_miknatis() -> void:
	await place(Vector3(0, 0.1, -8.0), PI, "miknatis")
	Input.action_press("ability"); await step(2); Input.action_release("ability")
	await step(40)
	check("Mıknatısla tutamağa yapıştı", bip.magnet_state == 2, "durum %d" % bip.magnet_state)
	Input.action_press("jump"); await step(3); Input.action_release("jump")
	await step(80)
	check("Tutamağın üstüne tırmandı", bip.is_on_floor() and bip.global_position.y > 4.9, str(bip.global_position))
	# Zincir: B1 üstünden B2'ye
	await place(Vector3(0, 5.1, -28.5), PI, "miknatis")
	Input.action_press("ability"); await step(2); Input.action_release("ability")
	await step(50)
	check("Zincir: sıradaki bloğa yapıştı", bip.magnet_state == 2 and bip.global_position.z < -33.5, str(bip.global_position))
	Input.action_press("jump"); await step(3); Input.action_release("jump")
	await step(80)
	check("Zincir: bloğun üstüne çıktı", bip.is_on_floor() and absf(bip.global_position.z + 36.0) < 1.2 and bip.global_position.y > 4.9, str(bip.global_position))
	# Dikey levhalar
	await place(Vector3(0, 5.1, -72.4), PI, "miknatis")
	for i in 3:
		Input.action_press("ability"); await step(2); Input.action_release("ability")
		await step(40)
		print("   levha %d: durum %d konum %s" % [i, bip.magnet_state, bip.global_position])
	Input.action_press("jump"); await step(3); Input.action_release("jump")
	await step(90)
	check("Levhalarla duvarın üstüne", bip.global_position.y > 11.8, str(bip.global_position))
	# Dönen çark
	await place(Vector3(0, 21.1, -123.3), PI, "miknatis")
	Input.action_press("ability"); await step(2); Input.action_release("ability")
	await step(40)
	Input.action_press("jump"); await step(3); Input.action_release("jump")
	await step(90)
	check("Dönen çarka tırmandı", bip.global_position.y > 21.8 and bip.global_position.z < -127.5, str(bip.global_position))
	# Gizli Depo: C2'nin doğu kenarından deponun tutamağına çekil, tırman
	await place(Vector3(6.3, 12.1, -79.5), PI / 2, "miknatis")
	Input.action_press("ability"); await step(2); Input.action_release("ability")
	await step(40)
	Input.action_press("jump"); await step(3); Input.action_release("jump")
	await step(90)
	check("Gizli Depo'ya mıknatısla çıkış", absf(bip.global_position.y - 12.0) < 0.3 and bip.global_position.x > 9.0, str(bip.global_position))
	# Gizli Vinç Kulesi: üç levha
	await place(Vector3(5.5, 26.1, -153), PI / 2, "miknatis")
	for i in 3:
		Input.action_press("ability"); await step(2); Input.action_release("ability")
		await step(40)
	Input.action_press("jump"); await step(3); Input.action_release("jump")
	await step(90)
	check("Vinç Kulesi'ne levhalarla çıkış", bip.global_position.y > 32.8, str(bip.global_position))


func _test_kaya() -> void:
	var gate := level.find_child("Gate_1", true, false)
	var gy: float = gate.global_position.y
	await place(Vector3(0, 0.1, -8.0), PI, "kaya")
	Input.action_press("move_forward"); await step(30); Input.action_release("move_forward")
	await step(60)
	check("Ağır buton kapıyı açtı", gate.global_position.y < gy - 3.0, "%.1f → %.1f" % [gy, gate.global_position.y])
	# Kayasız buton çalışmaz
	var gate2 := level.find_child("Gate_2", true, false)
	var g2y: float = gate2.global_position.y
	await place(Vector3(-5, 0.1, -52.0), PI, "")
	Input.action_press("move_forward"); await step(18); Input.action_release("move_forward")
	await step(40)
	check("Kayasız buton açmaz", absf(gate2.global_position.y - g2y) < 0.1)
	# Yere çakılma: çatlak zemin
	await place(Vector3(0, 0.1, -26.0), PI, "kaya")
	Input.action_press("jump"); await step(10); Input.action_release("jump")
	Input.action_press("ability"); await step(2); Input.action_release("ability")
	await step(90)
	check("Çakılma çatlak zemini kırdı", bip.global_position.y < -4.0, str(bip.global_position))
	# Mağaradan rampayla meydana çıkış (rampa ters eğimliydi: oyuncu boşluğa düşüyordu)
	Input.action_press("move_forward"); await step(480); Input.action_release("move_forward")
	check("Mağaradan rampayla meydana çıktı", bip.global_position.y > -0.3 and bip.global_position.z < -51.0, str(bip.global_position))
	# Su: Kaya batar ve duvarın altından geçer
	await place(Vector3(0, 0.3, -82.5), PI, "kaya")
	await step(90)
	check("Kaya suda dibe battı", bip.global_position.y < -4.5, str(bip.global_position))
	Input.action_press("move_forward"); await step(150); Input.action_release("move_forward")
	check("Su altından bölmeyi geçti", bip.global_position.z < -91.0, str(bip.global_position))
	Input.action_press("move_forward")
	for i in 300:
		await step(1)
		if bip.global_position.y > -0.3 and bip.global_position.z < -102.0:
			break
	Input.action_release("move_forward")
	check("Havuzdan rampayla çıktı", bip.global_position.y > -0.3 and bip.global_position.z < -102.0, str(bip.global_position))
	# Kayasız yüzer, bölmeyi geçemez
	await place(Vector3(0, 0.3, -82.5), PI, "")
	Input.action_press("move_forward"); await step(150); Input.action_release("move_forward")
	check("Kayasız yüzer, geçemez", bip.global_position.y > -1.5 and bip.global_position.z > -88.5, str(bip.global_position))
	# Son parkur: Balon ile 7 m
	await place(Vector3(0, 4.6, -115.5), PI, "balon")
	var p := await jump_forward(30, 400, true)
	check("Son parkur: balonla U2", p.z < -122.5 and absf(p.y - 4.0) < 0.3, str(p))
