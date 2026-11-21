class_name Vista
extends Area3D
## Manzara anı: Bip ilk girdiğinde kamera bir an yön işaretine (fener, volkan, kale...) döner, adı ekrana gelir.

@export var size := Vector3(8, 4, 4)
@export var offset := Vector3(0, 10, -60)   ## bakılacak nokta (bu düğüme göre, dünya yönünde)
@export var title := ""
@export var seconds := 2.6

var _done := false


func _ready() -> void:
	add_to_group("setpiece")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	cs.shape = sh
	cs.position.y = size.y / 2.0
	add_child(cs)
	body_entered.connect(_on_body)


func _on_body(b: Node) -> void:
	if _done or not (b is Bip):
		return
	_done = true
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("look_toward"):
		cam.look_toward(global_position + offset, seconds)
	var sc := get_tree().current_scene
	if title != "" and sc and sc.get("hud"):
		sc.hud.banner(title, "", 2.0)
	Sfx.play("wake", -4.0, 0.8)
