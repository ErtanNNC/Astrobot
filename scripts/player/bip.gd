class_name Bip
extends CharacterBody3D
## Bip'in hareketi ve yetenekleri.
## Hareket: docs/features/hareket/design.md · Yetenekler: docs/features/kopyalama/design.md
## Tüm ayar sayıları aşağıdaki @export değişkenlerinde; Inspector'dan değiştirilebilir.

signal jumped
signal landed(fall_speed: float)
signal copied(ability: String)
signal ability_dropped
signal hurt(result: String)   ## "ability" | "life" | "dead"
signal pounded(at: Vector3)

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

@export_group("Kopyalama")
@export var copy_range := 1.8            ## m
@export var copy_anim_time := 0.25       ## s
@export var drop_hold_time := 1.2        ## s, Yetenek tuşu bu kadar basılı tutulursa yetenek bırakılır

@export_group("Yay")
@export var spring_jump_height := 5.0    ## m
@export var spring_charged_height := 6.5 ## m
@export var spring_charge_time := 0.5    ## s, tam şarj

@export_group("Balon")
@export var balloon_fall_speed := 1.5    ## m/s
@export var balloon_glide_time := 3.0    ## s, yere inince yenilenir
@export var balloon_air_speed := 5.0     ## m/s

@export_group("Mıknatıs")
@export var magnet_range := 7.0          ## m
@export var magnet_speed := 12.0         ## m/s

@export_group("Kaya")
@export var rock_speed_mult := 0.6       ## × koşu hızı
@export var rock_jump_height := 1.2      ## m
@export var rock_pound_speed := 25.0     ## m/s

@export_group("Pervane")
@export var prop_lift_speed := 4.5       ## m/s, havada zıplama basılı tutulunca yükselme
@export var prop_fuel := 1.2             ## s, yere inince dolar
@export var prop_dash_speed := 11.0      ## m/s, havada Yetenek: ileri atılma
@export var prop_dash_time := 0.25       ## s

@export_group("Buz")
@export var ice_freeze_range := 3.5      ## m, Yetenek: en yakın düşmanı dondur
@export var ice_freeze_time := 8.0       ## s, donmuş düşman buz kütlesi (platform) olur

@export_group("Hasar")
@export var invuln_time := 1.4           ## s
@export var knockback_speed := 7.0       ## m/s

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
var controls_enabled := true   # ara sahnelerde kapatılır

# Yetenek durumu
var nearby_sources: Array = []
var ability_hold := 0.0
var ability_press_used := false
var charging := false
var charge := 0.0
var gliding := false
var glide_left := 3.0
var magnet_state := 0          # 0 yok, 1 çekiliyor, 2 yapışık
var magnet_target := Vector3.ZERO
var magnet_normal := Vector3.ZERO
var _magnet_node: Node = null
var _magnet_last: Node = null
var _magnet_left_at := 0
var pounding := false
var propelling := false
var prop_left := 1.2
var dash_left := 0.0
var dash_used := false
var invuln := 0.0
var wind := Vector3.ZERO       # rüzgâr alanları her kare ekler
var water_level := -INF        # suyun yüzeyi (suda değilse -INF)
var copy_timer := 0.0
var _jump_frame := false
var _magnet_prev: Node = null
var _magnet_pull_time := 0.0
var _vault_dir := Vector3.ZERO
var _vault_time := 0.0
var _squash_tween: Tween


func _ready() -> void:
	add_to_group("player")
	collision_mask = 1 | 2   # 2: küçük süsler (ağaç, kaya, sandık) — Bip çarpar, kamera çarpmaz
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


var ability: String:
	get:
		return GameState.ability


func current_jump_velocity() -> float:
	match ability:
		"yay":
			return sqrt(2.0 * gravity * spring_jump_height)
		"kaya":
			return sqrt(2.0 * gravity * rock_jump_height)
	return jump_velocity


