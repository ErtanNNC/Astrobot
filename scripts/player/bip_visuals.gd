extends Node3D
## Bip'in görünüşü ve sesleri: robot modelinin animasyonları, anten ışığı,
## zıplama/iniş/adım sesleri. Hareketin kendisi bip.gd içinde.
## Model: Quaternius "Animated Robot" (CC0), bkz. CREDITS.md

@export var walk_anim_speed := 2.2   ## m/s, yürüme animasyonunun 1× hızda gittiği hız
@export var run_anim_speed := 6.0    ## m/s, koşu animasyonunun 1× hızda gittiği hız
@export var run_threshold := 3.2     ## m/s, bunun üstünde koşu animasyonu
@export var blend_time := 0.15       ## s, animasyon geçişi
@export var step_volume_db := -8.0

const A_IDLE := "RobotArmature|Robot_Idle"
const A_WALK := "RobotArmature|Robot_Walking"
const A_RUN := "RobotArmature|Robot_Running"
const A_JUMP := "RobotArmature|Robot_Jump"
const A_WAVE := "RobotArmature|Robot_Wave"

@onready var bip: Bip = get_parent()
@onready var model: Node3D = $Model
@onready var anim: AnimationPlayer = $Model/AnimationPlayer
@onready var sfx_jump: AudioStreamPlayer3D = $"../Sfx/Jump"
@onready var sfx_land: AudioStreamPlayer3D = $"../Sfx/Land"
@onready var sfx_steps: AudioStreamPlayer3D = $"../Sfx/Steps"

var _idle_time := 0.0
var _air_anim := false


func _ready() -> void:
	for n in [A_IDLE, A_WALK, A_RUN]:
		anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	anim.play(A_IDLE)
	bip.jumped.connect(_on_jumped)
	bip.landed.connect(_on_landed)
	_attach_antenna.call_deferred()


func _process(delta: float) -> void:
	var v := bip.velocity
	var speed := Vector2(v.x, v.z).length()
	var on_floor := bip.is_on_floor()

	if on_floor:
		_air_anim = false
		if speed < 0.3:
			_idle_time += delta
			# Uzun süre beklersen Bip oyuncuya el sallar (küçük sürpriz).
			if _idle_time > 6.0 and anim.current_animation != A_WAVE:
				anim.play(A_WAVE, blend_time)
				anim.queue(A_IDLE)
				_idle_time = 0.0
			elif anim.current_animation not in [A_IDLE, A_WAVE]:
				anim.play(A_IDLE, blend_time)
			anim.speed_scale = 1.0
		else:
			_idle_time = 0.0
			if speed > run_threshold:
				_play(A_RUN)
				anim.speed_scale = clampf(speed / run_anim_speed, 0.6, 1.6)
			else:
				_play(A_WALK)
				anim.speed_scale = clampf(speed / walk_anim_speed, 0.5, 1.5)
	else:
		_idle_time = 0.0
		if not _air_anim:
			_air_anim = true
			anim.play(A_JUMP, 0.08)
			anim.speed_scale = 1.0
			anim.seek(0.18, true)
		# Tepeye yakın pozda bekle; düşüşte hafifçe ilerle.
		if anim.current_animation == A_JUMP and anim.current_animation_position > 0.42:
			anim.speed_scale = 0.0

	# Adım sesi: yerde ve hareket ederken
	var walking := on_floor and speed > 1.0
	if walking and not sfx_steps.playing:
		sfx_steps.play()
	elif not walking and sfx_steps.playing:
		sfx_steps.stop()
	if walking:
		sfx_steps.pitch_scale = clampf(0.8 + speed / bip.run_speed * 0.45, 0.8, 1.25)


func _play(n: String) -> void:
	if anim.current_animation != n:
		anim.play(n, blend_time)


func _on_jumped() -> void:
	sfx_jump.pitch_scale = randf_range(0.95, 1.08)
	sfx_jump.play()


func _on_landed(fall_speed: float) -> void:
	if fall_speed > 3.0:
		sfx_land.volume_db = lerpf(-14.0, -2.0, clampf(fall_speed / bip.max_fall_speed, 0.0, 1.0))
		sfx_land.pitch_scale = randf_range(0.92, 1.05)
		sfx_land.play()


## Bip'in anteni: kafanın tepesine, kafayla birlikte sallanan bir çubuk ve parlayan uç.
## Kopyalama (M2) bu uçtaki ışığı kullanacak.
func _attach_antenna() -> void:
	var head: Node3D = model.find_child("Head2", true, false)
	var head_mesh: MeshInstance3D = head.find_child("*", false, false) as MeshInstance3D
	if head_mesh == null:
		for c in head.get_children():
			if c is MeshInstance3D:
				head_mesh = c
	var box: AABB = head_mesh.global_transform * head_mesh.get_aabb()
	var top := Vector3(box.get_center().x, box.end.y - 0.02, box.get_center().z)
	var antenna: Node3D = $Antenna
	remove_child(antenna)
	head.add_child(antenna)
	antenna.global_transform = Transform3D(Basis.from_euler(Vector3(0, global_rotation.y, 0)), top)
