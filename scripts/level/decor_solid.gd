class_name DecorSolid
extends RefCounted
## Süslerin çarpışması. Görsel süsler (MultiMesh'li kit parçaları ve Decor altındaki modeller) çarpışmasız eklenir;
## içlerinden geçilmesin diye iri olanlara burada çarpışma kurulur
## (geliştirici testi 2026-11-22: "kayaların, hediye paketlerinin, boruların içine giriliyor").
## Şekil modelin kendi üçgenlerinden yapılır: kemerlerin ve tünellerin altından yine geçilir.
## Katman 2 (küçük süsler): Bip çarpar, kamera kolu çarpmaz. Kurallar: docs/features/oyun-hissi/design.md

const MIN_HEIGHT := 0.5     ## m; bundan alçak süsler (taş, çiçek, halı) yürünür kalır
const MIN_WIDTH := 0.5      ## m
const MAX_SIZE := 14.0      ## m; daha büyükleri uzak manzaradır
const MAX_FACES := 6000     ## çok ayrıntılı modelde üçgen yerine kutu kullanılır
## Adında bunlar geçen modeller çarpışmasız kalır: zemin karoları/örtüsü, bulut, toplanabilir görünümlü süsler, ot ve çiçekler
const SKIP_PREFIX := ["platform_", "cap"]
## Bina/kule kaplamaları da burada: onların oynanış şekilleri (tırmanma levhaları, duvarlar) betikte ayrıca kurulur
const SKIP := ["cloud", "star_", "diamond", "heart", "grass", "flower", "plant", "bush", "mushroom",
		"rug", "indicator", "flag", "snow-flat", "snow-pile", "snowflat", "snowpile", "lantern", "candy-cane",
		"building", "tower", "castle", "wall", "hills", "mountain", "structure", "crane", "arch", "signage", "fence"]

static var _face_cache := {}      ## Mesh → PackedVector3Array


static func skipped(model_name: String) -> bool:
	var base := model_name.to_lower()
	for w in SKIP_PREFIX:
		if base.begins_with(w):
			return true
	for w in SKIP:
		if base.contains(w):
			return true
	return false


static func new_body(parent: Node3D) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = "SusCarpisma"
	body.collision_layer = 2
	body.collision_mask = 0
	parent.add_child(body)
	body.global_transform = Transform3D.IDENTITY
	return body


## parts: [[Mesh, dünya dönüşümü], ...]. Süs yeterince iriyse dünya uzayında bir CollisionShape3D döner, değilse null.
static func is_tree(model_name: String) -> bool:
	var base := model_name.to_lower()
	return base.contains("tree") or base.contains("pine")


## Ağaç: yapraklar zıplama yolunu kapatmasın diye yalnızca gövde katıdır (ince bir silindir).
static func trunk_for(parts: Array) -> CollisionShape3D:
	if parts.is_empty():
		return null
	var box := AABB()
	var first := true
	for part in parts:
		var b: AABB = (part[1] as Transform3D) * (part[0] as Mesh).get_aabb()
		box = b if first else box.merge(b)
		first = false
	if box.size.y < 1.2 or box.size.y > MAX_SIZE:
		return null
	var cyl := CylinderShape3D.new()
	cyl.radius = clampf(maxf(box.size.x, box.size.z) * 0.1, 0.15, 0.6)
	cyl.height = minf(box.size.y, 3.0)
	var cs := CollisionShape3D.new()
	cs.shape = cyl
	cs.position = Vector3(box.get_center().x, box.position.y + cyl.height / 2.0, box.get_center().z)
	return cs


static func shape_for(parts: Array) -> CollisionShape3D:
	if parts.is_empty():
		return null
	var box := AABB()
	var first := true
	var total := 0
	for part in parts:
		var b: AABB = (part[1] as Transform3D) * (part[0] as Mesh).get_aabb()
		box = b if first else box.merge(b)
		first = false
		total += _faces(part[0]).size() / 3
	var wide := maxf(box.size.x, box.size.z)
	if box.size.y < MIN_HEIGHT or wide < MIN_WIDTH or maxf(wide, box.size.y) > MAX_SIZE:
		return null
	var cs := CollisionShape3D.new()
	if total > MAX_FACES:
		var bs := BoxShape3D.new()
		bs.size = box.size
		cs.shape = bs
		cs.position = box.get_center()
		return cs
	var faces := PackedVector3Array()
	for part in parts:
		var m: Transform3D = part[1]
		for v in _faces(part[0]):
			faces.append(m * v)
	var sh := ConcavePolygonShape3D.new()
	sh.backface_collision = true
	sh.set_faces(faces)
	cs.shape = sh
	return cs


static func _faces(mesh: Mesh) -> PackedVector3Array:
	if not _face_cache.has(mesh):
		_face_cache[mesh] = mesh.get_faces()
	return _face_cache[mesh]


static func _mesh_parts(n: Node, out: Array) -> void:
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		out.append([(n as MeshInstance3D).mesh, (n as MeshInstance3D).global_transform])
	for c in n.get_children():
		_mesh_parts(c, out)


## Alanın Decor düğümü altındaki modeller: çarpışmasız olanlara çarpışma ekler; kayaların eski, sabit boylu
## çarpışma şeklini (büyük kayada küçük kalıyordu) modelin gerçek biçimiyle değiştirir. Ağaçlar gövde şekliyle kalır.
static func cover_decor(level: Node3D) -> int:
	var decor := level.get_node_or_null("Decor") as Node3D
	if decor == null:
		return 0
	var body: StaticBody3D = null
	var n := 0
	for c in decor.get_children():
		if not (c is Node3D) or c.get_script() != null or skipped(c.name):
			continue
		var target: Node = c
		if c is StaticBody3D:
			if not String(c.name).to_lower().contains("rock"):
				continue                      # ağaç vb.: kendi (gövde) şekli doğru
			target = c.get_node_or_null("Model")
			if target == null:
				continue
		var parts := []
		_mesh_parts(target, parts)
		var cs := trunk_for(parts) if is_tree(c.name) else shape_for(parts)
		if cs == null:
			continue
		if c is StaticBody3D:
			var old := c.get_node_or_null("Shape")
			if old:
				old.queue_free()
		if body == null:
			body = new_body(level)
		body.add_child(cs)
		n += 1
	return n
