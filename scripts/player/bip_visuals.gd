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
var _blob: MeshInstance3D
var _blob_mat: StandardMaterial3D
var _t := 0.0


# ---------- Yeni Bip modeli (Pixabay sarı robot + Mixamo animasyonları) ----------
const LITE_MESH := "res://assets/models/pixabay/bip/bip_mesh_lite.res"   ## ~12 bin üçgen
const NEW_BIP := true                        ## false: eski Quaternius robotu
const NEW_DIR := "res://assets/models/pixabay/bip/"
const NEW_SCALE := 120.0                     ## Mixamo santim ölçeğinde verdi: 120× → ~1,2 m (antenlerle)
const A_FALL := "bip_fall"
const A_HANG := "bip_hang"
## Eski robotun animasyon adları (oyunun her yerinde kullanılıyor) → yeni animasyonlar
const ALIASES := {
	"RobotArmature|Robot_Idle": "idle", "RobotArmature|Robot_Walking": "walk", "RobotArmature|Robot_Running": "run",
	"RobotArmature|Robot_Jump": "jump", "RobotArmature|Robot_Wave": "wave", "RobotArmature|Robot_Dance": "victory",
	"RobotArmature|Robot_Yes": "victory", "RobotArmature|Robot_ThumbsUp": "victory", "RobotArmature|Robot_Sitting": "idle",
	"RobotArmature|Robot_Standing": "idle", "RobotArmature|Robot_Punch": "wave", "bip_fall": "fall", "bip_hang": "hang",
}

static var _lib_cache: AnimationLibrary
var _new := false
var _skin_mats: Array[ShaderMaterial] = []
const SKIN_SHADER := preload("res://assets/shaders/bip_skin.gdshader")
var _base_scale := 0.2


