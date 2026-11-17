extends Control
## Basit dokunmatik kontroller (geçici, M4'te tasarlanacak):
## - Ekranın sol yarısı: parmağın değdiği yerde beliren sanal joystick
## - Sağ alttaki buton: Zıpla
## - Ekranın sağ yarısının geri kalanı: parmak kaydırarak kamerayı döndür

@export var joystick_radius := 110.0   ## piksel (ekran yüksekliği 720'ye göre)
@export var dead_zone := 0.12

@onready var base: Control = $JoyBase
@onready var knob: Control = $JoyBase/Knob
@onready var jump_button: Control = $JumpButton

var _joy_finger := -1
var _joy_center := Vector2.ZERO
var _cam_finger := -1
var _jump_finger := -1


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	base.visible = false
	set_process_input(visible)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)


func _on_touch(e: InputEventScreenTouch) -> void:
	var half := get_viewport_rect().size.x * 0.5
	if e.pressed:
		if jump_button.get_global_rect().grow(20).has_point(e.position) and _jump_finger == -1:
			_jump_finger = e.index
			Input.action_press("jump")
			jump_button.modulate = Color(1, 1, 1, 0.6)
		elif e.position.x < half and _joy_finger == -1:
			_joy_finger = e.index
			_joy_center = e.position
			base.visible = true
			base.global_position = _joy_center - base.size * 0.5
			knob.position = base.size * 0.5 - knob.size * 0.5
		elif e.position.x >= half and _cam_finger == -1:
			_cam_finger = e.index
	else:
		if e.index == _jump_finger:
			_jump_finger = -1
			Input.action_release("jump")
			jump_button.modulate = Color.WHITE
		elif e.index == _joy_finger:
			_joy_finger = -1
			base.visible = false
			TouchInput.move_vector = Vector2.ZERO
		elif e.index == _cam_finger:
			_cam_finger = -1


func _on_drag(e: InputEventScreenDrag) -> void:
	if e.index == _joy_finger:
		var scale_f := get_viewport_rect().size.y / 720.0
		var r := joystick_radius * scale_f
		var off := (e.position - _joy_center).limit_length(r)
		knob.position = base.size * 0.5 - knob.size * 0.5 + off
		var v := off / r
		TouchInput.move_vector = Vector2.ZERO if v.length() < dead_zone else v
	elif e.index == _cam_finger:
		TouchInput.add_camera_drag(e.relative)
