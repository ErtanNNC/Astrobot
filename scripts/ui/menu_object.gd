extends Area3D
## Atölye'deki menü nesnesi: Bip önüne gelince parlar, üstünde ne yaptığını gösteren simge çıkar;
## Yetenek tuşu (ya da telefonda nesneye dokunmak) seçer. Bkz. docs/features/ana-menu/design.md

@export_enum("door", "capsule", "tv", "showcase", "toybox", "switch") var kind := "door"
@export var action := "play"
@export var arg := ""

var near := false
var _icon: Node3D
var _glow: OmniLight3D
var _t := 0.0
var _holo: Label3D


func _ready() -> void:
	add_to_group("menu_object")
	collision_layer = 8          # dokunma ışını için ayrı katman
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(3.2, 3.5, 3.2)
	cs.shape = sh
	cs.position.y = 1.5
	add_child(cs)
	_build()
	_glow = OmniLight3D.new()
	_glow.light_color = Color(1, 0.85, 0.4)
	_glow.light_energy = 0.0
	_glow.omni_range = 4.0
	_glow.position.y = 2.0
	add_child(_glow)
	body_entered.connect(_on_body.bind(true))
	body_exited.connect(_on_body.bind(false))


func _on_body(b: Node, v: bool) -> void:
	if b is Bip:
		near = v


func _build() -> void:
	var body := StaticBody3D.new()
	add_child(body)
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	shape.shape = bs
	body.add_child(shape)
	var icon_y := 2.6
	match kind:
		"door":
			# KayKit Restaurant door_A (CC0): menteşesi yerel x=0'da, 1,6 m genişlik; duvardaki kapı boşluğuna oturur
			var d: Node3D = load("res://assets/models/kaykit/restaurant/door_A.gltf").instantiate()
			d.position = Vector3(-0.8, 0, 0)
			add_child(d)
			bs.size = Vector3(1.8, 2.9, 0.6)
			shape.position.y = 1.45
			icon_y = 3.4
		"capsule":
			var glass := CylinderMesh.new()
			glass.radial_segments = 16
			glass.rings = 1
			glass.top_radius = 0.75
			glass.bottom_radius = 0.75
			glass.height = 2.2
			var gm := AbilityModels.mat(Color(0.5, 0.85, 1.0, 0.3), 0.1, 0.4)
			gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			add_child(AbilityModels.mesh_node(glass, gm, Vector3(0, 1.4, 0)))
			var base := CylinderMesh.new()
			base.radial_segments = 16
			base.rings = 1
			base.top_radius = 0.9
			base.bottom_radius = 1.0
			base.height = 0.3
			add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.35, 0.4, 0.5)), Vector3(0, 0.15, 0)))
			add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.35, 0.4, 0.5)), Vector3(0, 2.6, 0)))
			bs.size = Vector3(1.8, 2.8, 1.8)
			shape.position.y = 1.4
			_holo = Label3D.new()
			_holo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			_holo.font_size = 48
			_holo.outline_size = 12
			_holo.modulate = Color(0.6, 0.95, 1.0)
			_holo.position.y = 1.4
			add_child(_holo)
			icon_y = 3.3
		"tv":
			# Eski tüplü TV: KayKit küçük masa üstünde koyu çerçeveli, parlayan ekran
			var stand: Node3D = load("res://assets/models/kaykit/furniture/table_small.gltf").instantiate()
			stand.scale = Vector3(1.6, 0.9, 1.2)
			add_child(stand)
			var box := BoxMesh.new()
			box.size = Vector3(1.9, 1.35, 0.9)
			add_child(AbilityModels.mesh_node(box, AbilityModels.mat(Color(0.28, 0.3, 0.38), 0.5), Vector3(0, 1.6, 0)))
			var bezel := BoxMesh.new()
			bezel.size = Vector3(1.75, 1.2, 0.06)
			add_child(AbilityModels.mesh_node(bezel, AbilityModels.mat(Color(0.95, 0.75, 0.3), 0.5), Vector3(0, 1.6, 0.45)))
			var scr := BoxMesh.new()
			scr.size = Vector3(1.5, 0.95, 0.05)
			add_child(AbilityModels.mesh_node(scr, AbilityModels.mat(Color(0.35, 0.8, 0.9), 0.2, 1.2), Vector3(0, 1.6, 0.48)))
			for k in 2:
				var ant := BoxMesh.new()
				ant.size = Vector3(0.05, 0.8, 0.05)
				add_child(AbilityModels.mesh_node(ant, AbilityModels.mat(Color(0.5, 0.52, 0.6)), Vector3(-0.25 + k * 0.5, 2.6, 0), Vector3(0, 0, 0.5 - k)))
			bs.size = Vector3(2.0, 2.3, 1.0)
			shape.position.y = 1.15
		"showcase":
			var cab := BoxMesh.new()
			cab.size = Vector3(2.4, 2.2, 1.0)
			var cm := AbilityModels.mat(Color(0.75, 0.9, 1.0, 0.25), 0.1)
			cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			add_child(AbilityModels.mesh_node(cab, cm, Vector3(0, 1.1, 0)))
			var shelf := BoxMesh.new()
			shelf.size = Vector3(2.3, 0.08, 0.9)
			for y in [0.1, 0.8, 1.5]:
				add_child(AbilityModels.mesh_node(shelf, AbilityModels.mat(Color(0.6, 0.45, 0.3)), Vector3(0, y, 0)))
			bs.size = Vector3(2.4, 2.2, 1.0)
			shape.position.y = 1.1
			_holo = Label3D.new()
			_holo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			_holo.font_size = 40
			_holo.outline_size = 10
			_holo.position.y = 2.6
			add_child(_holo)
		"toybox":
			# KayKit kasa (CC0), kapağı yana açık: içinden oyuncaklar görünür
			var crate: Node3D = load("res://assets/models/kaykit/restaurant/crate.gltf").instantiate()
			crate.scale = Vector3(0.9, 1.1, 0.6)
			add_child(crate)
			var lid: Node3D = load("res://assets/models/kaykit/restaurant/crate_lid.gltf").instantiate()
			lid.scale = Vector3(0.9, 1.0, 0.6)
			lid.position = Vector3(0, 0.95, -0.75)
			lid.rotation.x = -1.1
			add_child(lid)
			for k in 3:
				var ball := SphereMesh.new()
				ball.radius = 0.18
				ball.height = 0.36
				var c: Color = [Color(1, 0.4, 0.35), Color(0.35, 0.7, 1), Color(1, 0.85, 0.3)][k]
				add_child(AbilityModels.mesh_node(ball, AbilityModels.mat(c, 0.4), Vector3(-0.45 + k * 0.45, 0.88, 0.05 * k)))
			bs.size = Vector3(1.8, 0.9, 1.2)
			shape.position.y = 0.45
			icon_y = 1.8
		"switch":
			var l: Node3D = load("res://assets/models/quaternius/platformer/Lever.gltf").instantiate()
			l.scale = Vector3.ONE
			add_child(l)
			bs.size = Vector3(1.2, 1.3, 0.6)
			shape.position.y = 0.65
			icon_y = 2.0
	_icon = _make_icon()
	_icon.position.y = icon_y
	_icon.visible = false
	add_child(_icon)


