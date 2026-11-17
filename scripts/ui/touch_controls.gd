extends Control
## Telefon kontrolleri: yüzen joystick, Zıpla, Yetenek, Duraklat ve kamera kaydırma.
## Kurallar ve ölçüler: docs/features/mobil-kontroller/design.md
## Ölçüler 720 px yüksekliğe göre; ekran büyüdükçe orantılı büyür.

signal pause_pressed

@export_group("Joystick")
@export var joy_radius := 105.0            ## px
@export var joy_knob_radius := 46.0        ## px
@export var joy_dead_zone := 0.15          ## × yarıçap
@export var joy_zone_width := 0.45         ## ekran genişliğinin oranı
@export var joy_zone_top := 0.22           ## ekranın üstünden bu oran hariç
@export var joy_rest := Vector2(190, 175)  ## px, dinlenme yeri: sol alt köşeden

@export_group("Butonlar")
@export var jump_radius := 88.0            ## px
@export var jump_from_corner := Vector2(165, 160)  ## px, sağ alt köşeden merkez
@export var ability_radius := 64.0         ## px
@export var ability_offset := Vector2(-150, -140)  ## px, Zıpla merkezine göre
@export var pause_radius := 40.0           ## px (dokunma)
@export var pause_from_corner := Vector2(62, 58)   ## px, sol üst köşeden
@export var hit_scale := 1.25              ## dokunma alanı / çizim
@export var jump_vibration_ms := 12

const COL_FILL := Color(1, 1, 1, 0.16)
const COL_RING := Color(1, 1, 1, 0.75)
const COL_JUMP := Color(0.25, 0.62, 1.0, 0.55)
const COL_ABILITY := Color(1.0, 0.75, 0.2, 0.5)
const COL_ICON := Color(1, 1, 1, 0.95)
const COL_SHADOW := Color(0.05, 0.08, 0.2, 0.35)

var ability_enabled := false  ## yetenek varsa ya da menzilde kopyalanabilir nesne varsa
var _ability_color := COL_ABILITY
var _pulse := 0.0
var _t := 0.0

var _joy_finger := -1
var _joy_center := Vector2.ZERO
var _joy_knob := Vector2.ZERO
var _cam_finger := -1
var _jump_finger := -1
var _ability_finger := -1
var _pause_finger := -1
var _active := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_active = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	visible = _active
	set_process_input(_active)
	Settings.changed.connect(queue_redraw)
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	if not _active:
		return
	_t += delta
	var bip := get_tree().get_first_node_in_group("player")
	var near := false
	if bip:
		near = bip.best_source() != null
	ability_enabled = near or GameState.ability != ""
	var c := AbilityModels.color(GameState.ability) if GameState.ability != "" else COL_ABILITY
	_ability_color = Color(c, 0.6)
	# Kopyalanabilir nesne yakınsa Yetenek butonu nabız gibi atar: "buna bas"
	_pulse = (0.5 + 0.5 * sin(_t * 8.0)) if near else 0.0
	queue_redraw()


# ---------- Yerleşim ----------

func _k() -> float:
	return size.y / 720.0


func _bs() -> float:
	return _k() * Settings.button_scale()


## Güvenli alan (çentik vb.) kenar boşlukları, bu Control'ün koordinatlarında.
func _insets() -> Rect2:
	var win := Vector2(DisplayServer.window_get_size())
	var safe := Rect2(DisplayServer.get_display_safe_area())
	if win.x <= 0 or safe.size.x <= 0:
		return Rect2()
	var r := size / win
	var left := maxf(safe.position.x, 0.0) * r.x
	var top := maxf(safe.position.y, 0.0) * r.y
	var right := maxf(win.x - safe.end.x, 0.0) * r.x
	var bottom := maxf(win.y - safe.end.y, 0.0) * r.y
	return Rect2(left, top, right, bottom)  # (sol, üst, sağ, alt)


func _mirror(p: Vector2) -> Vector2:
	return Vector2(size.x - p.x, p.y) if Settings.left_handed else p


