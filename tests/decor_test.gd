extends Node
## Süslerin içinden geçilmez (kaya, hediye paketi, yeşil boru katıdır; ot ve çiçek değildir) ve dönen zeminlerin
## kenar şeritleri zeminle birlikte döner. (Geliştirici testi 2026-11-22'den iki hata.)
var fails := 0

func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1

## Sahnedeki kit parçalarından adı `needle` içeren ilkinin dünya dönüşümü.
func find_item(level: Node, needle: String, min_scale := 0.0) -> Array:
	for n in level.find_children("*", "Node3D", true, false):
		if n.get("items") != null:
			for i in range(0, n.items.size() - 1, 2):
				if String(n.items[i]).contains(needle) and (n.items[i + 1] as Transform3D).basis.y.length() * 1.0 >= min_scale:
					return [true, (n as Node3D).global_transform * (n.items[i + 1] as Transform3D)]
	return [false, Transform3D.IDENTITY]

## Parçaya dört yandan, tabanının biraz üstünden yatay ışın: süs çarpışmasına (SusCarpisma) parçanın yakınında değiyor mu?
## (Tepeden bakmak yanıltır: boru içi boştur, yakındaki sandık da aynı katmandadır.)
func solid_at(level: Node3D, xf: Transform3D) -> bool:
	var space := level.get_world_3d().direct_space_state
	var c := xf.origin + Vector3.UP * 0.3 * xf.basis.y.length()
	for d in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(c + d * 8.0, c, 2))
		if not hit.is_empty() and (hit.collider as Node).name == "SusCarpisma" and (hit.position as Vector3).distance_to(c) < 3.0:
			return true
	return false

func load_level(path: String) -> Node3D:
	var level: Node3D = load(path).instantiate()
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	for i in 6:
		await get_tree().physics_frame
	return level

func _ready() -> void:
	await get_tree().process_frame
	GameState.data = GameState.new_data()
	for c in [["res://scenes/chapter1/a4_kaya_ocagi.tscn", "Rock_", true, "iri kaya", 1.8],
			["res://scenes/chapter1/a1_yay_bahcesi.tscn", "pipe_straight_A_green", true, "yeşil boru"],
			["res://scenes/chapter5/e1_oyuncak_kasabasi.tscn", "present_E_red", true, "hediye paketi"],
			["res://scenes/chapter1/a1_yay_bahcesi.tscn", "flowers.glb", false, "çiçek"],
			["res://scenes/chapter3/c3_zirve.tscn", "nosolid", false, "kenar süsü"]]:
		var level: Node3D = await load_level(c[0])
		var it := find_item(level, c[1], c[4] if c.size() > 4 else 0.0)
		check("%s sahnede var" % c[3], it[0])
		if it[0]:
			var hit := solid_at(level, it[1])
			check("%s %s" % [c[3], "katı" if c[2] else "içinden geçilir"], hit == c[2])
		level.free()
		await get_tree().process_frame

	# Dönen zemindeki uzun kenar şeridi zeminle aynı yöne bakmalı (Mıknatıs Fabrikası P1: 40° dönük)
	var fab: Node3D = await load_level("res://scenes/chapter1/a3_miknatis_fabrikasi.tscn")
	var yaw_ok := false
	var checked := 0
	for n in fab.find_children("*", "Node3D", true, false):
		if n.get("items") == null:
			continue
		for i in range(0, n.items.size() - 1, 2):
			if not String(n.items[i]).get_file().begins_with("platform_1x1x1_yellow"):
				continue
			var b: Basis = (n.items[i + 1] as Transform3D).basis
			var sx := b.x.length()
			var sz := b.z.length()
			if maxf(sx, sz) < 8.0:
				continue
			checked += 1
			# yerel eksenler dik kalmalı (eski hatada şerit eğiliyor/yanlış yöne uzuyordu)
			if absf(b.x.normalized().dot(b.z.normalized())) > 0.01:
				check("kenar şeridi eksenleri dik", false, str(b))
			if absf(b.x.normalized().x) < 0.99 and absf(b.x.normalized().z) < 0.99:
				yaw_ok = true          # en az bir şerit gerçekten dönük
	check("fabrikada uzun kenar şeritleri bulundu", checked > 10, str(checked))
	check("dönen zeminde şerit de dönük", yaw_ok)
	fab.free()
	await get_tree().process_frame

	# Havada duran nesne olmasın: her alanda sandık, trambolin, yetenek kaynağı ve kontrol noktasının altında zemin var
	# (geliştirici testi 2026-11-22: dönüş noktasındaki sütunun sandığı ve pilleri sütundan ayrı dönüp havada kalmıştı)
	for ch in GameState.CHAPTERS:
		for a in GameState.CHAPTERS[ch]:
			var lv: Node3D = await load_level(a["scene"])
			var space := lv.get_world_3d().direct_space_state
			var bad := []
			var n := 0
			for pat in ["Crate*", "Trampoline*", "Copy*", "Checkpoint*", "Cannon*"]:
				for e in lv.find_children(pat, "", true, false):
					# patron aşamasına bağlı nesneler patronun gövdesinde durur (zemin dövüşte kurulur): sayılmaz
					if not (e is Node3D) or (e.get_parent() is AnimatableBody3D) or e.is_in_group("boss_phase"):
						continue
					n += 1
					var o: Vector3 = (e as Node3D).global_position
					var q := PhysicsRayQueryParameters3D.create(o + Vector3.UP * 0.6, o + Vector3.DOWN * 1.2, 1)
					if e is CollisionObject3D:
						q.exclude = [(e as CollisionObject3D).get_rid()]
					if space.intersect_ray(q).is_empty():
						bad.append("%s %s" % [e.name, str(o.snapped(Vector3.ONE * 0.1))])
			check("%s: %d nesnenin hepsi zeminde" % [a["id"], n], bad.is_empty(), str(bad))
			lv.free()
			await get_tree().process_frame
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
