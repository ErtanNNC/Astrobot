extends Area3D
## Tehlike: dokununca hasar verir. Kırmızı/turuncu ve sivri (sanat yönü).
##  spikes – sivri diken sırası, saw – dönen testere (isteğe bağlı ileri geri gider)

@export_enum("spikes", "saw") var kind := "spikes"
@export var size := Vector2(2, 2)         ## m (diken alanı)
@export var move := Vector3.ZERO          ## testere gidip gelme mesafesi
@export var period := 3.0

var _start := Vector3.ZERO
var _t := 0.0
var _saw: Node3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	_start = position
	var cs := CollisionShape3D.new()
	if kind == "spikes":
		var b := BoxShape3D.new()
		b.size = Vector3(size.x - 0.2, 0.6, size.y - 0.2)
		cs.shape = b
		cs.position.y = 0.3
		var model: PackedScene = load("res://assets/models/quaternius/platformer/Hazard_SpikeTrap.gltf")
		for ix in int(maxf(1, round(size.x / 2.0))):
			for iz in int(maxf(1, round(size.y / 2.0))):
				var m: Node3D = model.instantiate()
				var nx := maxf(1, round(size.x / 2.0))
				var nz := maxf(1, round(size.y / 2.0))
				m.scale = Vector3(size.x / nx / 2.0, 1.0, size.y / nz / 2.0)
				m.position = Vector3((ix + 0.5) * size.x / nx - size.x / 2, 0, (iz + 0.5) * size.y / nz - size.y / 2)
				add_child(m)
	else:
		var s := SphereShape3D.new()
		s.radius = 0.75
		cs.shape = s
		cs.position.y = 0.75
		_saw = load("res://assets/models/quaternius/platformer/Hazard_Saw.gltf").instantiate()
		_saw.scale = Vector3.ONE * 0.55
		_saw.position.y = 0.75
		add_child(_saw)
	add_child(cs)
	body_entered.connect(_on_body)


func _physics_process(delta: float) -> void:
	_t += delta
	if _saw:
		_saw.rotation.z += delta * 8.0
	if move != Vector3.ZERO:
		position = _start + move * (0.5 - 0.5 * cos(_t / period * TAU))
	for b in get_overlapping_bodies():
		if b is Bip:
			b.take_hit(global_position)


func _on_body(b: Node) -> void:
	if b is Bip:
		b.take_hit(global_position)