func _jump_center() -> Vector2:
	var ins := _insets()
	var p := Vector2(size.x - ins.size.x - jump_from_corner.x * _bs(), size.y - ins.size.y - jump_from_corner.y * _bs())
	return _mirror(p)


func _ability_center() -> Vector2:
	var j := _jump_center()
	var off := ability_offset * _bs()
	if Settings.left_handed:
		off.x = -off.x
	return j + off


func _pause_center() -> Vector2:
	var ins := _insets()
	return Vector2(ins.position.x + pause_from_corner.x * _k(), ins.position.y + pause_from_corner.y * _k())


func _joy_rest_center() -> Vector2:
	var ins := _insets()
	var p := Vector2(ins.position.x + joy_rest.x * _bs(), size.y - ins.size.y - joy_rest.y * _bs())
	return _mirror(p)


func _in_joy_zone(p: Vector2) -> bool:
	var x := size.x - p.x if Settings.left_handed else p.x
	return x < size.x * joy_zone_width and p.y > size.y * joy_zone_top


func _hit(p: Vector2, c: Vector2, r: float) -> bool:
	return p.distance_to(c) <= r * hit_scale


# ---------- Dokunma ----------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)


func _on_touch(e: InputEventScreenTouch) -> void:
	var p := e.position
	if e.pressed:
		if _pause_finger == -1 and _hit(p, _pause_center(), pause_radius * _k()):
			_pause_finger = e.index
		elif _jump_finger == -1 and _hit(p, _jump_center(), jump_radius * _bs()):
			_jump_finger = e.index
			Input.action_press("jump")
			Haptics.vibrate(jump_vibration_ms)
		elif _ability_finger == -1 and _hit(p, _ability_center(), ability_radius * _bs()):
			_ability_finger = e.index
			Input.action_press("ability")
		elif _joy_finger == -1 and _in_joy_zone(p):
			_joy_finger = e.index
			_joy_center = p
			_joy_knob = p
			TouchInput.move_vector = Vector2.ZERO
		elif _cam_finger == -1:
			_cam_finger = e.index
		else:
			return
		get_viewport().set_input_as_handled()
	else:
		if e.index == _pause_finger:
			_pause_finger = -1
			if _hit(p, _pause_center(), pause_radius * _k() * 1.5):
				pause_pressed.emit()
		elif e.index == _jump_finger:
			_jump_finger = -1
			Input.action_release("jump")
		elif e.index == _ability_finger:
			_ability_finger = -1
			Input.action_release("ability")
		elif e.index == _joy_finger:
			_joy_finger = -1
			TouchInput.move_vector = Vector2.ZERO
		elif e.index == _cam_finger:
			_cam_finger = -1
	queue_redraw()


func _on_drag(e: InputEventScreenDrag) -> void:
	if e.index == _joy_finger:
		var r := joy_radius * _bs()
		var off := e.position - _joy_center
		if off.length() > r:
			# Halka parmağı izler: yön hiç takılmaz.
			_joy_center = e.position - off.normalized() * r
			off = e.position - _joy_center
		_joy_knob = e.position
		var v := off / r
		var mag := v.length()
		if mag < joy_dead_zone:
			TouchInput.move_vector = Vector2.ZERO
		else:
			TouchInput.move_vector = v.normalized() * clampf((mag - joy_dead_zone) / (1.0 - joy_dead_zone), 0.0, 1.0)
		queue_redraw()
		get_viewport().set_input_as_handled()
	elif e.index == _cam_finger:
		TouchInput.add_camera_drag(e.relative)
		get_viewport().set_input_as_handled()


## Duraklatma açılınca: basılı her şeyi bırak.
func release_all() -> void:
	if _jump_finger != -1:
		Input.action_release("jump")
	if _ability_finger != -1:
		Input.action_release("ability")
	_joy_finger = -1
	_cam_finger = -1
	_jump_finger = -1
	_ability_finger = -1
	_pause_finger = -1
	TouchInput.move_vector = Vector2.ZERO
	TouchInput.consume_camera_drag()
	queue_redraw()


