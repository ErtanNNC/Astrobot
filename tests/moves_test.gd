extends Node
## İlerledikçe açılan hareketler: kenara tutunma, dönme, atılma, duvar zıplaması, çift zıplama.
var level: Node
var bip
var fails := 0
var base := Vector3(200, 50, 200)   # testler için havada ayrı bir zemin

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

func box(center: Vector3, size: Vector3) -> StaticBody3D:
	var b := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	b.add_child(cs)
	level.add_child(b)
	b.global_position = center
	return b

func place(p: Vector3, yaw := PI) -> void:
	bip.reset_state(p)
	bip.facing_yaw = yaw
	bip.rotation.y = yaw
	level.cam.snap_to_target()
	await step(10)

func peak_of_jump(second_press_at := -1) -> float:
	var y0: float = bip.global_position.y
	var peak := y0
	Input.action_press("jump")
	for i in 90:
		if i == 6:
			Input.action_release("jump")
		if i == second_press_at:
			Input.action_press("jump")
		await get_tree().physics_frame
		peak = maxf(peak, bip.global_position.y)
		if OS.has_environment("DBG2") and second_press_at > 0 and i < 40:
			print(i, " y=%.2f vy=%.2f dbl=%s hov=%s" % [bip.global_position.y - y0, bip.velocity.y, bip._double_used, bip.hovering])
	Input.action_release("jump")
	return peak - y0

func _run() -> void:
	await step(5)
	# Açılma sırası
	check("Yeni oyunda yalnız tutunma açık", GameState.has_move("ledge") and not GameState.has_move("spin") and not GameState.has_move("double"))
	GameState.data["furthest"] = "ch2_rihtim"
	check("Bölüm 1 bitince dönme + atılma", GameState.has_move("spin") and GameState.has_move("dash") and not GameState.has_move("wall"))
	check("Duyurulacak yeni hareketler", GameState.new_moves() == ["spin", "dash"], str(GameState.new_moves()))
	GameState.data["furthest"] = "ch4_bulut"
	check("Bölüm 3 bitince hepsi", GameState.unlocked_moves().size() == 5)

	box(base + Vector3(0, -0.5, 0), Vector3(40, 1, 40))
	# Jet süzülme: Zıpla basılı tutulunca tepe noktasından sonra asılı kalır
	await place(base + Vector3(0, 0.1, 0))
	Input.action_press("jump")
	var hovered := false
	var air := 0
	for i in 150:
		await get_tree().physics_frame
		if bip.hovering:
			hovered = true
		if not bip.is_on_floor():
			air += 1
		elif i > 5:
			break
	Input.action_release("jump")
	check("Jet süzülme: basılı tutunca asılı kalır", hovered and air > 75, "havada %d kare" % air)
	await step(20)
	# Çift zıplama
	await place(base + Vector3(0, 0.1, 0))
	var single := await peak_of_jump(-1)
	await step(20)
	await place(base + Vector3(0, 0.1, 0))
	var dbl := await peak_of_jump(20)
	check("Çift zıplama daha yükseğe çıkar", dbl > single + 1.0, "tek %.2f, çift %.2f" % [single, dbl])
	await step(20)
	# Kaya ile çift zıplama yok
	GameState.set_ability("kaya")
	await place(base + Vector3(0, 0.1, 0))
	var rock1 := await peak_of_jump(-1)
	await place(base + Vector3(0, 0.1, 0))
	bip._double_used = false
	Input.action_press("jump")
	await step(12)
	Input.action_release("jump")
	await step(2)
	Input.action_press("jump")
	await step(2)
	Input.action_release("jump")
	check("Kaya çift zıplayamaz", not bip._double_used)
	await step(40)
	GameState.set_ability("")

	# Dönme saldırısı: yakındaki sandığı kırar
	await place(base + Vector3(5, 0.1, 5))
	var crate := StaticBody3D.new()
	crate.set_script(load("res://scripts/entities/crate.gd"))
	level.add_child(crate)
	crate.global_position = bip.global_position + Vector3(1.0, 0, 0)
	await step(2)
	Input.action_press("attack")
	await step(2)
	Input.action_release("attack")
	await step(5)
	check("Dönme saldırısı sandığı kırar", not is_instance_valid(crate))

	# Havada atılma
	await step(30)
	await place(base + Vector3(-10, 0.1, 10))
	var fwd := Vector3(sin(bip.facing_yaw), 0, cos(bip.facing_yaw))
	var p0: Vector3 = bip.global_position
	Input.action_press("jump")
	await step(10)
	Input.action_release("jump")
	Input.action_press("attack")
	await step(2)
	Input.action_release("attack")
	await step(14)
	var moved: float = (bip.global_position - p0).dot(fwd)
	check("Havada atılma ileri götürür", moved > 2.0, "%.2f m" % moved)
	await step(60)

	# Kenara tutunma ve çıkma: önde 2.6 m yüksek blok
	await place(base + Vector3(0, 0.1, -10))
	var dir: Vector3 = bip._camera_relative(Vector2(0, -1)).normalized()
	var top_y := base.y + 2.6
	# Bölümlerdeki gibi CSG kutu (tutunma bir ara yalnızca StaticBody3D'de çalışıyordu)
	var csg := CSGBox3D.new()
	csg.size = Vector3(5, 3.6, 5)
	csg.use_collision = true
	level.add_child(csg)
	csg.global_position = bip.global_position + dir * 3.1 + Vector3(0, -1.0 + 1.8, 0)
	await step(2)
	# kutunun üstü: merkez y = base.y + 0.8 → üst = base.y + 2.6
	Input.action_press("move_forward")
	await step(4)
	Input.action_press("jump")
	var hung := false
	var climbed := false
	for i in 120:
		await get_tree().physics_frame
		if bip.ledge_hanging:
			hung = true
		if OS.has_environment("DBG"):
			print(i, " y=%.2f vy=%.2f hang=%s floor=%s" % [bip.global_position.y - base.y, bip.velocity.y, bip.ledge_hanging, bip.is_on_floor()])
		if i == 20:
			Input.action_release("jump")
		if hung and not bip.ledge_hanging and bip.is_on_floor() and bip.global_position.y > top_y - 0.1:
			climbed = true
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(20)
	check("Kenara tutunur", hung)
	check("Kenardan yukarı çıkar", climbed, str(bip.global_position.y - top_y))

	# Duvar zıplaması: önde yüksek duvar
	await place(base + Vector3(10, 0.1, -10))
	dir = bip._camera_relative(Vector2(0, -1)).normalized()
	box(bip.global_position + dir * 1.5 + Vector3(0, 4, 0), Vector3(6, 9, 0.5).abs() if absf(dir.z) > 0.5 else Vector3(0.5, 9, 6))
	Input.action_press("move_forward")
	Input.action_press("jump")
	await step(8)
	Input.action_release("jump")
	var slid := false
	var kicked := false
	for i in 80:
		await get_tree().physics_frame
		if bip.wall_sliding and not slid:
			slid = true
			Input.action_press("jump")
		elif slid and not kicked:
			kicked = true
			Input.action_release("jump")
			await step(3)
			var away: float = Vector3(bip.velocity.x, 0, bip.velocity.z).dot(-dir)
			check("Duvar zıplaması duvardan iter", away > 3.0 and bip.velocity.y > 2.0, "uzak %.2f, vy %.2f" % [away, bip.velocity.y])
			break
	Input.action_release("move_forward")
	check("Duvarda kayar", slid)
