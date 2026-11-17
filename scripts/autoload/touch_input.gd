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
