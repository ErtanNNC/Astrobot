extends Node3D
## M1 test alanı: suya düşünce başa dönme, müzik, fare yakalama, yardım yazısı.

@export var kill_height := -5.0  ## m, bunun altına (suya) düşen Bip başa döner

@onready var bip: Bip = $Bip
@onready var cam: FollowCamera = $FollowCamera
@onready var spawn: Marker3D = $SpawnPoint
@onready var music: AudioStreamPlayer = $Music


func _ready() -> void:
	if OS.has_feature("mobile"):
		$UI/Help.text = "Sol: joystick · Sağ alt: zıpla · Sağda kaydır: kamera"
	bip.reset_state(spawn.global_position)
	cam.snap_to_target()
	if music.stream is AudioStreamMP3:
		music.stream.loop = true
	music.play()


func _physics_process(_delta: float) -> void:
	if bip.global_position.y < kill_height:
		$FallSfx.play()
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
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_M:
		var bus := AudioServer.get_bus_index("Music")
		AudioServer.set_bus_mute(bus, not AudioServer.is_bus_mute(bus))
