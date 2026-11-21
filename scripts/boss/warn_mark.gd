class_name WarnMark
extends Node3D
## Patron saldırısı uyarı işareti: yerde halka + içinde büyüyen disk. Disk halkayı doldurduğu an darbe iner;
## oyuncu "nereye" ile birlikte "ne zaman"ı da görür. Son üçte birde halka hızlı yanıp söner.
## Kullanım: add_child(WarnMark.make(renk, yarıçap, süre))

var radius := 1.0
var time := 1.0
var color := Color(1, 0.25, 0.15)

var _t := 0.0
var _ring: MeshInstance3D
var _disc: MeshInstance3D
var _disc_mat: StandardMaterial3D


static func make(c: Color, r: float, seconds: float) -> WarnMark:
	var w := WarnMark.new()
	w.color = c
	w.radius = r
	w.time = seconds
	return w


func _ready() -> void:
	var t := TorusMesh.new()
	t.rings = 20
	t.ring_segments = 6
	t.inner_radius = radius * 0.9
	t.outer_radius = radius * 1.1
	_ring = AbilityModels.mesh_node(t, AbilityModels.mat(color, 0.4, 2.2), Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1, 0.2, 1))
	add_child(_ring)
	var c := CylinderMesh.new()
	c.top_radius = radius * 0.9
	c.bottom_radius = radius * 0.9
	c.height = 0.02
	c.radial_segments = 20
	c.rings = 1
	_disc_mat = StandardMaterial3D.new()
	_disc_mat.albedo_color = Color(color.r, color.g, color.b, 0.45)
	_disc_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_disc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_disc = AbilityModels.mesh_node(c, _disc_mat, Vector3(0, 0.04, 0))
	_disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_disc.scale = Vector3(0.05, 1, 0.05)
	add_child(_disc)
	Sfx.play("charge", -10.0, 1.5)


func _physics_process(delta: float) -> void:
	_t += delta
	var k := clampf(_t / time, 0.0, 1.0)
	_disc.scale = Vector3(maxf(k, 0.05), 1, maxf(k, 0.05))
	var late := k > 0.66
	var pulse := 1.0 + (0.12 if late else 0.06) * sin(_t * (34.0 if late else 16.0))
	_ring.scale = Vector3(pulse, 0.2, pulse)
	_disc_mat.albedo_color.a = 0.45 + (0.3 * absf(sin(_t * 34.0)) if late else 0.0)


## Darbe indi: işaret söner.
func finish() -> void:
	set_physics_process(false)
	visible = false
