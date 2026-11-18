extends Node3D
## Bir alanın yöneticisi: başlangıç/kontrol noktası, düşünce can kaybı, yeniden doğma,
## alan sonu, müzik, duraklatma. Kurallar: docs/features/bolum-1/design.md

@export var area_id := "ch1_yay"
@export var title := ""
@export var music: AudioStream
@export var kill_height := -12.0
@export var safe := false       ## öğretici: düşme ölümü ve can yok
@export var start_ability := "" ## alan bu yetenekle başlar (ör. test)
@export var cam_distance := 0.0  ## 0 = varsayılan (kamera dokümanı); patron gibi geniş alanlarda büyütülür
@export var cam_pitch := 0.0

## Alan müzikleri (hepsi CC0, bkz. CREDITS.md). Burada olan, sahnedeki ayarın önüne geçer.
const AREA_MUSIC := {
	"ch1_atolye": "res://assets/audio/opengameart/happy_adventure_loop.mp3",
	"ch1_yay": "res://assets/audio/opengameart/happy_clappy_loop.mp3",
	"ch1_balon": "res://assets/audio/opengameart/superhero.ogg",
	"ch1_miknatis": "res://assets/audio/opengameart/mechanical_complex.ogg",
	"ch1_kaya": "res://assets/audio/opengameart/fasttheme.ogg",
	"ch1_patron": "res://assets/audio/opengameart/lsc_boss.ogg",
	"ch2_rihtim": "res://assets/audio/opengameart/pacific_ocean.ogg",
	"ch2_fener": "res://assets/audio/opengameart/lsc_ingame.ogg",
	"ch2_gemi": "res://assets/audio/opengameart/superhero.ogg",
	"ch2_patron": "res://assets/audio/opengameart/lsc_boss.ogg",
	"ch3_magara": "res://assets/audio/opengameart/snow_theme_loop.ogg",
	"ch3_gol": "res://assets/audio/opengameart/village_of_snow.ogg",
	"ch3_zirve": "res://assets/audio/opengameart/fasttheme.ogg",
	"ch3_patron": "res://assets/audio/opengameart/lsc_boss.ogg",
}

var area_total := 0
var bip: Bip
var cam
var hud
var touch
var pause_menu
var _start: Node3D
var _respawn: Node3D
var _completing := false
var _deaths_here := 0   ## aynı kontrol noktasından sonra kaç kez ölündü (Bölüm 1 kural 6)


func _ready() -> void:
	var rig := $GameRig
	bip = rig.get_node("Bip")
	cam = rig.get_node("FollowCamera")
	hud = rig.get_node("UI/HUD")
	touch = rig.get_node("UI/TouchControls")
	pause_menu = rig.get_node("UI/PauseMenu")
	_start = get_node_or_null("Start")
	if cam_distance > 0.0:
		cam.distance = cam_distance
	if cam_pitch > 0.0:
		cam.pitch_deg = cam_pitch
	if GameState.data.is_empty():
		GameState.data = GameState.new_data()  # sahne doğrudan açıldıysa (editörde F6)
	touch.pause_pressed.connect(open_pause)
	pause_menu.restart_requested.connect(func(): respawn(false))
	pause_menu.home_requested.connect(go_home)
	bip.hurt.connect(_on_hurt)
	GameState.area_batteries = 0
	GameState.safe_mode = safe
	_count_batteries.call_deferred()
	# Nereden başlıyoruz?
	_respawn = _start
	var ability := start_ability
	if GameState.data.get("area", "") == area_id and GameState.data.get("checkpoint_id", "start") != "start":
		for cp in get_tree().get_nodes_in_group("checkpoint"):
			if cp.checkpoint_id == GameState.data["checkpoint_id"]:
				_respawn = cp
				ability = GameState.data.get("checkpoint_ability", "")
	else:
		GameState.data["area"] = area_id
		GameState.data["checkpoint_id"] = "start"
		ability = GameState.ability if start_ability == "" else start_ability
		GameState.data["checkpoint_ability"] = ability
		GameState.save(true)
	GameState.set_ability(ability)
	GameState.refill_lives()
	_place_bip()
	hud.visible = not safe or GameState.data.get("seen_cutscenes", []).has("health_shown")
	if AREA_MUSIC.has(area_id) and ResourceLoader.exists(AREA_MUSIC[area_id]):
		music = load(AREA_MUSIC[area_id])
	if music:
		var mp: AudioStreamPlayer = rig.get_node("Music")
		mp.stream = music
		if music is AudioStreamMP3 or music is AudioStreamOggVorbis:
			music.loop = true
		mp.play()
	if title != "":
		hud.banner.call_deferred(title, "", 2.2)


func _count_batteries() -> void:
	area_total = get_tree().get_nodes_in_group("battery").size()
	for n in get_tree().get_nodes_in_group("poundable"):
		if "batteries" in n:
			area_total += n.batteries


func _place_bip() -> void:
	var p := _respawn.global_position if _respawn else Vector3.ZERO
	var yaw := _respawn.global_rotation.y if _respawn else 0.0
	bip.reset_state(p + Vector3.UP * 0.1)
	bip.facing_yaw = yaw
	bip.rotation.y = yaw
	cam.snap_to_target()


