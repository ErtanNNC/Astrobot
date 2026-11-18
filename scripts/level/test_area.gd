extends Node3D
## M1 test alanı: suya düşünce başa dönme, müzik, fare yakalama, yardım yazısı.

@export var kill_height := -5.0  ## m, bunun altına (suya) düşen Bip başa döner

@onready var bip: Bip = $Bip
@onready var cam: FollowCamera = $FollowCamera
@onready var spawn: Marker3D = $SpawnPoint
@onready var music: AudioStreamPlayer = $Music
@onready var touch = $UI/TouchControls
@onready var pause_menu = $UI/PauseMenu


func _ready() -> void:
	if OS.has_feature("mobile"):
		$UI/Help.visible = false  # telefonda butonlar kendini anlatır (yazısız)
	bip.reset_state(spawn.global_position)
	cam.snap_to_target()
	if music.stream is AudioStreamMP3:
		music.stream.loop = true
	music.play()
	touch.pause_pressed.connect(open_pause)
	pause_menu.restart_requested.connect(respawn)


func open_pause() -> void:
	touch.release_all()
	bip.clear_timers()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.open()


## Telefon arka plana alınınca oyun kendiliğinden duraklar.
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_inside_tree() and OS.has_feature("mobile"):
			open_pause()


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
	if event.is_action_pressed("pause"):
		open_pause()
		get_viewport().set_input_as_handled()
		return
	if OS.has_feature("mobile"):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT \
			and not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("restart"):
		respawn()
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_M:
		Settings.set_value("music_vol", 0.0 if Settings.music_vol > 0.01 else 0.8)
