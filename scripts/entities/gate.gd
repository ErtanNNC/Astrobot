extends AnimatableBody3D
## Kapı: buton ya da tetikleyiciyle açılır (aşağı iner), isteğe bağlı kapanır.

@export var size := Vector3(4, 4, 0.6)
@export var open_offset := Vector3(0, -4.2, 0)

var _closed_pos := Vector3.ZERO
var _tween: Tween


func _ready() -> void:
	_closed_pos = position
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	cs.position.y = size.y / 2
	add_child(cs)
	var mesh := BoxMesh.new()
	mesh.size = size
	add_child(AbilityModels.mesh_node(mesh, AbilityModels.mat(Color(0.95, 0.6, 0.2), 0.5), Vector3(0, size.y / 2, 0)))
	for i in 3:
		var bar := BoxMesh.new()
		bar.size = Vector3(size.x + 0.05, 0.2, size.z + 0.05)
		add_child(AbilityModels.mesh_node(bar, AbilityModels.mat(Color(0.25, 0.25, 0.3)), Vector3(0, size.y * (0.25 + i * 0.25), 0)))


func open() -> void:
	_move(_closed_pos + open_offset, 0.6)


func close() -> void:
	_move(_closed_pos, 0.8)


func _move(to: Vector3, t: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "position", to, t).set_trans(Tween.TRANS_QUAD)
