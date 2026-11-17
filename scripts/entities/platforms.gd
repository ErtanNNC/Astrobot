extends AnimatableBody3D
## Hareketli platformların hepsi:
##  move     – iki nokta arasında gidip gelir
##  fall     – üstüne basılınca sallanır ve düşer, sonra geri gelir (kaybolan platform)
##  spin     – kendi ekseninde döner (dönen çark / dönen yay kulesi)
##  conveyor – yerinde durur, üstündekini taşır (konveyör bant)

@export_enum("move", "fall", "spin", "conveyor") var kind := "move"
@export var size := Vector3(3, 0.5, 3)
@export var offset := Vector3(0, 0, -6)     ## move: gidilecek yer
@export var duration := 2.5                 ## move: tek yön süresi, spin: bir tur
@export var belt_speed := 3.0               ## conveyor: m/s (yerel -Z yönünde)
@export var color := Color(0.8, 0.55, 0.32)
@export var metal := false                  ## Mıknatıs yapışabilir mi

var _start := Vector3.ZERO
var _t := 0.0
var _fall_state := 0   # 0 bekliyor, 1 sallanıyor, 2 düştü
var _fall_t := 0.0
var _mesh: MeshInstance3D
var _belt_mat: StandardMaterial3D


func _ready() -> void:
	_start = position
	sync_to_physics = kind != "fall"
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	add_child(cs)
	var mesh := BoxMesh.new()
	mesh.size = size
	var m := AbilityModels.mat(color, 0.5)
	if metal:
		m = AbilityModels.mat(Color(0.62, 0.68, 0.78), 0.35)
		m.metallic = 0.7
		add_to_group("metal")
	_mesh = AbilityModels.mesh_node(mesh, m)
	add_child(_mesh)
	if kind == "conveyor":
		_belt_mat = StandardMaterial3D.new()
		_belt_mat.albedo_color = Color(0.25, 0.27, 0.32)
		_belt_mat.albedo_texture = _stripe_texture()
		_belt_mat.uv1_scale = Vector3(1, size.z, 1)
		_belt_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		var top := PlaneMesh.new()
		top.size = Vector2(size.x - 0.1, size.z)
		add_child(AbilityModels.mesh_node(top, _belt_mat, Vector3(0, size.y / 2 + 0.01, 0)))
		constant_linear_velocity = global_basis * Vector3(0, 0, -belt_speed)
	if kind == "fall":
		var edge := BoxMesh.new()
		edge.size = Vector3(size.x + 0.04, 0.08, size.z + 0.04)
		_mesh.add_child(AbilityModels.mesh_node(edge, AbilityModels.mat(Color(0.95, 0.85, 0.3), 0.4, 0.3), Vector3(0, size.y / 2 - 0.02, 0)))


static func _stripe_texture() -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, Color(0.95, 0.75, 0.2))
	g.set_color(1, Color(0.2, 0.2, 0.25))
	g.set_offset(1, 0.5)
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0, 0)
	t.fill_to = Vector2(0, 1)
	t.width = 8
	t.height = 32
	return t


func closest_point(p: Vector3) -> Vector3:
	var local := to_local(p)
	var h := size * 0.5
	return to_global(Vector3(clampf(local.x, -h.x, h.x), clampf(local.y, -h.y, h.y), clampf(local.z, -h.z, h.z)))


func surface_normal(p: Vector3) -> Vector3:
	var local := to_local(p)
	var h := size * 0.5
	var d := Vector3(absf(absf(local.x) - h.x), absf(absf(local.y) - h.y), absf(absf(local.z) - h.z))
	if d.x <= d.y and d.x <= d.z:
		return (global_basis * Vector3(signf(local.x), 0, 0)).normalized()
	if d.y <= d.z:
		return (global_basis * Vector3(0, signf(local.y), 0)).normalized()
	return (global_basis * Vector3(0, 0, signf(local.z))).normalized()


func _physics_process(delta: float) -> void:
	_t += delta
	match kind:
		"move":
			var phase := (1.0 - cos(_t / duration * PI)) * 0.5
			position = _start + offset * phase
		"spin":
			rotation.y += TAU / duration * delta
		"conveyor":
			_belt_mat.uv1_offset.y -= belt_speed * delta / 1.0
		"fall":
			_process_fall(delta)


func _process_fall(delta: float) -> void:
	match _fall_state:
		0:
			for i in 1:
				var bip := get_tree().get_first_node_in_group("player") as Bip
				if bip and bip.is_on_floor() and bip.get_last_slide_collision() and bip.get_last_slide_collision().get_collider() == self:
					_fall_state = 1
					_fall_t = 0.0
		1:
			_fall_t += delta
			_mesh.position = Vector3(randf_range(-0.05, 0.05), 0, randf_range(-0.05, 0.05))
			if _fall_t > 0.6:
				_fall_state = 2
				_fall_t = 0.0
				Sfx.play("drop", -6.0)
		2:
			_fall_t += delta
			position.y -= delta * (4.0 + _fall_t * 15.0)
			if _fall_t > 2.5:
				position = _start
				_mesh.position = Vector3.ZERO
				_fall_state = 0
				_mesh.scale = Vector3.ZERO
				create_tween().tween_property(_mesh, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK)
