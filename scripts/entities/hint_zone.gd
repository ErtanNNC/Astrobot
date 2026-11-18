extends Area3D
## İpucu alanı: Bip bu alanda 4 sn boyunca beklenen şeyi yapmazsa Pırıl'ın üstünde
## ilgili tuş simgesi belirir (D-005, Bölüm 1 öğretici).
##  jump – zıplama, ability – yetenek/kopyalama, hold_jump – basılı tut zıpla, look – kamera

@export_enum("jump", "ability", "hold_jump", "look", "move") var hint := "jump"
@export var size := Vector3(4, 3, 4)
@export var delay := 4.0

var _time := 0.0
var _inside := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = size
	cs.shape = b
	cs.position.y = size.y / 2
	add_child(cs)
	body_entered.connect(_set_inside.bind(true))
	body_exited.connect(_set_inside.bind(false))


func _set_inside(b: Node, v: bool) -> void:
	if b is Bip and is_inside_tree():
		_inside = v
		_time = 0.0
		if not v:
			_piril_hint("")


func _process(delta: float) -> void:
	if not _inside or not Settings.get("hints_on"):
		return
	var acted := false
	match hint:
		"jump", "hold_jump":
			acted = Input.is_action_pressed("jump")
		"ability":
			acted = Input.is_action_pressed("ability")
		"look":
			acted = Input.is_action_pressed("camera_left") or Input.is_action_pressed("camera_right")
	if acted:
		_time = 0.0
		_piril_hint("")
		return
	_time += delta
	if _time > delay:
		_piril_hint(hint)


func _piril_hint(h: String) -> void:
	var p := get_tree().get_first_node_in_group("piril")
	if p and p.has_method("show_hint"):
		p.show_hint(h, global_position + Vector3.UP * 2.2)