# ---------- Çizim ----------

func _draw() -> void:
	var a := Settings.button_opacity
	var bs := _bs()

	# Joystick
	if _joy_finger != -1:
		_circle(_joy_center, joy_radius * bs, COL_FILL, COL_RING, a)
		_circle(_clamp_knob(), joy_knob_radius * bs, Color(1, 1, 1, 0.55), COL_RING, a)
	else:
		var c := _joy_rest_center()
		_circle(c, joy_radius * bs, Color(1, 1, 1, 0.07), Color(1, 1, 1, 0.3), a)
		_circle(c, joy_knob_radius * bs, Color(1, 1, 1, 0.18), Color(1, 1, 1, 0.35), a)

	# Zıpla
	var jc := _jump_center()
	var jr := jump_radius * bs * (0.9 if _jump_finger != -1 else 1.0)
	_circle(jc, jr, COL_JUMP.lightened(0.3) if _jump_finger != -1 else COL_JUMP, COL_RING, a)
	_icon_jump(jc, jr * 0.5, a)

	# Yetenek
	var ac := _ability_center()
	var ar := ability_radius * bs * (0.9 if _ability_finger != -1 else 1.0) * (1.0 + _pulse * 0.12)
	var aa := a if ability_enabled else a * 0.45
	if _pulse > 0.0:
		draw_circle(ac, ar * 1.25, Color(1, 1, 0.7, 0.25 * _pulse * a))
	_circle(ac, ar, _ability_color, COL_RING, aa)
	_icon_antenna(ac, ar * 0.55, aa)

	# Duraklat
	var pc := _pause_center()
	var pr := 30.0 * _k()
	_circle(pc, pr, Color(0, 0, 0, 0.25), Color(1, 1, 1, 0.6), a)
	var bw := pr * 0.22
	var bh := pr * 0.9
	draw_rect(Rect2(pc + Vector2(-bw * 1.7, -bh * 0.5), Vector2(bw, bh)), Color(1, 1, 1, 0.9 * a))
	draw_rect(Rect2(pc + Vector2(bw * 0.7, -bh * 0.5), Vector2(bw, bh)), Color(1, 1, 1, 0.9 * a))


func _clamp_knob() -> Vector2:
	var r := joy_radius * _bs()
	return _joy_center + (_joy_knob - _joy_center).limit_length(r)


func _circle(c: Vector2, r: float, fill: Color, ring: Color, alpha: float) -> void:
	draw_circle(c + Vector2(0, 4 * _k()), r, Color(COL_SHADOW, COL_SHADOW.a * alpha))
	draw_circle(c, r, Color(fill, fill.a * alpha))
	draw_arc(c, r, 0, TAU, 48, Color(ring, ring.a * alpha), 3.0 * _k(), true)


func _icon_jump(c: Vector2, s: float, alpha: float) -> void:
	var col := Color(COL_ICON, COL_ICON.a * alpha)
	var pts := PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.85, s * 0.05), c + Vector2(s * 0.32, s * 0.05),
		c + Vector2(s * 0.32, s * 0.8), c + Vector2(-s * 0.32, s * 0.8), c + Vector2(-s * 0.32, s * 0.05), c + Vector2(-s * 0.85, s * 0.05)])
	draw_colored_polygon(pts, col)


func _icon_antenna(c: Vector2, s: float, alpha: float) -> void:
	var col := Color(COL_ICON, COL_ICON.a * alpha)
	draw_line(c + Vector2(0, s * 0.9), c + Vector2(0, -s * 0.35), col, 4.0 * _k(), true)
	draw_circle(c + Vector2(0, -s * 0.6), s * 0.32, col)
	draw_arc(c + Vector2(0, -s * 0.6), s * 0.75, -PI * 0.85, -PI * 0.15, 16, col, 3.0 * _k(), true)
	draw_line(c + Vector2(-s * 0.6, s * 0.9), c + Vector2(s * 0.6, s * 0.9), col, 4.0 * _k(), true)