func current_speed() -> float:
	return run_speed * (rock_speed_mult if ability == "kaya" else 1.0)


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	invuln = maxf(invuln - delta, 0.0)
	copy_timer = maxf(copy_timer - delta, 0.0)

	# --- Sayaçlar (coyote time ve zıplama tamponu) ---
	var floating := _in_water() and ability != "kaya" and global_position.y > water_level - 1.2
	if on_floor or floating:
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if controls_enabled and Input.is_action_just_pressed("jump"):
		buffer_timer = jump_buffer
	else:
		buffer_timer = maxf(buffer_timer - delta, 0.0)

	if on_floor:
		glide_left = balloon_glide_time
		prop_left = prop_fuel
		dash_used = false

	if controls_enabled:
		_jump_frame = false
		_handle_ability_input(delta, on_floor)
		if _jump_frame:
			on_floor = false

	# --- Mıknatıs: çekilme ve yapışma ---
	if magnet_state != 0:
		_process_magnet(delta)
		return

	# --- Yatay hareket (kameraya göre) ---
	var input := _get_move_input() if controls_enabled else Vector2.ZERO
	var dir := _camera_relative(input)
	var speed := current_speed()
	if gliding:
		speed = balloon_air_speed
	var target := dir * speed
	if _vault_time > 0.0:
		# Kenara tırmanırken: girdi yoksa duvara doğru ilerlemeye devam et
		_vault_time -= delta
		if input.length() < 0.3:
			target = _vault_dir * 3.5
			if is_on_floor() and _vault_time < 0.45:
				_vault_time = 0.0
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var rate: float = ground_accel if input.length() > 0.01 else ground_decel
	if not on_floor:
		rate *= air_control
	if pounding:
		target = Vector3.ZERO
		rate = 200.0
	if dash_left > 0.0:
		dash_left -= delta
		target = Vector3(sin(facing_yaw), 0, cos(facing_yaw)) * prop_dash_speed
		rate = 400.0
	horizontal = horizontal.move_toward(target, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	# --- Dönüş: hareket yönüne yumuşakça ---
	if dir.length() > 0.05:
		var want := atan2(dir.x, dir.z)
		facing_yaw = rotate_toward(facing_yaw, want, turn_speed * delta)
		rotation.y = facing_yaw

	# --- Zıplama ---
	if buffer_timer > 0.0 and coyote_timer > 0.0 and not pounding:
		do_jump(current_jump_velocity())
		on_floor = false
		if ability == "yay":
			Sfx.play("spring", -4.0)

	# Değişken yükseklik: tuş tepe noktasından önce bırakılırsa yukarı hız kesilir.
	if is_jumping and velocity.y > 0.0 and not Input.is_action_pressed("jump"):
		velocity.y *= jump_cut_mult
		is_jumping = false

	# --- Balon: havada zıplama basılı tutulunca süzülme ---
	var want_glide := ability == "balon" and not on_floor and (gliding or velocity.y <= 0.5) \
			and Input.is_action_pressed("jump") and glide_left > 0.0 and controls_enabled
	if want_glide and not gliding:
		Sfx.play("glide", -8.0)
	gliding = want_glide

	# --- Pervane: havada zıplama basılı tutulunca yükselme (yakıt biter, yerde dolar) ---
	var want_prop := ability == "pervane" and not on_floor and (propelling or velocity.y <= 1.0) \
			and Input.is_action_pressed("jump") and prop_left > 0.0 and controls_enabled
	if want_prop and not propelling:
		Sfx.play("glide", -6.0, 1.4)
	propelling = want_prop

	# --- Yerçekimi ---
	# Yarım adım önce + yarım adım sonra uygulanır: zıplama yüksekliği
	# kare hızından bağımsız olarak tasarımdaki değere eşit çıkar.
	var g := 0.0
	var swimming := _in_water() and ability != "kaya" and water_level - global_position.y > 0.3 and not is_jumping
	if swimming:
		# Bip yüzer: kafası suyun üstünde kalacak şekilde yukarı itilir (Kaya batar)
		var want_vy := clampf((water_level - 0.45 - global_position.y) * 5.0, -3.0, 4.0)
		velocity.y = move_toward(velocity.y, want_vy, 40.0 * delta)
	elif pounding:
		velocity.y = -rock_pound_speed
	elif gliding:
		glide_left -= delta
		velocity.y = maxf(velocity.y - gravity * delta, -balloon_fall_speed)
	elif propelling:
		# Yukarı rüzgârın içinde yakıt harcanmaz ve daha hızlı yükselinir (Fener Kulesi)
		if wind.y <= 0.0:
			prop_left -= delta
		velocity.y = move_toward(velocity.y, prop_lift_speed + maxf(wind.y, 0.0) * 0.3, 40.0 * delta)
	elif dash_left > 0.0:
		velocity.y = maxf(velocity.y, 0.0)
	elif not on_floor:
		g = gravity
		if velocity.y < 0.0:
			g *= fall_gravity_mult
			is_jumping = false
		velocity.y = maxf(velocity.y - g * delta * 0.5, -max_fall_speed)

	# --- Rüzgâr (Kaya etkilenmez; Balon ile süzülürken ya da Pervane ile yükselirken yukarı taşır) ---
	if wind != Vector3.ZERO and ability != "kaya":
		var w := wind
		var lifted := gliding or propelling
		if not lifted:
			w.y *= 0.25
		velocity += w * delta
		if lifted and w.y > 0.0:
			velocity.y = minf(velocity.y + w.y * delta * 2.0, w.y * 0.6)
	wind = Vector3.ZERO

	# --- Su: Kaya yavaşça batar (yüzme yukarıda, yerçekimi yerine) ---
	if _in_water() and ability == "kaya":
		velocity.y = maxf(velocity.y, -3.0)

	var fall_speed := -velocity.y
	move_and_slide()
	if g > 0.0 and not is_on_floor():
		velocity.y = maxf(velocity.y - g * delta * 0.5, -max_fall_speed)

	# Tavana çarpınca yukarı hız sıfırlanır.
	if is_on_ceiling() and velocity.y > 0.0:
		velocity.y = 0.0
		is_jumping = false

	# --- Üstüne basma: düşman, sandık ---
	if fall_speed > 1.0:
		for i in get_slide_collision_count():
			var c := get_slide_collision(i)
			var col := c.get_collider()
			if col and col.is_in_group("stompable") and c.get_normal().y > 0.6 and col.has_method("on_stomp"):
				if pounding and col.has_method("on_pound"):
					col.on_pound(self)
				else:
					col.on_stomp(self)
				break

	# --- İniş ---
	var now_on_floor := is_on_floor()
	if now_on_floor:
		last_floor_y = global_position.y
		if not was_on_floor:
			is_jumping = false
			gliding = false
			var fl := _floor_collider()
			if fl and not fl.is_in_group("metal"):
				_magnet_prev = null
				_magnet_node = null
			if pounding:
				_pound_impact()
			_on_landed(fall_speed)
	was_on_floor = now_on_floor


func do_jump(v: float) -> void:
	_jump_frame = true
	velocity.y = v
	is_jumping = true
	buffer_timer = 0.0
	coyote_timer = 0.0
	_stretch()
	jumped.emit()


## Düşmana basınca ya da trambolinde: tuşa basılıysa daha yükseğe.
func bounce(v: float) -> void:
	velocity.y = v
	is_jumping = Input.is_action_pressed("jump")
	pounding = false
	coyote_timer = 0.0
	_stretch()


func _in_water() -> bool:
	return water_level > -INF and global_position.y < water_level + 0.1


# ---------- Yetenek tuşu ----------

func _handle_ability_input(delta: float, on_floor: bool) -> void:
	if Input.is_action_just_pressed("ability"):
		ability_hold = 0.0
		ability_press_used = false
		var src = best_source()
		# Aynı yeteneğin kaynağının yanında tuş yeteneği kullanır (ör. Kaya kaynağının yanında çakılma)
		if src and src.ability == ability and ability != "":
			src = null
		if src:
			copy_from(src)
			ability_press_used = true
		else:
			match ability:
				"yay":
					if on_floor:
						charging = true
						charge = 0.0
						Sfx.play("charge", -8.0)
				"miknatis":
					_start_magnet()
					ability_press_used = magnet_state != 0
				"kaya":
					if not on_floor and not pounding:
						_start_pound()
						ability_press_used = true
				"pervane":
					if not on_floor and not dash_used:
						dash_used = true
						dash_left = prop_dash_time
						Sfx.play("glide", -2.0, 1.8)
						Haptics.vibrate(20)
						ability_press_used = true
				"buz":
					if _freeze_nearest():
						ability_press_used = true

	if Input.is_action_pressed("ability"):
		ability_hold += delta
		if charging:
			charge = minf(charge + delta, spring_charge_time)
			if not on_floor:
				charging = false
		if ability_hold >= drop_hold_time and ability != "" and not ability_press_used:
			drop_ability()
			ability_press_used = true

	if Input.is_action_just_released("ability"):
		if charging and on_floor and not ability_press_used and ability == "yay":
			var f := charge / spring_charge_time
			if f >= 0.25:
				var h := lerpf(spring_jump_height, spring_charged_height, f)
				do_jump(sqrt(2.0 * gravity * h))
				is_jumping = false  # şarjlı zıplama zıplama tuşuyla kesilmez
				Sfx.play("spring", 0.0, 1.15)
				Haptics.vibrate(30)
		charging = false
		charge = 0.0


func charge_fraction() -> float:
	return charge / spring_charge_time if charging else 0.0


## Yetenek tuşu basılı tutulurken bırakmaya ne kadar kaldı (0..1); arayüz için.
func drop_fraction() -> float:
	if not Input.is_action_pressed("ability") or ability == "" or ability_press_used:
		return 0.0
	return clampf((ability_hold - 0.35) / (drop_hold_time - 0.35), 0.0, 1.0)


func register_source(src: Node) -> void:
	if not nearby_sources.has(src):
		nearby_sources.append(src)


func unregister_source(src: Node) -> void:
	nearby_sources.erase(src)


## Menzildeki kaynaklardan Bip'in baktığı yöne en yakın olanı.
func best_source() -> Node:
	var best: Node = null
	var best_score := INF
	var fwd := Vector3(sin(facing_yaw), 0, cos(facing_yaw))
	for s in nearby_sources:
		if not is_instance_valid(s) or not s.is_visible_in_tree():
			continue
		var to: Vector3 = s.global_position - global_position
		var d := to.length()
		if d > copy_range + 0.6:
			continue
		var score := d - fwd.dot(to.normalized()) * 0.8
		if score < best_score:
			best_score = score
			best = s
	return best


func copy_from(src: Node) -> void:
	var a: String = src.ability
	copy_timer = copy_anim_time
	if a == ability:
		Sfx.play("same", -6.0)
		copied.emit(a)
		return
	_cancel_ability_states()
	GameState.set_ability(a)
	Sfx.play("copy")
	Haptics.vibrate(35)
	if src.has_method("on_copied"):
		src.on_copied()
	copied.emit(a)


func drop_ability() -> void:
	_cancel_ability_states()
	GameState.set_ability("")
	Sfx.play("drop")
	ability_dropped.emit()


func _cancel_ability_states() -> void:
	charging = false
	charge = 0.0
	gliding = false
	pounding = false
	propelling = false
	dash_left = 0.0
	if magnet_state != 0:
		magnet_state = 0


# ---------- Buz ----------

## En yakın düşmanı dondur: buz kütlesine dönüşür, üstüne çıkılabilir (Bölüm 3).
func _freeze_nearest() -> bool:
	var best: Node3D = null
	var best_d := ice_freeze_range
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.has_method("freeze") and not e.get("_dead"):
			var d: float = e.global_position.distance_to(global_position)
			if d < best_d:
				best_d = d
				best = e
	if best:
		best.freeze(ice_freeze_time)
		Sfx.play("glass", 0.0, 1.2)
		Haptics.vibrate(40)
		return true
	Sfx.play("glass", -10.0, 0.8)
	return false


# ---------- Mıknatıs ----------

func _start_magnet() -> void:
	# Yapışıkken ya da bir metalin üstünde dururken: o metal hariç en yakın metale geç.
	# Zincirde geri dönmemek için bir önceki metal de atlanır.
	var skip: Node = null
	var skip2: Node = null
	if magnet_state == 2:
		skip = _magnet_node
		skip2 = _magnet_prev
	elif is_on_floor():
		var fc := _floor_collider()
		if fc == null and _magnet_node:
			fc = _magnet_node   # kenarda duruyor: ışın ıskaladı, son metal varsayılır
		if fc and fc.is_in_group("metal"):
			skip = fc
			skip2 = _magnet_prev if fc == _magnet_node else null
	var best := Vector3.ZERO
	var best_score := INF
	var best_n := Vector3.ZERO
	var best_node: Node = null
	var me := global_position + Vector3.UP * 0.5
	for m in get_tree().get_nodes_in_group("metal"):
		if m == skip or m == skip2 or not m.has_method("closest_point") or not m.is_visible_in_tree():
			continue
		# Az önce bırakılan yüzeye hemen tekrar yapışma: bir sonrakine (tercihen yukarıdakine) git
		if m == _magnet_last and Time.get_ticks_msec() - _magnet_left_at < 1500:
			continue
		var p: Vector3 = m.closest_point(me)
		var d := p.distance_to(me)
		if d > magnet_range:
			continue
		# Yakın, yukarıda ve Bip'in baktığı yönde olan metal tercih edilir
		var fwd := Vector3(sin(facing_yaw), 0, cos(facing_yaw))
		var flat := Vector3(p.x - me.x, 0, p.z - me.z)
		var facing_bonus := fwd.dot(flat.normalized()) * 2.0 if flat.length() > 0.3 else 0.0
		var score := d - clampf(p.y - me.y, -2.0, 4.0) * 0.6 - facing_bonus
		if score < best_score:
			best_score = score
			best = p
			best_n = m.surface_normal(p)
			best_node = m
	if best_node == null:
		if magnet_state == 2:
			_detach_magnet(true)
		return
	magnet_state = 1
	magnet_target = best
	magnet_normal = best_n
	_magnet_prev = _magnet_node if _magnet_node != best_node else _magnet_prev
	_magnet_node = best_node
	_magnet_pull_time = 0.0
	gliding = false
	pounding = false
	Sfx.play("magnet")
	Haptics.vibrate(20)


func _process_magnet(delta: float) -> void:
	var anchor := magnet_target + magnet_normal * 0.42 - Vector3.UP * 0.5
	if magnet_state == 1:
		_magnet_pull_time += delta
		var to := anchor - global_position
		if to.length() < 0.15:
			magnet_state = 2
			velocity = Vector3.ZERO
			Haptics.vibrate(25)
			_on_landed(4.5)
		elif _magnet_pull_time > 1.2:
			# Yol kapalı: çekilmeyi bırak
			magnet_state = 0
			velocity = Vector3.ZERO
		else:
			velocity = to.normalized() * minf(magnet_speed, to.length() / delta)
			move_and_slide()
			if get_slide_collision_count() > 0 and to.length() < 1.0:
				magnet_state = 2
				velocity = Vector3.ZERO
		if magnet_normal.length() > 0.1 and absf(magnet_normal.y) < 0.7:
			facing_yaw = atan2(-magnet_normal.x, -magnet_normal.z)
			rotation.y = facing_yaw
	else:
		velocity = Vector3.ZERO
		global_position = global_position.lerp(anchor, 0.5)
		if controls_enabled and Input.is_action_just_pressed("jump"):
			_detach_magnet(false)
			# Üst kenar yakınsa üstüne tırman; değilse duvardan it.
			var top_y := global_position.y + 100.0
			if _magnet_node and _magnet_node.has_method("closest_point") and absf(magnet_normal.y) < 0.7:
				top_y = _magnet_node.closest_point(global_position + Vector3.UP * 50.0).y
			var rise := top_y - global_position.y
			if rise > -0.5 and rise < 3.2:
				do_jump(sqrt(2.0 * gravity * maxf(rise + 0.7, 1.2)))
				is_jumping = false
				velocity += -magnet_normal * 3.5
				_vault_dir = -magnet_normal
				_vault_time = 0.6
			else:
				do_jump(jump_velocity)
				velocity += magnet_normal * 4.0
			move_and_slide()


## Bip'in altındaki zemin nesnesi (aşağı ışın; son çarpışma kaydı güvenilir değil).
func _floor_collider() -> Object:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_normal().y > 0.6 and c.get_collider():
			return c.get_collider()
	var q := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.3, global_position + Vector3.DOWN * 0.6, 1 | 2, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return hit.collider if hit else null


func _detach_magnet(push: bool) -> void:
	magnet_state = 0
	_magnet_last = _magnet_node
	_magnet_left_at = Time.get_ticks_msec()
	if push:
		velocity = magnet_normal * 3.0


# ---------- Kaya: yere çakılma ----------

func _start_pound() -> void:
	pounding = true
	velocity = Vector3(0, 4.0, 0)  # küçük bir sıçrayış, sonra çakılma
	is_jumping = false
	Sfx.play("charge", -6.0, 0.7)
	await get_tree().create_timer(0.12, false).timeout
	if pounding:
		velocity.y = -rock_pound_speed


func _pound_impact() -> void:
	pounding = false
	Sfx.play("break", 0.0, 0.7)
	Haptics.vibrate(60)
	pounded.emit(global_position)
	for n in get_tree().get_nodes_in_group("poundable"):
		if n.has_method("on_pound") and n.global_position.distance_to(global_position) < 2.2:
			n.on_pound(self)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.35)


