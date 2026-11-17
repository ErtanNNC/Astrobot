class_name CameraZone
extends Area3D
## Bip bu alana girince kamera açısı ve uzaklığı sabitlenir.

@export var yaw_deg := 0.0       ## derece, kameranın baktığı yön (0 = -Z yönüne bakar)
@export var pitch_deg := 35.0    ## derece aşağı
@export var distance := 9.0      ## m


func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


func _on_enter(body: Node) -> void:
	if body is Bip:
		var cam := get_tree().get_first_node_in_group("follow_camera")
		if cam:
			cam.set_zone(self)


func _on_exit(body: Node) -> void:
	if body is Bip:
		var cam := get_tree().get_first_node_in_group("follow_camera")
		if cam:
			cam.clear_zone(self)