func _physics_process(_delta: float) -> void:
	if bip.global_position.y < kill_height and not _completing:
		_fall()


func _fall() -> void:
	Sfx.play("fall")
	_count_death()
	if safe:
		respawn(false)
		return
	var r := GameState.lose_life()
	respawn(r == "dead")


func _on_hurt(result: String) -> void:
	if result == "dead":
		_count_death()
		await get_tree().create_timer(0.5, false).timeout
		respawn(true)


## Son kontrol noktasında, o andaki yetenekle başla (Bölüm 1 edge case).
func respawn(refill: bool) -> void:
	Scenes.blink(func():
		GameState.set_ability(GameState.data.get("checkpoint_ability", ""))
		if refill:
			GameState.refill_lives()
		_place_bip()
	)


## Aynı yerde 3 kez ölünürse Pırıl yolu gösterir (ayarlardan kapatılabilir).
func _count_death() -> void:
	_deaths_here += 1
	if _deaths_here >= 3 and Settings.hints_on:
		var piril := get_tree().get_first_node_in_group("piril")
		var best: Node3D = null
		var best_d := INF
		for p in get_tree().get_nodes_in_group("piril_point"):
			var d: float = p.global_position.distance_to(_respawn.global_position if _respawn else bip.global_position)
			if d > 4.0 and d < best_d:
				best_d = d
				best = p
		if piril and best:
			piril.show_hint("jump", best.global_position + Vector3.UP * 1.0)
			get_tree().create_timer(8.0).timeout.connect(func(): piril.show_hint("", Vector3.ZERO))


func on_checkpoint(cp: Node3D) -> void:
	_respawn = cp
	_deaths_here = 0
	GameState.reach_checkpoint(area_id, cp.checkpoint_id)


func on_screw_found() -> void:
	hud.banner("Altın Vida!", "", 1.6)


func open_door(node_name: String) -> void:
	var n := find_child(node_name, true, false)
	if n and n.has_method("open"):
		n.open()
		Sfx.play("open")


## Vadi manzarası: kamera birkaç saniye uzaktaki karanlık kuleye bakar (hikaye).
func vista() -> void:
	var tower := get_tree().get_first_node_in_group("vista_target") as Node3D
	var p := tower.global_position if tower else bip.global_position + Vector3(0, 0, -50)
	cam.look_toward(p, 3.5)


# ---------- Patron ----------

func start_boss() -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss:
		boss.start_fight()
		cam.look_toward(boss.global_position + Vector3.UP * 8.0, 2.5)
		hud.banner("Hurdacı Vinç", "", 1.8)
		var mp: AudioStreamPlayer = $GameRig/Music
		mp.volume_db = 2.0


func boss_event(what: String) -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss:
		boss.on_event(what)


func boss_phase(p: int) -> void:
	# Her aşama başında kontrol noktası: o aşamadan devam edilir
	hud.banner("Aşama %d" % p, "", 1.2)
	GameState.data["checkpoint_ability"] = GameState.ability


func boss_defeated(cell_pos: Vector3) -> void:
	var cell := load("res://scripts/entities/core_cell.gd").new() as Node3D
	cell.cell_id = "ch%d" % GameState.chapter_of(area_id)
	add_child(cell)
	cell.global_position = cell_pos


func show_health() -> void:
	## Öğreticide ilk düşmandan sonra can göstergesi belirir.
	if not GameState.data["seen_cutscenes"].has("health_shown"):
		GameState.data["seen_cutscenes"].append("health_shown")
	hud.visible = true


func complete_area() -> void:
	if _completing:
		return
	_completing = true
	bip.controls_enabled = false
	bip.velocity = Vector3.ZERO
	Sfx.play("clear")
	Haptics.vibrate(120)
	var anim: AnimationPlayer = bip.get_node("Visual/Model/AnimationPlayer")
	anim.play("RobotArmature|Robot_Dance", 0.2)
	var got := GameState.area_battery_count(area_id)
	hud.banner("Tamam!", "Pil %d / %d" % [got, area_total], 2.5)
	await get_tree().create_timer(3.2).timeout
	var nxt := GameState.next_area(area_id)
	if nxt.is_empty():
		Scenes.go("res://scenes/ui/results.tscn")
		return
	GameState.data["area"] = nxt["id"]
	GameState.data["checkpoint_id"] = "start"
	GameState.data["checkpoint_ability"] = GameState.ability
	GameState.save(true)
	Scenes.go(nxt["scene"])


## Duraklatmadan "Atölye'ye dön": kaydet ve Atölye'ye git (kayıt kural 2).
func go_home() -> void:
	GameState.save(true)
	load("res://scripts/ui/hub.gd").skip_title = true
	Scenes.go("res://scenes/ui/hub.tscn")


func open_pause() -> void:
	touch.release_all()
	bip.clear_timers()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.open()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_inside_tree() and OS.has_feature("mobile"):
			GameState.save(true)
			open_pause()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		open_pause()
		get_viewport().set_input_as_handled()
		return
	if OS.has_feature("mobile"):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT \
			and not DisplayServer.is_touchscreen_available():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("restart"):
		respawn(false)
