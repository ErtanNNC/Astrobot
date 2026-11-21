class_name GhostRun
extends Node3D
## Hayalet yarışı: alanın rekor turu 0,1 saniyede bir konum olarak kaydedilir; alana yeniden girince saydam bir
## Bip o turu yanında koşar. Zaman ekseni alan süresidir (duraklatınca hayalet de durur).
## Kurallar: docs/features/geri-donme/design.md ("Hayalet")

const STEP := 0.1                 ## s, iki örnek arası
const MAX_SAMPLES := 9000         ## 15 dakika; daha uzun tur kaydedilmez

var samples := PackedFloat32Array()   # x, y, z, yaw, x, y, z, yaw...
var _body: Node3D


static func path_for(slot: int, area_id: String) -> String:
	return "user://ghost_%d_%s.bin" % [slot, area_id]


static func save_run(slot: int, area_id: String, data: PackedFloat32Array) -> bool:
	if data.size() < 8 or data.size() / 4 > MAX_SAMPLES:
		return false
	var f := FileAccess.open(path_for(slot, area_id), FileAccess.WRITE)
	if f == null:
		return false
	f.store_32(data.size())
	f.store_buffer(data.to_byte_array())
	f.close()
	return true


static func load_run(slot: int, area_id: String) -> PackedFloat32Array:
	var p := path_for(slot, area_id)
	if not FileAccess.file_exists(p):
		return PackedFloat32Array()
	var f := FileAccess.open(p, FileAccess.READ)
	if f == null:
		return PackedFloat32Array()
	var n := f.get_32()
	var out := f.get_buffer(n * 4).to_float32_array()
	f.close()
	return out if out.size() == n and n % 4 == 0 else PackedFloat32Array()


static func delete_slot(slot: int) -> void:
	var d := DirAccess.open("user://")
	if d == null:
		return
	for fn in d.get_files():
		if fn.begins_with("ghost_%d_" % slot):
			d.remove(fn)


## t anındaki konum ve yön (iki örnek arası doğrusal). Tur bittiyse son örnek.
static func sample_at(data: PackedFloat32Array, t: float) -> Array:
	var n := data.size() / 4
	if n == 0:
		return [Vector3.ZERO, 0.0]
	var f := clampf(t / STEP, 0.0, float(n - 1))
	var i := int(f)
	var j := mini(i + 1, n - 1)
	var k := f - i
	var a := Vector3(data[i * 4], data[i * 4 + 1], data[i * 4 + 2])
	var b := Vector3(data[j * 4], data[j * 4 + 1], data[j * 4 + 2])
	return [a.lerp(b, k), lerp_angle(data[i * 4 + 3], data[j * 4 + 3], k)]


static func duration(data: PackedFloat32Array) -> float:
	return maxf(data.size() / 4 - 1, 0) * STEP


func _ready() -> void:
	# Basit, saydam bir Bip silüeti: gövde, kafa, iki anten
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.55, 0.9, 1.0, 0.38)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_body = Node3D.new()
	add_child(_body)
	var cap := CapsuleMesh.new()
	cap.radius = 0.26
	cap.height = 0.75
	_body.add_child(AbilityModels.mesh_node(cap, m, Vector3(0, 0.42, 0)))
	var head := SphereMesh.new()
	head.radius = 0.3
	head.height = 0.52
	_body.add_child(AbilityModels.mesh_node(head, m, Vector3(0, 0.95, 0)))
	for s in [-1.0, 1.0]:
		var ant := CylinderMesh.new()
		ant.top_radius = 0.02
		ant.bottom_radius = 0.02
		ant.height = 0.4
		_body.add_child(AbilityModels.mesh_node(ant, m, Vector3(s * 0.14, 1.36, 0), Vector3(0, 0, -s * 0.3)))
	for mi in _body.get_children():
		(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Alan süresine göre hayaleti yerine koy; tur bitince söner.
func show_at(t: float) -> void:
	var r := sample_at(samples, t)
	global_position = r[0]
	rotation.y = r[1]
	visible = t <= duration(samples) + 0.5
	_body.position.y = sin(t * 9.0) * 0.03
