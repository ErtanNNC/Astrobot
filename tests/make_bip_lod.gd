extends SceneTree
## Bip'in 49 bin üçgenli modelinden hafif bir kopya üretir (telefon performansı).
## Godot'un içe aktarırken ürettiği detay seviyelerinden (LOD) hedefe en yakın olanı seçer, kullanılmayan
## köşeleri atar ve iskelet ağırlıklarını koruyarak assets/models/pixabay/bip/bip_mesh_lite.res yazar.
## Çalıştırma: godot --headless --path . -s tests/make_bip_lod.gd
const SRC := "res://assets/models/pixabay/bip/idle.fbx"
const OUT := "res://assets/models/pixabay/bip/bip_mesh_lite.res"
const TARGET_TRIS := 12000


func _init() -> void:
	var sc: Node = load(SRC).instantiate()
	var mi: MeshInstance3D = sc.find_children("*", "MeshInstance3D", true, false)[0]
	var src: ArrayMesh = mi.mesh
	var out := ArrayMesh.new()
	for si in src.get_surface_count():
		var arrays := src.surface_get_arrays(si)
		var full: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var best: PackedInt32Array = full
		var d: Dictionary = RenderingServer.mesh_get_surface(src.get_rid(), si)
		var vcount: int = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		print("yüzey ", si, ": ", full.size() / 3, " üçgen, ", vcount, " köşe, LOD sayısı ", (d.get("lods", []) as Array).size())
		for lod in d.get("lods", []):
			var raw: PackedByteArray = lod["index_data"]
			var idx := PackedInt32Array()
			if vcount <= 65536:
				for k in range(0, raw.size(), 2):
					idx.append(raw.decode_u16(k))
			else:
				idx = raw.to_int32_array()
			print("   LOD kenar ", lod["edge_length"], " → ", idx.size() / 3, " üçgen")
			if idx.size() / 3 >= TARGET_TRIS and idx.size() < best.size():
				best = idx
		# İçe aktarıcının tek LOD'u yetmezse: sıkıştırılmış kopyadan bir tur daha sadeleştir
		var im := ImporterMesh.new()
		var tmp := arrays.duplicate()
		tmp[Mesh.ARRAY_INDEX] = best
		im.add_surface(Mesh.PRIMITIVE_TRIANGLES, tmp)
		im.generate_lods(60.0, 25.0, [])
		for li in im.get_surface_lod_count(0):
			var idx2 := im.get_surface_lod_indices(0, li)
			print("   2. tur LOD ", li, " → ", idx2.size() / 3, " üçgen")
			if idx2.size() / 3 >= TARGET_TRIS and idx2.size() < best.size():
				best = idx2
		# Kullanılan köşeleri sıkıştır
		var remap := {}
		var order := PackedInt32Array()
		var new_idx := PackedInt32Array()
		for i in best:
			if not remap.has(i):
				remap[i] = order.size()
				order.append(i)
			new_idx.append(remap[i])
		var na := []
		na.resize(Mesh.ARRAY_MAX)
		for a in Mesh.ARRAY_MAX:
			var arr = arrays[a]
			if arr == null or a == Mesh.ARRAY_INDEX:
				continue
			var per: int = arr.size() / vcount     # köşe başına eleman (kemik/ağırlık 4 ya da 8, teğet 4)
			var dst = arr.duplicate()
			dst.resize(order.size() * per)
			for n in order.size():
				for c in per:
					dst[n * per + c] = arr[order[n] * per + c]
			na[a] = dst
		na[Mesh.ARRAY_INDEX] = new_idx
		var flags := src.surface_get_format(si) & (Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS)
		out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, na, [], {}, flags)
		out.surface_set_material(si, src.surface_get_material(si))
		print("   seçilen: ", new_idx.size() / 3, " üçgen, ", order.size(), " köşe")
	print("kaydedildi: ", ResourceSaver.save(out, OUT))
	sc.free()
	quit()
