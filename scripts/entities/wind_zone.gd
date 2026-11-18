extends Area3D
## Rüzgâr akımı: içindeki Bip'i iter. Balon ile süzülen Bip yukarı taşınır; Kaya etkilenmez.
## Pervane gibi ritimle açılıp kapanabilir (Balon Kanyonu ustalık bölümü).

@export var size := Vector3(3, 8, 3)
@export var force := Vector3(0, 14, 0)     ## m/s²
@export var cycle := 0.0                   ## s; 0 = hep açık
@export var offset := 0.0

var _particles: CPUParticles3D
var _t := 0.0
var on := true


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	cs.position.y = size.y / 2
	add_child(cs)
	_particles = CPUParticles3D.new()
	_particles.amount = int(clampf(size.x * size.z * 3, 12, 60))
	_particles.lifetime = size.y / maxf(force.length() * 0.5, 1.0)
	var q := BoxMesh.new()
	q.size = Vector3(0.04, 0.5, 0.04)
	_particles.mesh = q
	var m := AbilityModels.mat(Color(1, 1, 1, 0.5), 1.0, 0.8)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_particles.material_override = m
	_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_particles.emission_box_extents = Vector3(size.x / 2, 0.2, size.z / 2)
	_particles.direction = force.normalized()
	_particles.spread = 3.0
	_particles.gravity = Vector3.ZERO
	_particles.initial_velocity_min = force.length() * 0.5
	_particles.initial_velocity_max = force.length() * 0.6
	add_child(_particles)
	# Pervane tabanı
	var fan := CylinderMesh.new()
	fan.radial_segments = 16
	fan.rings = 1
	fan.top_radius = minf(size.x, size.z) * 0.45
	fan.bottom_radius = fan.top_radius
	fan.height = 0.15
	add_child(AbilityModels.mesh_node(fan, AbilityModels.mat(Color(0.7, 0.75, 0.85), 0.3), Vector3(0, 0.08, 0)))


func _physics_process(delta: float) -> void:
	_t += delta
	if cycle > 0.0:
		on = fmod(_t + offset, cycle) < cycle * 0.5
		_particles.emitting = on
	if not on:
		return
	for b in get_overlapping_bodies():
		if b is Bip:
			b.wind += global_basis * force
