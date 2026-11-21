class_name HatModels
extends RefCounted
## Bip'in şapkaları: basit şekillerden, oyuncak görünüşlü. Yıldızla açılır (GameState.HATS), Kostüm Dolabı'ndan seçilir.
## Ölçü metre; başın tepesine (kopyalama ucunun dibine) oturur. Bkz. docs/features/kostum/design.md


static func make(id: String) -> Node3D:
	var root := Node3D.new()
	match id:
		"parti":
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = 0.16
			cone.height = 0.36
			root.add_child(AbilityModels.mesh_node(cone, AbilityModels.mat(Color(0.95, 0.3, 0.55), 0.4), Vector3(0, 0.18, 0)))
			for i in 3:
				var band := TorusMesh.new()
				band.inner_radius = 0.02 + (2 - i) * 0.045
				band.outer_radius = band.inner_radius + 0.03
				root.add_child(AbilityModels.mesh_node(band, AbilityModels.mat(Color(1.0, 0.9, 0.3), 0.4), Vector3(0, 0.07 + i * 0.1, 0)))
			var pom := SphereMesh.new()
			pom.radius = 0.05
			pom.height = 0.1
			root.add_child(AbilityModels.mesh_node(pom, AbilityModels.mat(Color(1, 1, 1), 0.6), Vector3(0, 0.38, 0)))
		"silindir":
			var brim := CylinderMesh.new()
			brim.top_radius = 0.24
			brim.bottom_radius = 0.24
			brim.height = 0.03
			var black := AbilityModels.mat(Color(0.12, 0.12, 0.16), 0.5)
			root.add_child(AbilityModels.mesh_node(brim, black, Vector3(0, 0.015, 0)))
			var top := CylinderMesh.new()
			top.top_radius = 0.15
			top.bottom_radius = 0.14
			top.height = 0.26
			root.add_child(AbilityModels.mesh_node(top, black, Vector3(0, 0.16, 0)))
			var band := CylinderMesh.new()
			band.top_radius = 0.146
			band.bottom_radius = 0.146
			band.height = 0.05
			root.add_child(AbilityModels.mesh_node(band, AbilityModels.mat(Color(0.85, 0.2, 0.2), 0.5), Vector3(0, 0.06, 0)))
		"tac":
			var gold := AbilityModels.mat(Color(1.0, 0.8, 0.2), 0.25, 0.5)
			var ring := CylinderMesh.new()
			ring.top_radius = 0.17
			ring.bottom_radius = 0.16
			ring.height = 0.1
			root.add_child(AbilityModels.mesh_node(ring, gold, Vector3(0, 0.05, 0)))
			for i in 6:
				var a := TAU * i / 6.0
				var spike := PrismMesh.new()
				spike.size = Vector3(0.09, 0.13, 0.03)
				root.add_child(AbilityModels.mesh_node(spike, gold, Vector3(cos(a) * 0.155, 0.16, sin(a) * 0.155), Vector3(0, -a + PI / 2, 0)))
				var gem := SphereMesh.new()
				gem.radius = 0.025
				gem.height = 0.05
				root.add_child(AbilityModels.mesh_node(gem, AbilityModels.mat(Color(0.9, 0.2, 0.3) if i % 2 == 0 else Color(0.2, 0.6, 1.0), 0.2, 0.8), Vector3(cos(a) * 0.17, 0.06, sin(a) * 0.17)))
		"pervane":
			var cap := SphereMesh.new()
			cap.radius = 0.19
			cap.height = 0.2
			cap.is_hemisphere = true
			root.add_child(AbilityModels.mesh_node(cap, AbilityModels.mat(Color(0.25, 0.6, 0.95), 0.5), Vector3.ZERO))
			var brim := CylinderMesh.new()
			brim.top_radius = 0.12
			brim.bottom_radius = 0.12
			brim.height = 0.02
			root.add_child(AbilityModels.mesh_node(brim, AbilityModels.mat(Color(0.95, 0.3, 0.3), 0.5), Vector3(0, 0.01, 0.17)))
			var stick := CylinderMesh.new()
			stick.top_radius = 0.012
			stick.bottom_radius = 0.012
			stick.height = 0.1
			root.add_child(AbilityModels.mesh_node(stick, AbilityModels.mat(Color(0.9, 0.9, 0.9), 0.4), Vector3(0, 0.15, 0)))
			var blades := Node3D.new()
			blades.name = "HatBlades"
			blades.position.y = 0.2
			root.add_child(blades)
			for i in 2:
				var bl := BoxMesh.new()
				bl.size = Vector3(0.3, 0.012, 0.05)
				blades.add_child(AbilityModels.mesh_node(bl, AbilityModels.mat(Color(1.0, 0.85, 0.2), 0.4), Vector3.ZERO, Vector3(0, i * PI / 2, 0)))
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return root
