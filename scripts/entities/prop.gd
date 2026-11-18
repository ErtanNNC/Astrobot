extends Node3D
## Basit süs: bir model ya da şekil, isteğe bağlı dönme/sallanma.

@export_enum("gear", "lamp", "station", "screen", "dark_tower", "storm", "rain", "generator") var kind := "gear"
@export var size := 1.0
@export var spin := 0.0          ## rad/s
@export var color := Color(0.75, 0.78, 0.85)

var _t := 0.0
var _part: Node3D


func _ready() -> void:
	match kind:
		"gear":
			var g := CylinderMesh.new()
			g.top_radius = 0.9 * size
			g.bottom_radius = 0.9 * size
			g.height = 0.25 * size
			g.radial_segments = 12
			_part = Node3D.new()
			add_child(_part)
			var m := AbilityModels.mat(color, 0.35)
			m.metallic = 0.6
			_part.add_child(AbilityModels.mesh_node(g, m))
			for i in 10:
				var tooth := BoxMesh.new()
				tooth.size = Vector3(0.3, 0.25, 0.35) * size
				var a := TAU * i / 10.0
				_part.add_child(AbilityModels.mesh_node(tooth, m, Vector3(cos(a), 0, sin(a)) * 1.0 * size, Vector3(0, -a, 0)))
			var hub := CylinderMesh.new()
			hub.radial_segments = 16
			hub.rings = 1
			hub.top_radius = 0.25 * size
			hub.bottom_radius = 0.25 * size
			hub.height = 0.35 * size
			_part.add_child(AbilityModels.mesh_node(hub, AbilityModels.mat(Color(0.95, 0.75, 0.2)), Vector3.ZERO))
			_part.rotation.x = PI / 2
		"lamp":
			var bulb := SphereMesh.new()
			bulb.radial_segments = 12
			bulb.rings = 6
			bulb.radius = 0.15 * size
			bulb.height = 0.3 * size
			add_child(AbilityModels.mesh_node(bulb, AbilityModels.mat(Color(1, 0.85, 0.5), 0.3, 1.5)))
			var l := OmniLight3D.new()
			l.light_color = Color(1, 0.82, 0.55)
			l.light_energy = 1.3
			l.omni_range = 7.0 * size
			add_child(l)
		"station":
			# Bip'in şarj istasyonu: taban, kablo, parlayan halka
			var base := CylinderMesh.new()
			base.radial_segments = 16
			base.rings = 1
			base.top_radius = 1.0
			base.bottom_radius = 1.15
			base.height = 0.3
			add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.35, 0.4, 0.5)), Vector3(0, 0.15, 0)))
			var ring := TorusMesh.new()
			ring.rings = 16
			ring.ring_segments = 8
			ring.inner_radius = 0.75
			ring.outer_radius = 0.9
			_part = AbilityModels.mesh_node(ring, AbilityModels.mat(Color(0.3, 0.9, 1.0), 0.3, 2.0), Vector3(0, 0.32, 0))
			add_child(_part)
			var pole := BoxMesh.new()
			pole.size = Vector3(0.3, 2.2, 0.3)
			add_child(AbilityModels.mesh_node(pole, AbilityModels.mat(Color(0.5, 0.55, 0.65)), Vector3(1.4, 1.1, 0)))
			var arm := BoxMesh.new()
			arm.size = Vector3(1.0, 0.2, 0.2)
			add_child(AbilityModels.mesh_node(arm, AbilityModels.mat(Color(0.5, 0.55, 0.65)), Vector3(0.95, 2.1, 0)))
		"screen":
			var frame := BoxMesh.new()
			frame.size = Vector3(1.6, 1.1, 0.25) * size
			add_child(AbilityModels.mesh_node(frame, AbilityModels.mat(Color(0.55, 0.4, 0.3))))
			var scr := BoxMesh.new()
			scr.size = Vector3(1.3, 0.85, 0.05) * size
			add_child(AbilityModels.mesh_node(scr, AbilityModels.mat(color, 0.2, 1.2), Vector3(0, 0, 0.13 * size)))
		"dark_tower":
			# Uzaktaki karanlık jeneratör kulesi (hikaye: yön işareti)
			add_to_group("vista_target")
			var t: Node3D = load("res://assets/models/quaternius/platformer/Tower.gltf").instantiate()
			t.scale = Vector3.ONE * size
			add_child(t)
			for m in t.find_children("*", "MeshInstance3D", true, false):
				var mi := m as MeshInstance3D
				for i in mi.mesh.get_surface_count():
					mi.set_surface_override_material(i, AbilityModels.mat(Color(0.22, 0.2, 0.32), 0.8))
			_part = Node3D.new()
			add_child(_part)
			var spark_m := AbilityModels.mat(Color(0.75, 0.4, 1.0), 0.3, 4.0)
			for i in 6:
				var s := SphereMesh.new()
				s.radial_segments = 12
				s.rings = 6
				s.radius = 0.35 * size
				s.height = 0.7 * size
				var a := TAU * i / 6.0
				_part.add_child(AbilityModels.mesh_node(s, spark_m, Vector3(cos(a) * 6.0, 13.0 + sin(a * 2) * 1.5, sin(a) * 6.0) * size))
		"rain":
			var r := CPUParticles3D.new()
			r.amount = 220
			r.lifetime = 0.9
			var line := BoxMesh.new()
			line.size = Vector3(0.02, 0.45, 0.02)
			r.mesh = line
			var rm := AbilityModels.mat(Color(0.7, 0.8, 1.0, 0.5), 0.3, 0.5)
			rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			r.material_override = rm
			r.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
			r.emission_box_extents = Vector3(12, 0.5, 6) * size
			r.direction = Vector3(0.1, -1, 0)
			r.spread = 2.0
			r.gravity = Vector3(0, -20, 0)
			r.initial_velocity_min = 12.0
			r.initial_velocity_max = 15.0
			add_child(r)
		"generator":
			# Ana Jeneratör: dört Çekirdek Pil yuvası (hikaye)
			var base := CylinderMesh.new()
			base.radial_segments = 16
			base.rings = 1
			base.top_radius = 2.2 * size
			base.bottom_radius = 2.8 * size
			base.height = 1.0 * size
			add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.45, 0.48, 0.58)), Vector3(0, 0.5, 0) * size))
			var col := CylinderMesh.new()
			col.radial_segments = 16
			col.rings = 1
			col.top_radius = 1.0 * size
			col.bottom_radius = 1.3 * size
			col.height = 5.0 * size
			add_child(AbilityModels.mesh_node(col, AbilityModels.mat(Color(0.55, 0.58, 0.68)), Vector3(0, 3.5, 0) * size))
			_part = Node3D.new()
			add_child(_part)
			for i in 4:
				var a := TAU * i / 4.0
				var cell := CylinderMesh.new()
				cell.radial_segments = 16
				cell.rings = 1
				cell.top_radius = 0.35 * size
				cell.bottom_radius = 0.35 * size
				cell.height = 1.1 * size
				var cm := AbilityModels.mat(color, 0.3, 3.0)
				var mi := AbilityModels.mesh_node(cell, cm, Vector3(cos(a) * 1.5, 3.2, sin(a) * 1.5) * size)
				mi.name = "Cell%d" % i
				_part.add_child(mi)
			var cap := SphereMesh.new()
			cap.radial_segments = 12
			cap.rings = 6
			cap.radius = 1.2 * size
			cap.height = 1.4 * size
			add_child(AbilityModels.mesh_node(cap, AbilityModels.mat(Color(0.95, 0.75, 0.25), 0.3, 0.6), Vector3(0, 6.2, 0) * size))
		"storm":
			# Statik: mor kıvılcımlı bulut (Quaternius Cloud, mora boyanmış)
			var c: Node3D = load("res://assets/models/quaternius/platformer/Cloud_2.gltf").instantiate()
			c.scale = Vector3.ONE * size
			add_child(c)
			for m in c.find_children("*", "MeshInstance3D", true, false):
				var mi := m as MeshInstance3D
				for i in mi.mesh.get_surface_count():
					mi.set_surface_override_material(i, AbilityModels.mat(Color(0.55, 0.35, 0.85), 0.6, 0.4))
			var p := CPUParticles3D.new()
			p.amount = 16
			p.lifetime = 0.6
			var q := SphereMesh.new()
			q.radial_segments = 12
			q.rings = 6
			q.radius = 0.08
			q.height = 0.16
			p.mesh = q
			p.material_override = AbilityModels.mat(Color(0.85, 0.6, 1.0), 0.3, 5.0)
			p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
			p.emission_sphere_radius = 2.0 * size
			p.gravity = Vector3(0, -6, 0)
			p.initial_velocity_min = 1.0
			p.initial_velocity_max = 3.0
			add_child(p)


func _process(delta: float) -> void:
	_t += delta
	if _part and spin != 0.0:
		_part.rotate_object_local(Vector3.UP, spin * delta)
	if kind == "storm":
		position.y += sin(_t * 0.8) * delta * 0.4
		rotation.z = sin(_t * 0.6) * 0.05
