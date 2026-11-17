extends Area3D
## Su havuzu: Bip normalde yüzer; Kaya taşıyorsa dibe batar ve altta yürüyebilir.

@export var size := Vector3(8, 4, 8)   ## yüzey = üst kenar


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	cs.position.y = -size.y / 2
	add_child(cs)
	var plane := PlaneMesh.new()
	plane.size = Vector2(size.x, size.z)
	plane.subdivide_width = int(size.x)
	plane.subdivide_depth = int(size.z)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/water.gdshader")
	mat.set_shader_parameter("wave_height", 0.06)
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = mat
	add_child(mi)
	# Su içi hacmi (yarı saydam)
	var vol := BoxMesh.new()
	vol.size = Vector3(size.x - 0.02, size.y, size.z - 0.02)
	var vm := StandardMaterial3D.new()
	vm.albedo_color = Color(0.2, 0.55, 0.9, 0.35)
	vm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vm.cull_mode = BaseMaterial3D.CULL_DISABLED
	add_child(AbilityModels.mesh_node(vol, vm, Vector3(0, -size.y / 2 - 0.05, 0)))
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


func _on_enter(b: Node) -> void:
	if b is Bip:
		b.water_level = global_position.y


func _on_exit(b: Node) -> void:
	if b is Bip:
		b.water_level = -INF
