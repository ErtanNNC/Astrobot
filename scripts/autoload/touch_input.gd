extends Node
## Dokunmatik kontrollerden gelen girdiyi tutar (autoload: TouchInput).
## Bip ve kamera, klavye/gamepad girdisinin yanında buradaki değerleri de okur.
## Not: Tam mobil kontroller M4'te tasarlanacak; bu, telefonda test için basit sürüm.

var move_vector := Vector2.ZERO  # sol joystick, uzunluğu 0..1
var _camera_drag := Vector2.ZERO # sağ yarıda parmak kaydırma (piksel)


func add_camera_drag(d: Vector2) -> void:
	_camera_drag += d


func consume_camera_drag() -> Vector2:
	var d := _camera_drag
	_camera_drag = Vector2.ZERO
	return d


## Son kullanılan giriş aygıtı: "touch", "keyboard", "gamepad" (Pırıl'ın tuş simgeleri için, D-005).
var last_device := "touch" if OS.has_feature("mobile") else "keyboard"


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		last_device = "touch"
	elif event is InputEventKey or event is InputEventMouseButton:
		last_device = "keyboard"
	elif event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.4):
		last_device = "gamepad"
