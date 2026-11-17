class_name Bip
extends CharacterBody3D
## Bip'in hareketi. Kurallar ve sayılar: docs/features/hareket/design.md
## Tüm ayar sayıları aşağıdaki @export değişkenlerinde; Inspector'dan değiştirilebilir.

signal jumped
signal landed(fall_speed: float)

@export_group("Koşu")
@export var run_speed := 7.0             ## m/s
@export var ground_accel := 45.0         ## m/s²
@export var ground_decel := 60.0         ## m/s²
@export var air_control := 0.65          ## × ivme (havada)
@export var turn_speed := 12.0           ## rad/s

@export_group("Zıplama")
@export var jump_height := 2.2           ## m (tam zıplama)
@export var time_to_apex := 0.38         ## s
@export var fall_gravity_mult := 1.8     ## × yerçekimi (düşerken)
@export var jump_cut_mult := 0.5         ## × yukarı hız (erken bırakınca)
@export var max_fall_speed := 20.0       ## m/s
@export var coyote_time := 0.10          ## s
@export var jump_buffer := 0.12          ## s

@export_group("Zemin")
@export var max_floor_angle_deg := 40.0  ## bundan dik yüzey duvar sayılır

@export_group("Bağlantılar")
## Hareket yönü bu kameraya göre hesaplanır. Boşsa aktif kamera kullanılır.
@export var camera_rig: Node3D

@onready var visual: Node3D = $Visual
@onready var dust: CPUParticles3D = $LandingDust

var gravity: float
var jump_velocity: float
var coyote_timer := 0.0
var buffer_timer := 0.0
var is_jumping := false        # zıplama tuşuyla başlayan yükseliş sürüyor mu
var was_on_floor := true
var facing_yaw := 0.0
var last_floor_y := 0.0        # kamera için: en son basılan zeminin yüksekliği
var _squash_tween: Tween


func _ready() -> void:
	floor_max_angle = deg_to_rad(max_floor_angle_deg)
	floor_snap_length = 0.3
	floor_stop_on_slope = true
	_recalculate_jump()
	facing_yaw = rotation.y
	last_floor_y = global_position.y


## g = 2h / t², v = 2h / t  (tasarım dokümanındaki formül)
func _recalculate_jump() -> void:
	gravity = 2.0 * jump_height / (time_to_apex * time_to_apex)
	jump_velocity = 2.0 * jump_height / time_to_apex


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	# --- Sayaçlar (coyote time ve zıplama tamponu) ---
	if on_floor:
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		buffer_timer = jump_buffer
	else:
		buffer_timer = maxf(buffer_timer - delta, 0.0)

	# --- Yatay hareket (kameraya göre) ---
	var input := _get_move_input()
	var dir := _camera_relative(input)
	var target := dir * run_speed
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var rate: float
	if input.length() > 0.01:
		rate = ground_accel
	else:
		rate = ground_decel
	if not on_floor:
		rate *= air_control
	horizontal = horizontal.move_toward(target, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	# --- Dönüş: hareket yönüne yumuşakça ---
	if dir.length() > 0.05:
		var want := atan2(dir.x, dir.z)
		facing_yaw = rotate_toward(facing_yaw, want, turn_speed * delta)
		rotation.y = facing_yaw

	# --- Zıplama ---
	if buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		is_jumping = true
		buffer_timer = 0.0
		coyote_timer = 0.0
		on_floor = false
		_stretch()
		jumped.emit()

	# Değişken yükseklik: tuş tepe noktasından önce bırakılırsa yukarı hız kesilir.
	if is_jumping and velocity.y > 0.0 and not Input.is_action_pressed("jump"):
		velocity.y *= jump_cut_mult
		is_jumping = false

	# --- Yerçekimi ---
	# Yarım adım önce + yarım adım sonra uygulanır: zıplama yüksekliği
	# kare hızından bağımsız olarak tasarımdaki değere eşit çıkar.
	var g := 0.0
	if not on_floor:
		g = gravity
		if velocity.y < 0.0:
			g *= fall_gravity_mult
			is_jumping = false
		velocity.y = maxf(velocity.y - g * delta * 0.5, -max_fall_speed)

	var fall_speed := -velocity.y
	move_and_slide()
	if g > 0.0 and not is_on_floor():
		velocity.y = maxf(velocity.y - g * delta * 0.5, -max_fall_speed)

	# Tavana çarpınca yukarı hız sıfırlanır.
	if is_on_ceiling() and velocity.y > 0.0:
		velocity.y = 0.0
		is_jumping = false

	# --- İniş ---
	var now_on_floor := is_on_floor()
	if now_on_floor:
		last_floor_y = global_position.y
		if not was_on_floor:
			is_jumping = false
			_on_landed(fall_speed)
	was_on_floor = now_on_floor


func _get_move_input() -> Vector2:
	var v := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var touch := TouchInput.move_vector
	if touch.length() > v.length():
		v = touch
	return v.limit_length(1.0)


## Joystick "yukarı" = kameranın baktığı yön.
func _camera_relative(input: Vector2) -> Vector3:
	if input.length() < 0.01:
		return Vector3.ZERO
	var yaw := 0.0
	if camera_rig and camera_rig.has_method("get_yaw"):
		yaw = camera_rig.get_yaw()
	else:
		var cam := get_viewport().get_camera_3d()
		if cam:
			yaw = cam.global_rotation.y
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	return (right * input.x - forward * input.y)


## Duraklatma / yeniden doğma: sayaçlar sıfırlanır.
func reset_state(at: Vector3) -> void:
	global_position = at
	velocity = Vector3.ZERO
	coyote_timer = 0.0
	buffer_timer = 0.0
	is_jumping = false
	was_on_floor = true
	last_floor_y = at.y


# --- Görsel his: zıplarken uzama, inerken ezilme, toz ---

func _stretch() -> void:
	_tween_scale(Vector3(0.8, 1.25, 0.8), Vector3.ONE, 0.08, 0.25)


func _on_landed(fall_speed: float) -> void:
	var t := clampf(fall_speed / max_fall_speed, 0.2, 1.0)
	_tween_scale(Vector3(1.0 + 0.35 * t, 1.0 - 0.35 * t, 1.0 + 0.35 * t), Vector3.ONE, 0.06, 0.2)
	if fall_speed > 4.0:
		dust.restart()
		dust.emitting = true
		if Haptics:
			Haptics.vibrate(int(20 + 30 * t))
	landed.emit(fall_speed)
	# Ses ve animasyon: scripts/player/bip_visuals.gd (landed sinyalini dinler).


func _tween_scale(peak: Vector3, rest: Vector3, t_in: float, t_out: float) -> void:
	if _squash_tween:
		_squash_tween.kill()
	_squash_tween = create_tween()
	_squash_tween.tween_property(visual, "scale", peak, t_in).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_squash_tween.tween_property(visual, "scale", rest, t_out).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
