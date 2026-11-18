extends StaticBody3D
## Metal yüzey: Mıknatıs taşıyan Bip, Yetenek tuşuyla buraya çekilip yapışır.
## Yalnızca eksenlere hizalı kutular (döndürme yalnızca Y ekseninde 90°'nin katları).

@export var size := Vector3(2, 2, 2)


func _ready() -> void:
	add_to_group("metal")
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	add_child(cs)
	var mesh := BoxMesh.new()
	mesh.size = size
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.62, 0.68, 0.78)
	m.metallic = 0.7
	m.roughness = 0.35
	add_child(AbilityModels.mesh_node(mesh, m))
	# Perçinler ve mavi şerit: "metal" olduğu her açıdan anlaşılsın
	var stripe := BoxMesh.new()
	stripe.size = size + Vector3(0.04, -size.y + 0.18, 0.04)
	add_child(AbilityModels.mesh_node(stripe, AbilityModels.mat(Color(0.25, 0.5, 1.0), 0.3, 0.6), Vector3(0, size.y / 2 - 0.25, 0)))
	var rivet := SphereMesh.new()
	rivet.radial_segments = 6
	rivet.rings = 3
	rivet.radius = 0.07
	rivet.height = 0.14
	var rm := AbilityModels.mat(Color(0.85, 0.88, 0.95), 0.2)
	for sx in [-1, 1]:
		for sy in [-1, 1]:
			for face in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
				var p: Vector3 = face * (size * 0.5 + Vector3.ONE * 0.01)
				var t := Vector3(face.z, 0, -face.x)
				p += t * sx * (absf(t.x) * size.x + absf(t.z) * size.z) * 0.4 + Vector3.UP * sy * size.y * 0.4
				add_child(AbilityModels.mesh_node(rivet, rm, p))


func closest_point(p: Vector3) -> Vector3:
	var local := to_local(p)
	var h := size * 0.5
	var c := Vector3(clampf(local.x, -h.x, h.x), clampf(local.y, -h.y, h.y), clampf(local.z, -h.z, h.z))
	# Nokta kutunun içindeyse en yakın yüze it
	if c == local:
		var dx := h.x - absf(local.x)
		var dy := h.y - absf(local.y)
		var dz := h.z - absf(local.z)
		if dx <= dy and dx <= dz:
			c.x = h.x * signf(local.x)
		elif dy <= dz:
			c.y = h.y * signf(local.y)
		else:
			c.z = h.z * signf(local.z)
	return to_global(c)


func surface_normal(p: Vector3) -> Vector3:
	var local := to_local(p)
	var h := size * 0.5
	var d := Vector3(absf(absf(local.x) - h.x), absf(absf(local.y) - h.y), absf(absf(local.z) - h.z))
	# Kenar ve köşelerde yan yüzleri tercih et (Bip yana yapışsın, üst kenara tırmanabilsin)
	var e := 0.05
	var n := Vector3.ZERO
	if d.x <= d.z + e and d.x <= d.y + e:
		n = Vector3(signf(local.x), 0, 0)
	elif d.z <= d.y + e:
		n = Vector3(0, 0, signf(local.z))
	else:
		n = Vector3(0, signf(local.y), 0)
	return (global_basis * n).normalized()
