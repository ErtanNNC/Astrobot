extends Node3D
## M1 test alanı: düşünce başa dönme, fare yakalama, yardım yazısı.

@export var kill_height := -15.0  ## m, bunun altına düşen Bip başa döner

@onready var bip: Bip = $Bip
@onready var cam: FollowCamera = $FollowCamera
@onready var spawn: Marker3D = $SpawnPoint


func _ready() -> void:
	if OS.has_feature("mobile"):
		$UI/Help.text = "Sol: joystick · Sağ alt: zıpla · Sağda kaydır: kamera"
	bip.reset_state(spawn.global_position)
	cam.snap_to_target()


func _physics_process(_delta: float) -> void:
	if bip.global_position.y < kill_height:
		respawn()


func respawn() -> void:
	bip.reset_state(spawn.global_position)
	bip.facing_yaw = spawn.rotation.y
	bip.rotation.y = spawn.rotation.y
	cam.snap_to_target()


func _unhandled_input(event: InputEvent) -> void:
	if OS.has_feature("mobile"):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("restart"):
		respawn()
