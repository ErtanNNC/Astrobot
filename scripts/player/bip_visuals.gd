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
var _orig_colors := {}      # malzeme → özgün renk
var _icon: Node3D
var _icon_holder: Node3D
var _tip_mat: StandardMaterial3D
var _beam: MeshInstance3D
var _tip: Node3D
var _dust_t := 0.0
var _t := 0.0


func _ready() -> void:
	for n in [A_IDLE, A_WALK, A_RUN]:
		anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	anim.play(A_IDLE)
	bip.jumped.connect(_on_jumped)
	bip.landed.connect(_on_landed)
	bip.copied.connect(_on_copied)
	bip.hurt.connect(_on_hurt)
	GameState.ability_changed.connect(_apply_ability)
	_prepare_materials()
	_icon_holder = Node3D.new()
	_icon_holder.position = Vector3(0, 1.75, 0)
	add_child(_icon_holder)
	_tip_mat = ($Antenna/Tip as MeshInstance3D).mesh.material.duplicate()
	($Antenna/Tip as MeshInstance3D).material_override = _tip_mat
	_attach_antenna.call_deferred()
	_apply_ability.call_deferred(GameState.ability)


func _process(delta: float) -> void:
	_t += delta
	_update_effects(delta)
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

	# Koşu tozu: hızlı koşarken ayaklardan küçük toz bulutları
	_dust_t -= delta
	if on_floor and speed > 5.0 and _dust_t <= 0.0:
		_dust_t = 0.12
		Fx.burst(bip.global_position + Vector3(0, 0.08, 0), Color(0.95, 0.92, 0.85), 2, 0.8)

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
	_tip = antenna.get_node("Tip")
	remove_child(antenna)
	head.add_child(antenna)
	antenna.global_transform = Transform3D(Basis.from_euler(Vector3(0, global_rotation.y, 0)), top)


# ---------- Yetenek görünüşü ----------

## Robotun malzemelerini kopyala ki renklerini değiştirebilelim.
func _prepare_materials() -> void:
	for m in model.find_children("*", "MeshInstance3D", true, false):
		var mi := m as MeshInstance3D
		for i in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(i)
			if mat is StandardMaterial3D:
				var dup: StandardMaterial3D = mat.duplicate()
				mi.set_surface_override_material(i, dup)
				_orig_colors[dup] = dup.albedo_color


## Gövde rengi ve kafadaki simge taşınan yeteneği gösterir (kopyalama kural 4).
func _apply_ability(a: String) -> void:
	var c := AbilityModels.color(a)
	for mat in _orig_colors:
		var orig: Color = _orig_colors[mat]
		# Yalnızca turuncu gövde boyası renk değiştirir; gri metal ve siyah gözler kalır.
		var is_paint := orig.s > 0.35 and orig.v > 0.35
		mat.albedo_color = orig.lerp(c, 0.75) if (a != "" and is_paint) else orig
	if _icon:
		_icon.queue_free()
		_icon = null
	if a != "":
		_icon = AbilityModels.make_icon(a)
		_icon_holder.add_child(_icon)
		_icon.scale = Vector3.ZERO
		create_tween().tween_property(_icon, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tip_mat.emission = c if a != "" else Color(0.3, 0.9, 1.0)
	_tip_mat.albedo_color = c if a != "" else Color(0.4, 0.95, 1.0)


func _update_effects(delta: float) -> void:
	# Anten ışığı: kopyalanabilir nesne yakınsa hızlı yanıp söner (kopyalama kural 1)
	var near: bool = bip.best_source() != null
	_tip_mat.emission_energy_multiplier = (2.5 + 2.5 * (0.5 + 0.5 * sin(_t * 14.0))) if near else 2.5
	# Hasar sonrası yanıp sönme
	visible = bip.invuln <= 0.0 or fmod(_t, 0.16) < 0.09
	# Simge salınımı; balon süzülürken büyür
	if _icon:
		_icon.rotation.y += delta * 1.5
		var target_scale := 1.0
		if GameState.ability == "balon" and bip.gliding:
			target_scale = 2.4
		_icon.scale = _icon.scale.lerp(Vector3.ONE * target_scale, 8.0 * delta) if _icon.scale.x > 0.9 else _icon.scale
		_icon_holder.position.y = 1.75 + (0.35 if bip.gliding else 0.0)
		if GameState.ability == "pervane":
			var bl := _icon.find_child("Blades", true, false) as Node3D
			if bl:
				bl.rotation.y += delta * (30.0 if (bip.propelling or bip.dash_left > 0.0) else 3.0)
	# Yay şarjı: Bip çömelir
	var cf: float = bip.charge_fraction()
	model.scale = model.scale.lerp(Vector3(0.2 * (1 + cf * 0.2), 0.2 * (1 - cf * 0.35), 0.2 * (1 + cf * 0.2)), 15.0 * delta)
	# Kopyalama ışını
	if _beam:
		_beam.scale.x = maxf(_beam.scale.x - delta * 4.0, 0.0)
		_beam.scale.z = _beam.scale.x
		if _beam.scale.x <= 0.0:
			_beam.queue_free()
			_beam = null


func _on_copied(a: String) -> void:
	var src = bip.best_source()
	if src == null:
		return
	# Antenden nesneye uzanan ışın (kopyalama kural 3)
	var from: Vector3 = _tip.global_position if _tip else bip.global_position + Vector3.UP * 1.2
	var to: Vector3 = src.global_position + Vector3.UP * 0.6
	var cyl := CylinderMesh.new()
	cyl.radial_segments = 16
	cyl.rings = 1
	cyl.top_radius = 0.05
	cyl.bottom_radius = 0.05
	cyl.height = 1.0
	if _beam:
		_beam.queue_free()
	_beam = AbilityModels.mesh_node(cyl, AbilityModels.mat(AbilityModels.color(a), 0.3, 4.0))
	get_tree().current_scene.add_child(_beam)
	var mid := (from + to) * 0.5
	_beam.global_position = mid
	var d := to - from
	_beam.look_at_from_position(mid, to, Vector3.UP if absf(d.normalized().y) < 0.95 else Vector3.RIGHT)
	_beam.rotate_object_local(Vector3.RIGHT, PI / 2)
	_beam.scale = Vector3(1, d.length(), 1)
	anim.play(A_WAVE, 0.05)
	anim.queue(A_IDLE)


func _on_hurt(_result: String) -> void:
	pass
