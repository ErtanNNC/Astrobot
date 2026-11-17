extends Area3D
## Tetikleyici: Bip girince alan yöneticisinde (ya da hedef düğümde) bir fonksiyonu bir kez çağırır.

@export var size := Vector3(4, 4, 4)
@export var method_name := ""   ## çağrılacak fonksiyon adı (alan yöneticisinde)
@export var arg := ""
@export var once := true

var _done := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	cs.position.y = size.y / 2
	add_child(cs)
	body_entered.connect(_on_body)


func _on_body(b: Node) -> void:
	if not (b is Bip) or (_done and once):
		return
	_done = true
	var lvl := get_tree().current_scene
	if lvl and lvl.has_method(method_name):
		if arg != "":
			lvl.call(method_name, arg)
		else:
			lvl.call(method_name)
