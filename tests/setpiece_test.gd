extends Node
## "Vay" anları: her alanda en az bir tane var; top Bip'i hedefe ulaştırır; gösteriler hatasız oynar ve temizlenir.
var level: Node
var bip
var fails := 0
var base := Vector3(300, 60, 300)

func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1

func step(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func floor_at(center: Vector3, size: Vector3) -> void:
	var b := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	b.add_child(cs)
	level.add_child(b)
	b.global_position = center

func _ready() -> void:
	# 1) Her alan sahnesinde (patronlar hariç) en az bir vay anı
	for ch in GameState.CHAPTERS:
		for a in GameState.CHAPTERS[ch]:
			if String(a["id"]).ends_with("patron"):
				continue
			var txt := FileAccess.get_file_as_string(a["scene"])
			check("vay anı var: " + a["id"], txt.contains("res://scripts/setpiece/"))

	GameState.data = GameState.new_data()
	level = load("res://scenes/levels/sandbox.tscn").instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().current_scene = level
	bip = level.get_node("GameRig/Bip")

	# 2) Fırlatma Topu
	floor_at(base + Vector3(0, -0.5, 0), Vector3(8, 1, 8))
	floor_at(base + Vector3(20, 9.5, -14), Vector3(8, 1, 8))
	var c := Cannon.new()
	c.offset = Vector3(20, 10, -14)
	level.add_child(c)
	c.global_position = base
	bip.reset_state(base + Vector3(0, 0.2, 2.5))
	await step(5)
	bip.reset_state(base + Vector3(0, 0.3, 0))
	await step(8)
	check("top Bip'i içine aldı, kontrol kapandı", c.busy and not bip.controls_enabled)
	await step(int((c.windup + c.time) * 60) / 2)
	check("uçuşta Bip yerden yüksekte", bip.global_position.y > base.y + 3.0, str(bip.global_position - base))
	await step(int((c.windup + c.time) * 60) / 2 + 40)
	var d: float = bip.global_position.distance_to(base + c.offset)
	check("Bip hedefe indi", d < 1.0, "uzaklık %.2f" % d)
	check("kontrol ve fizik geri geldi", bip.controls_enabled and bip.is_physics_processing() and bip.visual.visible)
	await step(70)
	check("Bip hedef platformda duruyor", bip.is_on_floor() and absf(bip.global_position.y - (base.y + 10.0)) < 0.3, str(bip.global_position - base))
	check("top yeniden kullanılabilir", not c.busy)

	# 3) Manzara
	var v := Vista.new()
	v.title = "Deneme"
	level.add_child(v)
	v.global_position = base + Vector3(20, 10, -16)
	bip.reset_state(base + Vector3(20, 10.2, -16))
	await step(6)
	check("manzara bir kez tetiklendi", v._done)

	# 4) Gösteriler: her tür oynar, kalıcı olmayanlar arkasını temizler
	bip.reset_state(base + Vector3(0, 0.2, 2.5))
	await step(5)
	for kind in ["whale", "eruption", "fireworks", "meteor", "lightning", "balloons", "beacon", "aurora", "crystals", "skywhale", "statik"]:
		var sp := SetPiece.new()
		sp.kind = kind
		sp.offset = Vector3(0, 4, -20)
		level.add_child(sp)
		sp.global_position = base + Vector3(60, 0, 0)
		var before := level.get_child_count()
		sp.play()
		await step(30)
		check("gösteri oynadı: " + kind, sp.played == 1)
		if kind in ["whale", "fireworks", "lightning"]:
			await step(60 * 5)
			check("gösteri temizlendi: " + kind, sp._actors.is_empty() and level.get_child_count() <= before, "%d → %d" % [before, level.get_child_count()])
		sp.queue_free()
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
