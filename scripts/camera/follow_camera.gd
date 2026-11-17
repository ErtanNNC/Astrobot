class_name FollowCamera
extends Node3D
## Bip'i kendi kendine takip eden kamera. Kurallar ve sayılar:
## docs/features/kamera/design.md
##
## Yapı:  FollowCamera (bu düğüm, dünyada serbest)
##          └ Pitch (yukarı/aşağı açı)
##              └ SpringArm3D (duvara çarpınca kısalır)
##                  └ Camera3D

@export var target: Bip

@export_group("Takip")
@export var distance := 7.0              ## m
@export var pitch_deg := 25.0            ## derece aşağı
@export var follow_smoothing := 6.0      ## 1/s
@export var look_ahead := 1.5            ## m (hareket yönünde ileri)
@export var fov := 60.0                  ## derece
@export var target_height := 1.0         ## m, Bip'in ayağından bakılan nokta yüksekliği

@export_group("Dikey takip")
## Bip zıplarken kamera yüksekliği bu sınırlar aşılmadıkça değişmez.
@export var vertical_up_margin := 2.5    ## m, son zeminin üstünde
@export var vertical_down_margin := 0.5  ## m, son zeminin altında
@export var vertical_smoothing := 4.0    ## 1/s

@export_group("Dönüş")
@export var auto_return_delay := 2.0     ## s, elle döndürmeden sonra otomatiğe dönüş
@export var auto_turn_speed := 1.6       ## 1/s, hareket yönüne kendiliğinden dönme
@export var mouse_sensitivity := 0.004   ## rad/piksel
@export var stick_speed := 2.8           ## rad/s
@export var touch_sensitivity := 0.006   ## rad/piksel
@export var min_pitch_deg := 5.0
@export var max_pitch_deg := 60.0

@export_group("Saydamlık")
@export var fade_start := 2.0            ## m, kamera bundan yakınsa Bip saydamlaşır
@export var fade_end := 0.8              ## m, tamamen saydam

@onready var pitch_node: Node3D = $Pitch
@onready var arm: SpringArm3D = $Pitch/SpringArm3D
@onready var camera: Camera3D = $Pitch/SpringArm3D/Camera3D

var _yaw := 0.0
var _pitch := 0.0
var _focus := Vector3.ZERO
var _focus_y := 0.0
var _manual_timer := 999.0
var _return_pending := false
var _cur_distance := 7.0
var _zone: Node = null  # aktif CameraZone (varsa)
var _trauma := 0.0      # ekran sarsıntısı (0..1)
var _look_yaw := 0.0
var _hold_front := false
var _front_dist := 4.5
var _front_pitch := 12.0
var _look_time := 0.0
var extra_distance := 0.0  ## Yay zıplamasında kamera biraz uzaklaşır (kopyalama Interactions)


func _ready() -> void:
	add_to_group("follow_camera")
	top_level = true
	_pitch = deg_to_rad(pitch_deg)
	_cur_distance = distance
	camera.fov = fov
	if target:
		arm.add_excluded_object(target.get_rid())
		_yaw = target.facing_yaw + PI
		snap_to_target()


func get_yaw() -> float:
	return _yaw


## Ölüm / ışınlanma sonrası: kayma olmadan anında yerine geç.
func snap_to_target() -> void:
	if not target:
		return
	_focus = target.global_position
	_focus_y = target.global_position.y
	_yaw = target.facing_yaw + PI
	_manual_timer = 999.0
	_apply_transform()


## Sarsıntı ekle (iniş, çakılma, hasar). Ayarlardan kapatılabilir.
func shake(amount: float) -> void:
	if Settings.shake_on:
		_trauma = clampf(_trauma + amount, 0.0, 1.0)


## Kısa bir an bir noktaya bak (manzara, patron girişi). Kontrol elden alınmaz.
func look_toward(p: Vector3, duration: float) -> void:
	var to := p - global_position
	_look_yaw = atan2(-to.x, -to.z)
	_look_time = duration


## Kamerayı Bip'in önüne al (giriş ekranında yüzünü göstermek için).
func face_target(dist := 4.5, pitch := 12.0) -> void:
	_yaw = target.facing_yaw
	_pitch = deg_to_rad(pitch)
	_cur_distance = dist
	_return_pending = false
	_manual_timer = 0.0
	_hold_front = true
	_front_dist = dist
	_front_pitch = pitch


func release_front() -> void:
	_hold_front = false


func set_zone(zone: Node) -> void:
	_zone = zone


func clear_zone(zone: Node) -> void:
	if _zone == zone:
		_zone = null


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_manual(-event.relative.x * mouse_sensitivity, -event.relative.y * mouse_sensitivity)