func icon_world_position() -> Vector3:
	return _icon.global_position


func set_hologram(text: String) -> void:
	if _holo:
		_holo.text = text


func _make_icon() -> Node3D:
	var root := Node3D.new()
	var disc := CylinderMesh.new()
	disc.radial_segments = 16
	disc.rings = 1
	disc.top_radius = 0.38
	disc.bottom_radius = 0.38
	disc.height = 0.06
	var col := Color(1.0, 0.75, 0.2)
	root.add_child(AbilityModels.mesh_node(disc, AbilityModels.mat(col, 0.4, 1.0), Vector3.ZERO, Vector3(PI / 2, 0, 0)))
	var w := AbilityModels.mat(Color.WHITE, 0.4, 1.5)
	match action:
		"play":
			var tri := PrismMesh.new()
			tri.size = Vector3(0.36, 0.34, 0.06)
			root.add_child(AbilityModels.mesh_node(tri, w, Vector3(0.03, 0, 0.05), Vector3(0, 0, -PI / 2)))
		"settings":
			var g := TorusMesh.new()
			g.rings = 16
			g.ring_segments = 8
			g.inner_radius = 0.09
			g.outer_radius = 0.2
			root.add_child(AbilityModels.mesh_node(g, w, Vector3(0, 0, 0.05), Vector3(PI / 2, 0, 0)))
		"slot":
			var l := Label3D.new()
			l.text = str(int(arg) + 1)
			l.font_size = 64
			l.outline_size = 0
			l.position.z = 0.05
			root.add_child(l)
		_:
			var s := SphereMesh.new()
			s.radial_segments = 12
			s.rings = 6
			s.radius = 0.14
			s.height = 0.28
			root.add_child(AbilityModels.mesh_node(s, w, Vector3(0, 0, 0.05)))
	return root


func _process(delta: float) -> void:
	_t += delta
	_icon.visible = near
	_glow.light_energy = lerpf(_glow.light_energy, 1.6 if near else 0.0, 6.0 * delta)
	if near:
		_icon.position.y += sin(_t * 4.0) * delta * 0.3
		var cam := get_viewport().get_camera_3d()
		if cam:
			_icon.look_at(cam.global_position, Vector3.UP)
			_icon.rotate_object_local(Vector3.UP, PI)