func _swap_model() -> void:
	var old := $Model
	var nm: Node3D = load(NEW_DIR + "idle.fbx").instantiate()
	remove_child(old)
	old.queue_free()
	nm.name = "Model"
	nm.scale = Vector3.ONE * NEW_SCALE
	add_child(nm)
	move_child(nm, 0)
	model = nm
	anim = nm.get_node("AnimationPlayer")
	if _lib_cache == null:
		# Animasyonlar tek kütüphanede (tests/extract_bip_anims.gd üretir); eski adlarla eşlenir
		var src: AnimationLibrary = load(NEW_DIR + "bip_anims.res")
		_lib_cache = AnimationLibrary.new()
		for alias in ALIASES:
			_lib_cache.add_animation(alias, src.get_animation(ALIASES[alias]))
	for lib in anim.get_animation_library_list():
		anim.remove_animation_library(lib)
	anim.add_animation_library("", _lib_cache)
	_base_scale = NEW_SCALE
	_new = true
	for mi in nm.find_children("*", "MeshInstance3D", true, false):
		(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		# 49 bin üçgenli (148 bin köşeli) model yerine hafif kopya: tests/make_bip_lod.gd üretir
		if ResourceLoader.exists(LITE_MESH):
			(mi as MeshInstance3D).mesh = load(LITE_MESH)


const DUST := Color(0.95, 0.92, 0.85)

func _ready() -> void:
	if NEW_BIP:
		_swap_model()
	for n in [A_IDLE, A_WALK, A_RUN]:
		anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
	anim.play(A_IDLE)
	bip.jumped.connect(_on_jumped)
	bip.landed.connect(_on_landed)
	bip.copied.connect(_on_copied)
	bip.hurt.connect(_on_hurt)
	bip.spun.connect(_on_spun)
	bip.double_jumped.connect(_on_double_jumped)
	bip.ledge_grabbed.connect(_on_ledge_grabbed)
	GameState.ability_changed.connect(_apply_ability)
	_prepare_materials()
	apply_skin()
	Settings.changed.connect(func(): apply_skin())
	_icon_holder = Node3D.new()
	_icon_holder.position = Vector3(0, 1.75, 0)
	add_child(_icon_holder)
	_tip_mat = ($Antenna/Tip as MeshInstance3D).mesh.material.duplicate()
	($Antenna/Tip as MeshInstance3D).material_override = _tip_mat
	_attach_antenna.call_deferred()
	_apply_ability.call_deferred(GameState.ability)
	_make_blob_shadow()
	_make_jets()


func _process(delta: float) -> void:
	_t += delta
	_update_jets()
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
	elif bip.ledge_hanging:
		# Kenara asılı: yeni modelde tutunma animasyonu, eskide zıplama pozu
		_idle_time = 0.0
		_air_anim = false
		if _new:
			if anim.current_animation != A_HANG:
				anim.play(A_HANG, 0.1)
			anim.speed_scale = 1.0
		else:
			anim.speed_scale = 0.0
	else:
		_idle_time = 0.0
		if bip.wall_sliding:
			_dust_t -= delta
			if _dust_t <= 0.0:
				_dust_t = 0.1
				Fx.burst(bip.global_position + Vector3(0, 0.9, 0) - bip._wall_normal * 0.3, Color(0.95, 0.92, 0.85), 2, 0.6)
		if _new:
			# Yeni model: zıplama animasyonu baştan oynar, iniş pozuna yakın yerde bekler.
			# (Mixamo "Falling Idle" yüzüstü paraşüt pozu; platform oyununda tuhaf durduğu için kullanılmıyor.)
			if not _air_anim:
				_air_anim = true
				anim.play(A_JUMP, 0.1)
				anim.speed_scale = 1.0
				anim.seek(0.2, true)
			var jl := anim.current_animation_length
			if anim.current_animation == A_JUMP and anim.current_animation_position > jl * 0.45:
				anim.speed_scale = 0.0
		else:
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
	# Koşu izi (Kostüm Dolabı'ndan seçilir): hareket ederken arkada renkli zerreler
	if Settings.trail != "yok" and speed > 3.0:
		_trail_t -= delta
		if _trail_t <= 0.0:
			_trail_t = 0.07
			var ti := GameState.trail_info(Settings.trail)
			var tc: Color = Color.from_hsv(fmod(_t * 0.6, 1.0), 0.75, 1.0) if ti.get("rainbow", false) else ti.get("color", Color.WHITE)
			Fx.burst(bip.global_position + Vector3(0, 0.35, 0), tc, 2, 0.7)

	# Her adımda zemine göre ayrı bir örnek çalar (bkz. docs/features/ses/design.md)
	var walking := on_floor and speed > 1.0
	_step_t -= delta
	if walking and _step_t <= 0.0:
		_step_t = clampf(STEP_LENGTH / speed, 0.2, 0.45)
		_play_step()
	elif not walking:
		_step_t = minf(_step_t, 0.06)


const STEP_LENGTH := 1.75        ## m, iki adım sesi arası yol
## yüzey: [örnekler, ses (dB), perde]
const STEP_SETS := {
	"grass": [["leaves01", "leaves02"], -9.0, 1.0],
	"wood": [["wood01", "wood02", "wood03"], -5.0, 1.0],
	"stone": [["stone01"], -4.0, 1.0],
	"metal": [["stone01"], -5.0, 1.5],
	"gravel": [["gravel"], -11.0, 1.15],
	"snow": [["mud02", "leaves02"], -7.0, 0.75],
	"cloud": [["leaves01"], -16.0, 0.7],
}
const AREA_SURFACE := {
	"ch1_atolye": "wood", "ch1_yay": "grass", "ch1_balon": "gravel", "ch1_miknatis": "stone", "ch1_kaya": "gravel",
	"ch1_patron": "gravel", "ch2_rihtim": "wood", "ch2_fener": "grass", "ch2_gemi": "wood", "ch2_patron": "wood",
	"ch3_magara": "snow", "ch3_gol": "snow", "ch3_zirve": "snow", "ch3_patron": "snow",
	"ch4_bulut": "cloud", "ch4_kopru": "stone", "ch4_kale": "stone", "ch4_patron": "stone",
	"ch5_oyuncak": "wood", "ch5_gozlemevi": "stone", "ch5_volkan": "gravel", "ch5_sampiyon": "wood",
}
var _step_t := 0.0
var _trail_t := 0.0
var _step_cache := {}


## Bip'in bastığı yüzey: metal blok ve hareketli platformlar kendi sesini verir, gerisi alanın zemini.
func surface() -> String:
	var fc: Object = bip._floor_collider()
	if fc is Node:
		if (fc as Node).is_in_group("metal"):
			return "metal"
		if fc is AnimatableBody3D:
			return "wood"
	var sc := get_tree().current_scene
	var id: String = sc.area_id if sc and "area_id" in sc else ""
	return AREA_SURFACE.get(id, "wood")


func _play_step() -> void:
	var set_: Array = STEP_SETS[surface()]
	var names: Array = set_[0]
	var n: String = names[randi() % names.size()]
	if not _step_cache.has(n):
		_step_cache[n] = load("res://assets/audio/opengameart/steps/%s.ogg" % n)
	sfx_steps.stream = _step_cache[n]
	sfx_steps.volume_db = set_[1]
	sfx_steps.pitch_scale = float(set_[2]) * randf_range(0.92, 1.08)
	sfx_steps.play()


func _play(n: String) -> void:
	if anim.current_animation != n:
		anim.play(n, blend_time)


func _on_jumped() -> void:
	if bip.is_on_floor() or bip.velocity.y > 0.0:
		Fx.burst(bip.global_position + Vector3(0, 0.1, 0), DUST, 5, 1.6)
	sfx_jump.pitch_scale = randf_range(0.95, 1.08)
	sfx_jump.play()


func _on_landed(fall_speed: float) -> void:
	if fall_speed > 3.0:
		sfx_land.volume_db = lerpf(-14.0, -2.0, clampf(fall_speed / bip.max_fall_speed, 0.0, 1.0))
		sfx_land.pitch_scale = randf_range(0.92, 1.05)
		sfx_land.play()
	if fall_speed > 7.0:
		# Sert iniş: toz halkası (ezilme ve toz bulutu bip.gd'de; bkz. oyun-hissi "Geri bildirim")
		var k := clampf(fall_speed / bip.max_fall_speed, 0.3, 1.0)
		Fx.ring(bip.global_position, Color(DUST.r, DUST.g, DUST.b, 0.8), 0.9 + k * 0.9, 0.3)


## Bip'in anteni: kafanın tepesine, kafayla birlikte sallanan bir çubuk ve parlayan uç.
## Kopyalama (M2) bu uçtaki ışığı kullanacak.
func _attach_antenna() -> void:
	if _new:
		# Yeni modelin kendi iki anteni var: parlayan kopyalama ucunu başın tepesine, kafayla birlikte bağla
		var sk: Skeleton3D = model.get_node("Skeleton3D")
		var ba := BoneAttachment3D.new()
		ba.bone_name = "mixamorig_HeadTop_End"
		sk.add_child(ba)
		var antenna: Node3D = $Antenna
		_tip = antenna.get_node("Tip")
		antenna.get_node("Stick").visible = false
		remove_child(antenna)
		ba.add_child(antenna)
		antenna.transform = Transform3D(Basis().scaled(Vector3.ONE / NEW_SCALE), Vector3.ZERO)
		_tip.position = Vector3(0, 0.02, 0)
		return
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
			if _new and mat is StandardMaterial3D and (mat as StandardMaterial3D).albedo_texture:
				# Kostüm gölgelendiricisi: boyalı yerlerin tonu kaydırılabilir (GameState.SKINS)
				var sm := ShaderMaterial.new()
				sm.shader = SKIN_SHADER
				sm.set_shader_parameter("albedo_tex", (mat as StandardMaterial3D).albedo_texture)
				mi.set_surface_override_material(i, sm)
				_skin_mats.append(sm)
				continue
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
		if _new:
			mat.albedo_color = Color.WHITE.lerp(c.lightened(0.15), 0.55) if a != "" else orig
			continue
		mat.albedo_color = orig.lerp(c, 0.75) if (a != "" and is_paint) else orig
	for sm in _skin_mats:
		# Dokulu malzeme: bütün gövde yeteneğin rengine hafifçe boyanır
		sm.set_shader_parameter("tint", Color.WHITE.lerp(c.lightened(0.15), 0.55) if a != "" else Color.WHITE)
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


## Yuvarlak iniş gölgesi: Bip'in tam altında, havadayken nereye ineceğini gösterir.
func _make_blob_shadow() -> void:
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.55))
	g.set_color(1, Color(0, 0, 0, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	_blob_mat = StandardMaterial3D.new()
	_blob_mat.albedo_texture = tex
	_blob_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_blob_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_blob_mat.render_priority = 1
	var q := QuadMesh.new()
	q.size = Vector2(1.0, 1.0)
	q.orientation = PlaneMesh.FACE_Y
	_blob = MeshInstance3D.new()
	_blob.mesh = q
	_blob.material_override = _blob_mat
	_blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_blob.top_level = true
	add_child(_blob)


func _update_blob() -> void:
	if not _blob or not bip.is_inside_tree():
		return
	var from := bip.global_position + Vector3.UP * 0.4
	var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 40.0, 1 | 2, [bip.get_rid()])
	var hit := bip.get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		_blob.visible = false
		return
	var h: float = bip.global_position.y - hit.position.y
	_blob.visible = true
	_blob.global_position = hit.position + hit.normal * 0.03
	var s := clampf(1.1 - h * 0.04, 0.45, 1.1)
	_blob.scale = Vector3(s, 1, s)
	_blob_mat.albedo_color = Color(1, 1, 1, clampf(1.0 - h * 0.05, 0.35, 1.0))


func _update_effects(delta: float) -> void:
	_update_blob()
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
	var b := _base_scale
	model.scale = model.scale.lerp(Vector3(b * (1 + cf * 0.2), b * (1 - cf * 0.35), b * (1 + cf * 0.2)), 15.0 * delta)
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


func _on_hurt(result: String) -> void:
	var c := Color(1.0, 0.35, 0.3) if result != "ability" else Color(1.0, 0.8, 0.3)
	Fx.burst(bip.global_position + Vector3.UP * 0.7, c, 14, 4.5)
	Fx.ring(bip.global_position + Vector3.UP * 0.7, c, 1.5, 0.3, false)


## Yeniden doğma: Bip küçükten büyüyerek belirir, yerde mavi halka.
func pop_in() -> void:
	model.scale = Vector3.ONE * _base_scale * 0.15
	Fx.ring(bip.global_position, Color(0.4, 0.9, 1.0), 1.6, 0.45)
	Fx.burst(bip.global_position + Vector3.UP * 0.6, Color(0.5, 0.95, 1.0), 12, 3.0)



var _spin_tween: Tween


## Dönme saldırısı ve çift zıplama: model kendi ekseninde döner.
func _spin_model(turns: float, t: float) -> void:
	if _spin_tween:
		_spin_tween.kill()
	model.rotation.y = 0.0
	_spin_tween = create_tween()
	_spin_tween.tween_property(model, "rotation:y", TAU * turns, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_spin_tween.tween_callback(func(): model.rotation.y = 0.0)


func _on_spun() -> void:
	_spin_model(2.0, bip.spin_time)
	Fx.burst(bip.global_position + Vector3.UP * 0.6, Color(1.0, 0.95, 0.6), 10, bip.spin_radius * 1.6)


func _on_double_jumped() -> void:
	Fx.ring(bip.global_position + Vector3.UP * 0.05, Color(0.6, 0.95, 1.0), 1.0, 0.3, false)
	_spin_model(1.0, 0.3)


func _on_ledge_grabbed() -> void:
	if _new:
		return
	anim.play(A_JUMP, 0.05)
	anim.seek(0.3, true)
	anim.speed_scale = 0.0



# ---------- Jet süzülme ışınları ----------
var _jets: Array[MeshInstance3D] = []


func _make_jets() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(0.4, 0.85, 1.0, 0.85)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.07
	mesh.bottom_radius = 0.02
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 1
	mesh.material = mat
	for side in [-1, 1]:
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = Vector3(0.13 * side, -0.4, 0)
		mi.visible = false
		add_child(mi)
		_jets.append(mi)


func _update_jets() -> void:
	var on: bool = bip.hovering
	for j in _jets:
		j.visible = on
		if on:
			var len := 0.8 + 0.25 * sin(_t * 60.0 + j.position.x * 10.0)
			j.scale = Vector3(1.0, len, 1.0)
			j.position.y = 0.05 - len * 0.5
	if on and fmod(_t, 0.08) < 0.02:
		Fx.burst(bip.global_position + Vector3(0, -0.8, 0), Color(0.5, 0.9, 1.0), 1, 0.8)


## Kostüm (renk): Ayarlar'daki seçili kostümü gövdeye uygular. Bkz. GameState.SKINS
func apply_skin(id := "") -> void:
	var sk := GameState.skin_info(id if id != "" else Settings.skin)
	for sm in _skin_mats:
		sm.set_shader_parameter("hue_shift", float(sk.get("hue", 0.0)))
		sm.set_shader_parameter("sat_mul", float(sk.get("sat", 1.0)))
		sm.set_shader_parameter("val_mul", float(sk.get("val", 1.0)))
		var g := float(sk.get("glow", 0.0))
		sm.set_shader_parameter("glow", Vector3(1.0, 0.8, 0.3) * g)