func _rotate_manual(dyaw: float, dpitch: float) -> void:
	if _zone:
		return
	_yaw += dyaw
	_pitch = clampf(_pitch - dpitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	_manual_timer = 0.0
	_return_pending = true


func _process(delta: float) -> void:
	if not target:
		return

	# --- Elle döndürme: sağ çubuk / ok tuşları ve dokunmatik kaydırma ---
	var stick := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if stick.length() > 0.05:
		_rotate_manual(-stick.x * stick_speed * delta, -stick.y * stick_speed * delta)
	var drag := TouchInput.consume_camera_drag()
	if drag.length() > 0.0:
		_rotate_manual(-drag.x * touch_sensitivity, -drag.y * touch_sensitivity)
	_manual_timer += delta

	# --- Hedef nokta: Bip + hareket yönünde biraz ileri ---
	var vel := target.velocity
	var hvel := Vector3(vel.x, 0.0, vel.z)
	var speed_frac := clampf(hvel.length() / maxf(target.run_speed, 0.01), 0.0, 1.0)
	var ahead := Vector3.ZERO
	if hvel.length() > 0.1:
		ahead = hvel.normalized() * look_ahead * speed_frac

	var k := 1.0 - exp(-follow_smoothing * delta)
	var want := target.global_position + ahead
	_focus.x = lerpf(_focus.x, want.x, k)
	_focus.z = lerpf(_focus.z, want.z, k)

	# --- Dikey: zıplarken sabit, yeni zemine inince ya da sınır aşılınca takip ---
	var bip_y := target.global_position.y
	var base_y := target.last_floor_y
	var wanted_y := _focus_y
	if target.is_on_floor():
		wanted_y = bip_y
	elif bip_y > _focus_y + vertical_up_margin:
		wanted_y = bip_y - vertical_up_margin
	elif bip_y < minf(_focus_y, base_y) - vertical_down_margin:
		wanted_y = bip_y + vertical_down_margin
	var kv := 1.0 - exp(-vertical_smoothing * delta)
	# Aşağı düşerken daha hızlı takip et ki Bip ekrandan çıkmasın.
	if wanted_y < _focus_y - 0.01 and not target.is_on_floor():
		kv = 1.0 - exp(-vertical_smoothing * 2.5 * delta)
	_focus_y = lerpf(_focus_y, wanted_y, kv)

	# --- Kamera bölgesi (varsa) açıyı ve uzaklığı sabitler ---
	var want_dist := distance
	if _zone:
		_yaw = lerp_angle(_yaw, deg_to_rad(_zone.yaw_deg), k)
		_pitch = lerpf(_pitch, deg_to_rad(_zone.pitch_deg), k)
		want_dist = _zone.distance
	elif _hold_front:
		_yaw = lerp_angle(_yaw, target.facing_yaw, k)
		_pitch = lerpf(_pitch, deg_to_rad(_front_pitch), k)
		want_dist = _front_dist
		_manual_timer = 0.0
	elif _look_time > 0.0:
		_look_time -= delta
		_yaw = lerp_angle(_yaw, _look_yaw, 1.0 - exp(-2.5 * delta))
		_pitch = lerpf(_pitch, deg_to_rad(10.0), 1.0 - exp(-2.0 * delta))
		want_dist = distance + 3.0
		_manual_timer = 0.0
		_return_pending = true
	elif _manual_timer > auto_return_delay:
		_auto_yaw(hvel, speed_frac, delta)
		_pitch = lerpf(_pitch, deg_to_rad(pitch_deg), 1.0 - exp(-1.5 * delta))
	if target.ability == "yay" and not target.is_on_floor() and target.velocity.y > 2.0:
		extra_distance = lerpf(extra_distance, 2.0, 1.0 - exp(-3.0 * delta))
	else:
		extra_distance = lerpf(extra_distance, 0.0, 1.0 - exp(-1.5 * delta))
	_cur_distance = lerpf(_cur_distance, want_dist + extra_distance, k)

	_apply_transform()
	if _trauma > 0.0:
		_trauma = maxf(_trauma - delta * 1.8, 0.0)
		var a := _trauma * _trauma
		camera.h_offset = randf_range(-1, 1) * 0.35 * a
		camera.v_offset = randf_range(-1, 1) * 0.35 * a
	else:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
	_update_fade()


## Otomatik dönüş: Bip yana koşarken kamera yavaşça arkasına geçer.
## Bip kameraya doğru koşuyorsa dönmez; yalnızca geri çekilir.
func _auto_yaw(hvel: Vector3, speed_frac: float, delta: float) -> void:
	var cam_fwd := Vector3(-sin(_yaw), 0.0, -cos(_yaw))
	if hvel.length() > 0.5:
		var move_dir := hvel.normalized()
		var toward_camera := move_dir.dot(cam_fwd) < -0.35
		if not toward_camera:
			var want_yaw := atan2(-move_dir.x, -move_dir.z)
			var rate := auto_turn_speed * speed_frac
			_yaw = lerp_angle(_yaw, want_yaw, 1.0 - exp(-rate * delta))
			_return_pending = false
	elif _return_pending:
		# Elle döndürmeden sonra, Bip dururken: Bip'in arkasına dön.
		var behind := target.facing_yaw + PI
		_yaw = lerp_angle(_yaw, behind, 1.0 - exp(-3.0 * delta))
		if absf(angle_difference(_yaw, behind)) < 0.02:
			_return_pending = false


func _apply_transform() -> void:
	global_position = Vector3(_focus.x, _focus_y + target_height, _focus.z)
	rotation = Vector3(0.0, _yaw, 0.0)
	pitch_node.rotation = Vector3(-_pitch, 0.0, 0.0)
	arm.spring_length = _cur_distance


## Kamera Bip'e çok yaklaşırsa (duvar arkası) Bip saydamlaşır.
func _update_fade() -> void:
	var d := camera.global_position.distance_to(target.global_position + Vector3.UP * 0.5)
	var a := clampf((fade_start - d) / maxf(fade_start - fade_end, 0.01), 0.0, 1.0)
	for m in target.get_node("Visual").find_children("*", "GeometryInstance3D", true, false):
		(m as GeometryInstance3D).transparency = a
