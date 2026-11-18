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
	await place(Vector3(0, 0.1, -6.5), PI, "yay")
	var p := await jump_forward()
	check("Yay ile 4 m'lik terasa çıkış", absf(p.y - 4.0) < 0.2, str(p))
	await place(Vector3(0, 8.1, -40.5), PI, "")
	await step(5)
	# Trambolinli platform: üstüne düşünce yükseğe sıçrar
	var pa := level.find_child("Platform_3", true, false)
	await place(pa.global_position + Vector3(0, 3.0, 0), PI, "")
	var peak: float = bip.global_position.y
	for i in 120:
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
	check("Hareketli trambolin sıçratır", peak > pa.global_position.y + 5.0, "tepe %.1f" % peak)


func _test_balon() -> void:
	await place(Vector3(0, 17.1, -35.3), PI, "balon")
	var p := await jump_forward(30, 400, true)
	check("Balonla 12 m'lik boşluk", p.z < -47.5 and absf(p.y - 14.0) < 0.3, str(p))
	await place(Vector3(0, 18.6, -93.3), PI, "balon")
	p = await jump_forward(30, 500, true)
	check("Rüzgârla yukarıdaki mesaya", p.z < -109.5 and absf(p.y - 22.0) < 0.3, str(p))
	await place(Vector3(0, 18.6, -93.3), PI, "")
	p = await jump_forward(30, 300)
	check("Balonsuz rüzgâr kanyonu geçilemez", p.y < 10.0 or p.z > -96.0, str(p))


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