# ---------- Hasar ----------

func take_hit(from: Vector3) -> void:
	if invuln > 0.0:
		return
	_cancel_ability_states()
	var result := GameState.take_damage()
	invuln = invuln_time
	var away := global_position - from
	away.y = 0.0
	if away.length() < 0.01:
		away = -Vector3(sin(facing_yaw), 0, cos(facing_yaw))
	velocity = away.normalized() * knockback_speed + Vector3.UP * 7.0
	is_jumping = false
	Sfx.play("ability_lost" if result == "ability" else "hurt")
	Haptics.vibrate(80)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.25)
	hurt.emit(result)


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


## Duraklatmada: zıplama tamponu ve coyote sayaçları sıfırlanır.
func clear_timers() -> void:
	coyote_timer = 0.0
	buffer_timer = 0.0
	charging = false


## Yeniden doğma: konum, hız ve sayaçlar sıfırlanır.
func reset_state(at: Vector3) -> void:
	global_position = at
	velocity = Vector3.ZERO
	coyote_timer = 0.0
	buffer_timer = 0.0
	is_jumping = false
	was_on_floor = true
	last_floor_y = at.y
	_cancel_ability_states()
	magnet_state = 0
	nearby_sources.clear()


# --- Görsel his: zıplarken uzama, inerken ezilme, toz ---

func _stretch() -> void:
	_tween_scale(Vector3(0.8, 1.25, 0.8), Vector3.ONE, 0.08, 0.25)


func _on_landed(fall_speed: float) -> void:
	var t := clampf(fall_speed / max_fall_speed, 0.2, 1.0)
	_tween_scale(Vector3(1.0 + 0.35 * t, 1.0 - 0.35 * t, 1.0 + 0.35 * t), Vector3.ONE, 0.06, 0.2)
	if fall_speed > 4.0:
		dust.restart()
		dust.emitting = true
		Haptics.vibrate(int(20 + 30 * t))
	landed.emit(fall_speed)
	# Ses ve animasyon: scripts/player/bip_visuals.gd (landed sinyalini dinler).


func _tween_scale(peak: Vector3, rest: Vector3, t_in: float, t_out: float) -> void:
	if _squash_tween:
		_squash_tween.kill()
	_squash_tween = create_tween()
	_squash_tween.tween_property(visual, "scale", peak, t_in).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_squash_tween.tween_property(visual, "scale", rest, t_out).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
