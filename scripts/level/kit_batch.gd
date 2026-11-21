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
		var theme := ""
		var file: String = p
		if "#" in p:
			theme = p.get_slice("#", 1)
			file = p.get_slice("#", 0)
		for part in _parts(file):
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = part[0]
			var list: Array = groups[p]
			mm.instance_count = list.size()
			for k in list.size():
				mm.set_instance_transform(k, (list[k] as Transform3D) * (part[1] as Transform3D))
			var mmi := MultiMeshInstance3D.new()
			mmi.multimesh = mm
			mmi.material_override = _top_material(theme) if TOPS.has(theme) else _matte(part[0], file)
			if TOPS.has(theme):
				mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF   # gölgeyi alttaki gövde düşürür
			add_child(mmi)


static func _parts(path: String) -> Array:
	if _mesh_cache.has(path):
		return _mesh_cache[path]
	var out := []
	if path == "cap":
		# Doğal zemin örtüsü: 1 m'lik birim kutu, zemin boyuna ölçeklenir (kit_top gölgelendiricisi)
		var bm := BoxMesh.new()
		bm.size = Vector3.ONE
		_mesh_cache[path] = [[bm, Transform3D.IDENTITY]]
		return _mesh_cache[path]
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

## Doğal zemin temaları: [üst doku, renk A, renk B, saçak rengi, saçak derinliği (m), dalga 0..1, doku karışımı, doku boyu (m)]
## Oyuncak renkli bloklar (sarı, kırmızı, mavi, yeşil) burada yok: KayKit karosu olarak kalır.
const TEX := "res://assets/textures/freegameassets/painterly/"
const TOPS := {
	"grass": ["lush-meadow-grass", Color(0.40, 0.76, 0.24), Color(0.58, 0.86, 0.30), Color(0.33, 0.66, 0.21), 0.36, 1.0, 0.22, 4.0],
	"grass2": ["lush-meadow-grass", Color(0.50, 0.80, 0.26), Color(0.68, 0.88, 0.34), Color(0.40, 0.70, 0.22), 0.36, 1.0, 0.22, 4.0],
	"sand": ["fine-beach-sand", Color(0.96, 0.84, 0.56), Color(1.0, 0.91, 0.68), Color(0.90, 0.76, 0.48), 0.2, 0.6, 0.3, 4.0],
	"canyon": ["red-desert-dust", Color(0.93, 0.60, 0.38), Color(0.99, 0.72, 0.46), Color(0.84, 0.48, 0.30), 0.22, 0.6, 0.3, 4.0],
	"quarry": ["brown-crushed-rock", Color(0.92, 0.82, 0.62), Color(1.0, 0.90, 0.70), Color(0.78, 0.68, 0.52), 0.2, 0.5, 0.12, 4.0],
	"stone": ["cracked-stone-ground", Color(0.82, 0.85, 0.92), Color(0.94, 0.95, 1.0), Color(0.66, 0.69, 0.76), 0.14, 0.0, 0.15, 4.0],
	"castle": ["cracked-stone-ground", Color(0.90, 0.88, 0.86), Color(1.0, 0.97, 0.92), Color(0.70, 0.69, 0.72), 0.14, 0.0, 0.15, 4.0],
	"factory": ["rivet-metal", Color(0.80, 0.84, 0.92), Color(0.90, 0.93, 1.0), Color(0.95, 0.78, 0.25), 0.12, 0.0, 0.1, 2.0],
	"snow": ["powder-snow", Color(0.93, 0.96, 1.0), Color(1.0, 1.0, 1.0), Color(0.90, 0.94, 1.0), 0.42, 1.0, 0.25, 5.0],
	"ice": ["blue-ice-cracks", Color(0.66, 0.88, 1.0), Color(0.80, 0.94, 1.0), Color(0.56, 0.80, 0.98), 0.16, 0.3, 0.45, 5.0],
	"cloud": ["powder-snow", Color(0.97, 0.96, 1.0), Color(0.90, 0.88, 0.99), Color(0.95, 0.94, 1.0), 0.5, 1.0, 0.08, 7.0],
}
const TOP_SHADER := preload("res://assets/shaders/kit_top.gdshader")
static var _top_cache := {}


static var _lum_cache := {}


## Dokunun ortalama parlaklığı (küçültülmüş kopyadan, bir kez): koyu doku zemini karartmasın diye.
static func _avg_lum(key: String, tex: Texture2D) -> float:
	if _lum_cache.has(key):
		return _lum_cache[key]
	var v := 0.5
	var img := tex.get_image()
	if img:
		if img.is_compressed():
			img.decompress()
		img.resize(8, 8, Image.INTERPOLATE_BILINEAR)
		var sum := 0.0
		for y in 8:
			for x in 8:
				var c := img.get_pixel(x, y)
				sum += c.r * 0.3 + c.g * 0.55 + c.b * 0.15
		v = sum / 64.0
	_lum_cache[key] = v
	return v


static func _top_material(theme: String) -> ShaderMaterial:
	if _top_cache.has(theme):
		return _top_cache[theme]
	var t: Array = TOPS[theme]
	var m := ShaderMaterial.new()
	m.shader = TOP_SHADER
	var tex: Texture2D = load(TEX + t[0] + ".png")
	m.set_shader_parameter("top_tex", tex)
	m.set_shader_parameter("avg_lum", _avg_lum(t[0], tex))
	m.set_shader_parameter("tint_a", t[1])
	m.set_shader_parameter("tint_b", t[2])
	m.set_shader_parameter("fringe", t[3])
	m.set_shader_parameter("fringe_depth", t[4])
	m.set_shader_parameter("fringe_wave", t[5])
	m.set_shader_parameter("tex_mix", t[6])
	m.set_shader_parameter("tex_size", t[7])
	_top_cache[theme] = m
	return m


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
