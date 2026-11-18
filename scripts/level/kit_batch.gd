extends Node3D
## KayKit parçalarını (CC0, Kay Lousberg) tek tek düğüm yerine MultiMesh ile çizer:
## yüzlerce zemin karosu telefonda tek çizim çağrısına iner. Çarpışma yok (görsel);
## zeminin çarpışması alttaki ölçülü kutuda kalır. Üretici: tools/level/lvl.py (kit_*).

@export var items: Array = []   ## [model yolu, Transform3D, model yolu, Transform3D, ...]

static var _mesh_cache := {}    ## yol → [[Mesh, Transform3D], ...]


func _ready() -> void:
	var groups := {}
	for i in range(0, items.size() - 1, 2):
		var p: String = items[i]
		if not groups.has(p):
			groups[p] = []
		groups[p].append(items[i + 1])
	for p in groups:
		for part in _parts(p):
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = part[0]
			var list: Array = groups[p]
			mm.instance_count = list.size()
			for k in list.size():
				mm.set_instance_transform(k, (list[k] as Transform3D) * (part[1] as Transform3D))
			var mmi := MultiMeshInstance3D.new()
			mmi.multimesh = mm
			mmi.material_override = _matte(part[0], p)
			add_child(mmi)


static func _parts(path: String) -> Array:
	if _mesh_cache.has(path):
		return _mesh_cache[path]
	var out := []
	var ps := load(path) as PackedScene
	if ps:
		var inst := ps.instantiate()
		_collect(inst, Transform3D.IDENTITY, out, true)
		inst.free()
	_mesh_cache[path] = out
	return out


static func _collect(n: Node, xf: Transform3D, out: Array, is_root: bool) -> void:
	var here := xf
	if n is Node3D and not is_root:
		here = xf * (n as Node3D).transform
	if n is MeshInstance3D and (n as MeshInstance3D).mesh:
		out.append([(n as MeshInstance3D).mesh, here])
	for c in n.get_children():
		_collect(c, here, out, false)



static var _mat_cache := {}


## KayKit malzemesi çok parlak (pürüzlülük 0,3): gökyüzünü yansıtıp rengi soldurur. Mat sürüm.
static func _matte(mesh: Mesh, path := "") -> Material:
	if mesh.get_surface_count() == 0:
		return null
	var m := mesh.surface_get_material(0)
	if m == null:
		return null
	var tint := Color(1.12, 1.12, 1.1)
	if "_green" in path:
		tint = Color(1.12, 1.22, 0.8)   # KayKit yeşili turkuaza kaçıyor: çimen yeşiline ısıt
	var key := str(m.get_instance_id()) + str(tint)
	if not _mat_cache.has(key):
		var d := m.duplicate() as BaseMaterial3D
		if d:
			d.roughness = 0.85
			d.metallic_specular = 0.25
			d.albedo_color = tint
		_mat_cache[key] = d
	return _mat_cache[key]
