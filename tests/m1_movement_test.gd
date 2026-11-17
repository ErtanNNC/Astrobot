extends SceneTree
## M1 otomatik testi: zıplama yüksekliği, 2 m boşluk ve 1,5 m basamak.
## Çalıştırma:  godot --headless --path . -s tests/m1_movement_test.gd

var level: Node
var bip
var frames := 0
var fails := 0


func _initialize() -> void:
	level = load("res://scenes/levels/test_area.tscn").instantiate()
	root.add_child(level)
	bip = level.get_node("Bip")
	_run.call_deferred()


func step(n: int) -> void:
	for i in n:
		await physics_frame


func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1


func place(pos: Vector3) -> void:
	bip.reset_state(pos)
	bip.facing_yaw = PI
	bip.rotation.y = PI
	level.get_node("FollowCamera").snap_to_target()
	await step(10)


func _run() -> void:
	await step(5)

	# 1) Tam zıplama yüksekliği (~2,2 m)
	await place(Vector3(0, 0.05, 6))
	var y0: float = bip.global_position.y
	Input.action_press("jump")
	var peak := y0
	for i in 90:
		await physics_frame
		peak = maxf(peak, bip.global_position.y)
	Input.action_release("jump")
	check("Tam zıplama ~2,2 m", absf(peak - y0 - 2.2) < 0.15, "%.2f m" % (peak - y0))

	# 2) Kısa zıplama (erken bırakma) belirgin şekilde alçak
	await place(Vector3(0, 0.05, 6))
	y0 = bip.global_position.y
	Input.action_press("jump")
	await step(4)
	Input.action_release("jump")
	peak = y0
	for i in 60:
		await physics_frame
		peak = maxf(peak, bip.global_position.y)
	check("Kısa zıplama < 1,2 m", peak - y0 < 1.2, "%.2f m" % (peak - y0))

	# 3) 2 m boşluk: zeminin kenarı z=-10, ada z=-12..-18
	await place(Vector3(0, 0.05, -4))
	Input.action_press("move_forward")
	while bip.global_position.z > -9.6:
		await physics_frame
	Input.action_press("jump")
	await step(20)
	Input.action_release("jump")
	await step(40)
	Input.action_release("move_forward")
	await step(30)
	var p: Vector3 = bip.global_position
	check("2 m boşluk aşıldı", bip.is_on_floor() and p.z < -12.0 and p.y > -0.2, "konum %s" % p)

	# 4) Coyote time: kenardan 0,06 s sonra zıplama hâlâ çalışır
	await place(Vector3(0, 0.05, -4))
	Input.action_press("move_forward")
	while bip.global_position.z > -10.35:
		await physics_frame
	await step(3)
	Input.action_press("jump")
	await step(20)
	Input.action_release("jump")
	await step(40)
	Input.action_release("move_forward")
	await step(30)
	p = bip.global_position
	check("Coyote time ile 2 m boşluk", bip.is_on_floor() and p.z < -12.0, "konum %s" % p)

	# 5) 1,5 m basamak (x=-6, z=-4): önünden koşup zıpla
	await place(Vector3(-6, 0.05, 1))
	bip.global_position = Vector3(-6, 0.05, 0.0)
	await step(2)
	Input.action_press("move_forward")
	await step(4)
	Input.action_press("jump")
	for i in 90:
		await physics_frame
		if bip.is_on_floor() and bip.global_position.y > 1.0:
			break
	Input.action_release("jump")
	Input.action_release("move_forward")
	await step(30)
	p = bip.global_position
	check("1,5 m basamağa çıkıldı", bip.is_on_floor() and absf(p.y - 1.5) < 0.1, "konum %s" % p)

	# 6) Zıplama tamponu: inişten hemen önce basılan zıplama inişte çalışır
	await place(Vector3(0, 0.05, 6))
	Input.action_press("jump")
	await step(3)
	Input.action_release("jump")
	while not bip.is_on_floor() or bip.velocity.y > 0.0:
		await physics_frame
		if bip.global_position.y < 0.5 and bip.velocity.y < 0.0:
			break
	Input.action_press("jump")
	await step(12)
	check("Zıplama tamponu", bip.global_position.y > 0.6, "y=%.2f" % bip.global_position.y)
	Input.action_release("jump")

	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	quit(1 if fails > 0 else 0)
