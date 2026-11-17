class_name AbilityModels
extends RefCounted
## Yeteneklerin görünüşü: kopyalanabilir nesneler, Bip'in üstündeki simge ve HUD rengi.

const COLORS := {
	"yay": Color(0.45, 0.9, 0.35),
	"balon": Color(1.0, 0.4, 0.55),
	"miknatis": Color(0.95, 0.25, 0.25),
	"kaya": Color(0.62, 0.56, 0.5),
}

const NAMES := {"yay": "Yay", "balon": "Balon", "miknatis": "Mıknatıs", "kaya": "Kaya"}

const BOUNCER := "res://assets/models/quaternius/platformer/Bouncer.gltf"
const ROCK := "res://assets/models/quaternius/platformer/Rock_1.gltf"


static func color(a: String) -> Color:
	return COLORS.get(a, Color(1, 0.6, 0.2))


static func mat(c: Color, rough := 0.35, emit := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	return m


static func mesh_node(mesh: Mesh, m: Material, pos := Vector3.ZERO, rot := Vector3.ZERO, scl := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	mi.position = pos
	mi.rotation = rot
	mi.scale = scl
	return mi


## Kopyalanabilir nesnenin büyük modeli (yaklaşık 1–1,4 m).
static func make_source(a: String) -> Node3D:
	var root := Node3D.new()
	match a:
		"yay":
			var b: Node3D = load(BOUNCER).instantiate()
			b.scale = Vector3.ONE * 0.55
			root.add_child(b)
		"balon":
			_balloon(root, 1.0)
		"miknatis":
			_magnet(root, 1.0)
			root.get_child(0).position.y = 0.55
		"kaya":
			var r: Node3D = load(ROCK).instantiate()
			r.scale = Vector3.ONE * 0.75
			r.position.y = 0.14
			root.add_child(r)
	return root


## Bip'in kafasının üstündeki küçük simge.
static func make_icon(a: String) -> Node3D:
	var root := Node3D.new()
	match a:
		"yay":
			var m := mat(color("yay"), 0.3)
			for i in 4:
				var t := TorusMesh.new()
				t.inner_radius = 0.07
				t.outer_radius = 0.11
				t.rings = 12
				t.ring_segments = 6
				root.add_child(mesh_node(t, m, Vector3(0, i * 0.055, 0)))
			var cap := CylinderMesh.new()
			cap.top_radius = 0.12
			cap.bottom_radius = 0.12
			cap.height = 0.04
			root.add_child(mesh_node(cap, mat(Color(0.9, 0.2, 0.2)), Vector3(0, 0.24, 0)))
		"balon":
			_balloon(root, 0.35)
		"miknatis":
			_magnet(root, 0.3)
		"kaya":
			var r: Node3D = load(ROCK).instantiate()
			r.scale = Vector3.ONE * 0.16
			root.add_child(r)
	return root


static func _balloon(root: Node3D, s: float) -> void:
	var sph := SphereMesh.new()
	sph.radius = 0.4 * s
	sph.height = 0.8 * s
	var m := mat(color("balon"), 0.15)
	m.metallic_specular = 0.8
	root.add_child(mesh_node(sph, m, Vector3(0, 1.0 * s, 0), Vector3.ZERO, Vector3(1, 1.15, 1)))
	var knot := CylinderMesh.new()
	knot.top_radius = 0.02 * s
	knot.bottom_radius = 0.07 * s
	knot.height = 0.1 * s
	root.add_child(mesh_node(knot, m, Vector3(0, 0.5 * s, 0)))
	var rope := CylinderMesh.new()
	rope.top_radius = 0.008 * s + 0.004
	rope.bottom_radius = rope.top_radius
	rope.height = 0.5 * s
	root.add_child(mesh_node(rope, mat(Color(0.95, 0.95, 0.95)), Vector3(0, 0.22 * s, 0)))


static func _magnet(root: Node3D, s: float) -> void:
	var pivot := Node3D.new()
	root.add_child(pivot)
	var red := mat(color("miknatis"), 0.3)
	var steel := mat(Color(0.85, 0.87, 0.92), 0.2)
	steel.metallic = 0.8
	var arm := BoxMesh.new()
	arm.size = Vector3(0.26, 0.7, 0.3) * s
	var tip := BoxMesh.new()
	tip.size = Vector3(0.27, 0.18, 0.31) * s
	var base := TorusMesh.new()
	base.inner_radius = 0.2 * s
	base.outer_radius = 0.46 * s
	for side in [-1, 1]:
		pivot.add_child(mesh_node(arm, red, Vector3(side * 0.33 * s, 0.05 * s, 0)))
		pivot.add_child(mesh_node(tip, steel, Vector3(side * 0.33 * s, 0.45 * s, 0)))
	# Alt kavis: yarım torus yerine üç kutu
	var bot := BoxMesh.new()
	bot.size = Vector3(0.92, 0.26, 0.3) * s
	pivot.add_child(mesh_node(bot, red, Vector3(0, -0.3 * s, 0)))
	pivot.rotation.z = PI  # U şekli yukarı bakan uçlarla
	pivot.position.y = 0.3 * s
