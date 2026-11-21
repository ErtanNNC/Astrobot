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
	"ch4_bulut": "res://assets/audio/opengameart/superhero.ogg",
	"ch4_kopru": "res://assets/audio/opengameart/fasttheme.ogg",
	"ch4_kale": "res://assets/audio/opengameart/mechanical_complex.ogg",
	"ch4_patron": "res://assets/audio/opengameart/lsc_boss.ogg",
	"ch5_oyuncak": "res://assets/audio/opengameart/happy_clappy_loop.mp3",
	"ch5_gozlemevi": "res://assets/audio/opengameart/snow_theme_loop.ogg",
	"ch5_volkan": "res://assets/audio/opengameart/fasttheme.ogg",
	"ch5_top": "res://assets/audio/opengameart/happy_clappy_loop.mp3",
	"ch5_sampiyon": "res://assets/audio/opengameart/superhero.ogg",
}

## Ortam sesi (müziğin altında, kısık): alan nerede geçiyorsa oranın sesi. Bkz. docs/features/ses/design.md
const AREA_AMBIENT := {
	"ch1_yay": "birds", "ch1_balon": "wind", "ch1_miknatis": "machine", "ch1_kaya": "wind", "ch1_patron": "wind",
	"ch2_rihtim": "ocean", "ch2_fener": "ocean", "ch2_gemi": "ocean", "ch2_patron": "ocean",
	"ch3_magara": "cave", "ch3_gol": "wind", "ch3_zirve": "wind", "ch3_patron": "wind",
	"ch4_bulut": "wind", "ch4_kopru": "rain", "ch4_kale": "rain", "ch4_patron": "rain",
	"ch5_oyuncak": "birds", "ch5_gozlemevi": "cave", "ch5_volkan": "machine", "ch5_top": "ocean", "ch5_sampiyon": "wind",
}
const MUSIC_FADE_IN := 1.2       ## s
const MUSIC_FADE_OUT := 0.8      ## s
const AMBIENT_DB := -9.0

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
	Settings.apply_graphics.call_deferred()
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
	_move_props_to_layer2.call_deferred()
	_spawn_lost_robots.call_deferred()
	_optimize_rendering.call_deferred()
	for l3 in find_children("*", "Label3D", true, false):
		(l3 as Label3D).text = tr((l3 as Label3D).text)      # seviye tabelaları (Label3D kendiliğinden çevrilmez)
	if has_node("Decor"):
		var react := preload("res://scripts/level/decor_react.gd").new()
		react.name = "DecorReact"
		add_child(react)
		react.setup(get_node("Decor"), bip, area_id)
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
	GameState.note_progress(area_id)
	GameState.set_ability(ability)
	GameState.refill_lives()
	if GameState.data.get("checkpoint_id", "start") == "start":
		GameState.data["area_time"] = 0.0
		GameState.data["start_ability"] = GameState.ability
		_ghost_ok = not safe          # tur baştan başlıyor: kaydedilebilir (öğreticide hayalet yok)
	_start_ability = GameState.data.get("start_ability", "")
	if Settings.ghost_on and not safe and GameState.slot >= 0:
		var run := GhostRun.load_run(GameState.slot, area_id)
		if run.size() >= 8:
			_ghost = GhostRun.new()
			_ghost.samples = run
			add_child(_ghost)
			_ghost.show_at(float(GameState.data.get("area_time", 0.0)))
	_place_bip()
	hud.visible = not safe or GameState.data.get("seen_cutscenes", []).has("health_shown")
	if AREA_MUSIC.has(area_id) and ResourceLoader.exists(AREA_MUSIC[area_id]):
		music = load(AREA_MUSIC[area_id])
	if music:
		var mp: AudioStreamPlayer = rig.get_node("Music")
		mp.stream = music
		if music is AudioStreamMP3 or music is AudioStreamOggVorbis:
			music.loop = true
		mp.add_to_group("music")
		mp.volume_db = -30.0
		mp.play()
		create_tween().tween_property(mp, "volume_db", 0.0, MUSIC_FADE_IN)
	_start_ambient()
	DecorSolid.cover_decor(self)        # iri süslerin içinden geçilmesin
	PlayLog.begin(area_id, GameState.data.get("checkpoint_id", "start") == "start")
	_last_ability = GameState.ability
	GameState.ability_changed.connect(func(a: String):
		if a != "":
			_last_ability = a)
	if title != "":
		hud.banner.call_deferred(title, "", 2.2)
	_announce_moves()


## Kayıp robotlar: her kontrol noktasının yanında (zemin varsa) yardım bekleyen bir robot.
func _spawn_lost_robots() -> void:
	var space := get_world_3d().direct_space_state
	var script := load("res://scripts/entities/lost_robot.gd")
	for cp in get_tree().get_nodes_in_group("checkpoint"):
		var id: String = area_id + "_" + String(cp.checkpoint_id)
		if GameState.data.get("robots", []).has(id):
			continue
		for side in [-1.0, 1.0]:
			var p: Vector3 = cp.global_position + cp.global_basis.x * 2.6 * side + Vector3.UP * 1.5
			var q := PhysicsRayQueryParameters3D.create(p, p + Vector3.DOWN * 2.5, 1, [bip.get_rid()])
			var hit := space.intersect_ray(q)
			if hit and absf(hit.position.y - cp.global_position.y) < 0.6:
				var r: Area3D = Area3D.new()
				r.set_script(script)
				r.robot_id = id
				add_child(r)
				r.global_position = hit.position
				break


func on_robot_rescued() -> void:
	hud.banner("Robot kurtarıldı!", tr("Toplam %d") % GameState.data.get("robots", []).size(), 1.2)


## Ağaç/kaya gibi süs gövdeleri ve sandıklar 2. katmana: Bip çarpar, kamera kolu çarpmaz (ekran sıçramaz).
func _move_props_to_layer2() -> void:
	var decor := get_node_or_null("Decor")
	if decor:
		for b in decor.find_children("*", "StaticBody3D", true, false):
			b.collision_layer = 2
	for c in get_tree().get_nodes_in_group("stompable"):
		if c is StaticBody3D:
			c.collision_layer = 2


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
	_update_goals(_delta)
	if not _completing and bip.controls_enabled:
		var at: float = float(GameState.data.get("area_time", 0.0)) + _delta
		GameState.data["area_time"] = at
		PlayLog.tick(_delta, at)
		# Hayalet: bu turu kaydet, rekor turu oynat
		if _ghost_ok and at >= _ghost_rec.size() / 4 * GhostRun.STEP and _ghost_rec.size() / 4 < GhostRun.MAX_SAMPLES:
			_ghost_rec.append_array(PackedFloat32Array([bip.global_position.x, bip.global_position.y, bip.global_position.z, bip.rotation.y]))
		if _ghost:
			_ghost.show_at(at)
	if bip.global_position.y < kill_height and not _completing:
		_fall()


## Yeniden doğma perdesi inerken düşme her karede tekrar sayılmasın (eskiden tek düşüş bütün canları
## götürüyor, ölüm sayacını şişiriyor ve sahne değişince boşa düşen geri çağrılar bırakıyordu).
var _respawning := false
var _start_ability := ""        ## alana girerkenki yetenek (kaybedince alan bununla baştan başlar)
var _hurt_this_run := false     ## bu turda hasar alındı ya da düşüldü mü ("Çizik Bile Yok" başarımı)
var _ghost: GhostRun
var _ghost_rec := PackedFloat32Array()
var _ghost_ok := false     ## tur alanın başından mı başladı (ortadan devam edilen tur kaydedilmez)


func _fall() -> void:
	if _respawning:
		return
	_respawning = true
	_hurt_this_run = true
	PlayLog.fall(Vector3(bip.global_position.x, bip.last_floor_y, bip.global_position.z))
	Sfx.play("fall")
	_count_death()
	if safe or Settings.easy_mode:      # kolay mod: düşmek can götürmez
		respawn(false)
		return
	var r := GameState.lose_life()
	if r == "dead":
		game_over()
	else:
		respawn(false)


func _on_hurt(result: String) -> void:
	_hurt_this_run = true
	PlayLog.hit(bip.global_position, result)
	if result == "dead":
		_count_death()
		await get_tree().create_timer(0.5, false).timeout
		if safe or Settings.easy_mode:
			respawn(true)           # kolay mod ve öğretici: kaybetmek yok, kontrol noktasından devam
		else:
			game_over()


## Yetenek güvencesi (oynanış kaydından, 2026-11-22): hasar Bip'in yeteneğini alıyor, ama bazı yollar o yetenek olmadan
## geçilemiyor ve yakında kaynak olmayabiliyor (çıkmaz). Kural: kontrol noktası, Bip yeteneksizse bu alanda en son
## taşıdığı yeteneği geri verir; yeniden doğarken de aynı şey olur.
var _last_ability := ""


func _restore_ability(at: Vector3) -> bool:
	if GameState.ability != "" or _last_ability == "":
		return false
	GameState.set_ability(_last_ability)
	Sfx.play("copy", -4.0)
	Fx.burst(at + Vector3.UP * 1.4, AbilityModels.color(_last_ability), 14, 3.5)
	return true


## Üç can da bitti: "Pil bitti!" ekranı. Kontrol noktası kaybedilir; alan baştan başlar ya da Atölye'ye dönülür.
## (Kolay modda ve öğreticide bu ekran çıkmaz.) Kurallar: docs/features/bolum-1/design.md "Can ve kaybetme"
var is_game_over := false
var _over_panel: Control


func game_over() -> void:
	if is_game_over or _completing:
		return
	is_game_over = true
	_respawning = true
	PlayLog.game_over()
	PlayLog.end("over")
	bip.controls_enabled = false
	bip.velocity = Vector3.ZERO
	touch.release_all()
	Sfx.play("ability_lost", 0.0, 0.6)
	Haptics.vibrate(200)
	_fade_audio(-14.0, 0.6)
	Scenes.blink(func():
		if not is_instance_valid(self) or not is_inside_tree():
			return
		_place_bip()
		bip.visual.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var v := UIKit.panel($GameRig/UI, 520)
		_over_panel = v.get_parent().get_parent()
		UIKit.title(v, "Pil bitti!")
		UIKit.title(v, "Üç can da gitti. Alan baştan başlıyor.", 22)
		var again := UIKit.button(v, "Baştan dene", restart_area, UIKit.GREEN)
		UIKit.button(v, "Atölye'ye dön", func(): GameState.refill_lives(); _reset_to_start(); go_home(), UIKit.PURPLE)
		again.grab_focus.call_deferred()
	)


func _reset_to_start() -> void:
	GameState.data["checkpoint_id"] = "start"
	GameState.data["checkpoint_ability"] = _start_ability
	GameState.data["area_time"] = 0.0


## Alanı en baştan yükle (canlar dolu, alana girerkenki yetenekle).
func restart_area() -> void:
	_reset_to_start()
	GameState.set_ability(_start_ability)
	GameState.refill_lives()
	GameState.save(true)
	Scenes.go(GameState.area_info(area_id)["scene"])


## Son kontrol noktasında, o andaki yetenekle başla (Bölüm 1 edge case).
func respawn(refill: bool) -> void:
	_respawning = true
	Scenes.blink(func():
		if not is_instance_valid(self) or not is_inside_tree():
			return
		var ab: String = GameState.data.get("checkpoint_ability", "")
		GameState.set_ability(ab if ab != "" else _last_ability)       # yeteneksiz doğup çıkmaza girmesin
		if refill:
			GameState.refill_lives()
		_place_bip()
		_respawning = false
		var vis := bip.get_node_or_null("Visual")
		if vis and vis.has_method("pop_in"):
			vis.pop_in()
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
			get_tree().create_timer(8.0).timeout.connect(piril.show_hint.bind("", Vector3.ZERO))


func on_checkpoint(cp: Node3D) -> void:
	_respawn = cp
	_restore_ability(cp.global_position)
	PlayLog.checkpoint(String(cp.checkpoint_id), float(GameState.data.get("area_time", 0.0)))
	_deaths_here = 0
	if Settings.easy_mode:
		GameState.refill_lives()        # kolay mod: her kontrol noktası canları doldurur
	elif not safe and GameState.gain_life():
		# Normal mod: her yeni kontrol noktası bir kalp geri verir (kaybetmek mümkün ama acımasız değil)
		Fx.burst(cp.global_position + Vector3.UP * 1.5, Color(1.0, 0.4, 0.5), 12, 3.0)
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

func _start_ambient() -> void:
	if not AREA_AMBIENT.has(area_id):
		return
	var path := "res://assets/audio/opengameart/ambient/amb_%s.ogg" % AREA_AMBIENT[area_id]
	if not ResourceLoader.exists(path):
		return
	var st: AudioStreamOggVorbis = load(path)
	st.loop = true
	var ap := AudioStreamPlayer.new()
	ap.name = "Ambient"
	ap.bus = &"SFX"
	ap.stream = st
	ap.volume_db = -40.0
	$GameRig.add_child(ap)
	ap.play()
	create_tween().tween_property(ap, "volume_db", AMBIENT_DB, 2.0)


## Müziği ve ortam sesini yumuşakça kıs (alan sonu).
func _fade_audio(to_db: float, seconds: float) -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property($GameRig/Music, "volume_db", to_db, seconds)
	var ap: Node = $GameRig.get_node_or_null("Ambient")
	if ap:
		tw.tween_property(ap, "volume_db", -40.0, seconds)


func start_boss() -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss:
		boss.start_fight()
		cam.look_toward(boss.global_position + Vector3.UP * 8.0, 2.5)
		hud.banner(boss.get("boss_name") if boss.get("boss_name") else "Hurdacı Vinç", _phase_hint(boss, 1), 4.0)
		var mp: AudioStreamPlayer = $GameRig/Music
		create_tween().tween_property(mp, "volume_db", 2.0, 0.6)
		_boss_show(boss, true)


func boss_event(what: String) -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	if boss:
		boss.on_event(what)


func boss_phase(p: int) -> void:
	# Her aşama başında kontrol noktası: o aşamadan devam edilir
	var boss := get_tree().get_first_node_in_group("boss")
	hud.banner(tr("Aşama %d") % p, _phase_hint(boss, p), 4.5)
	_goal_t = 0.0
	GameState.data["checkpoint_ability"] = GameState.ability


## Patron giriş ve zafer gösterisi (vay anı; zararsız). Tür patrona göre: docs/features/vay-anlari/design.md
const BOSS_SHOW := {
	"ch1_patron": ["eruption", Vector3(0, 12, 0), 0.8],
	"ch2_patron": ["whale", Vector3(0, -9, -16), 1.6],
	"ch3_patron": ["aurora", Vector3(0, 34, -30), 1.3],
	"ch4_patron": ["lightning", Vector3(0, 0, -14), 1.4],
}


func _boss_show(boss: Node3D, intro: bool) -> void:
	var sp := SetPiece.new()
	var cfg: Array = BOSS_SHOW.get(area_id, ["fireworks", Vector3(0, 8, 0), 1.0])
	sp.kind = cfg[0] if intro else "fireworks"
	sp.offset = cfg[1] if intro else Vector3(0, 9, 0)
	sp.big = cfg[2] if intro else 1.2
	sp.size = Vector3(0.1, 0.1, 0.1)
	sp.collision_mask = 0
	add_child(sp)
	sp.global_position = boss.global_position
	sp.collision_mask = 0
	sp.play()
	if intro:
		Fx.ring(boss.global_position, Color(1.0, 0.4, 0.3), 9.0, 0.8)
		cam.shake(0.4)


func boss_defeated(cell_pos: Vector3) -> void:
	get_tree().create_timer(6.0).timeout.connect(func(): Achievements.refresh())
	var b := get_tree().get_first_node_in_group("boss") as Node3D
	if b:
		_boss_show(b, false)
	var cell := load("res://scripts/entities/core_cell.gd").new() as Node3D
	cell.cell_id = "ch%d" % GameState.chapter_of(area_id)
	add_child(cell)
	cell.global_position = cell_pos


## Gizli köşe ilk kez bulununca: özel müzik, afiş, kayıt (Koleksiyon'da sayılır).
func secret_found(id: String) -> void:
	var key := area_id + "_" + id
	var list: Array = GameState.data.get("secrets", [])
	if list.has(key):
		return
	list.append(key)
	GameState.data["secrets"] = list
	Sfx.play("secret")
	Haptics.vibrate(40)
	hud.banner("Gizli köşe!", tr("Toplam %d") % list.size(), 1.6)


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
	Fx.confetti(bip.global_position + Vector3.UP * 1.8)
	Fx.ring(bip.global_position, Color(1.0, 0.9, 0.35), 3.0, 0.6)
	_fade_audio(-16.0, MUSIC_FADE_OUT)        # bitiş cıngılı duyulsun
	var anim: AnimationPlayer = bip.get_node("Visual/Model/AnimationPlayer")
	anim.play("RobotArmature|Robot_Dance", 0.2)
	var got := GameState.area_battery_count(area_id)
	var res := GameState.finish_area(area_id, float(GameState.data.get("area_time", 0.0)), got, area_total)
	var line := tr("Pil %d / %d  ·  Süre %s") % [got, area_total, GameState.time_text(res["time"])]
	hud.banner("Yeni rekor!" if res["record"] else "Tamam!", line, 3.0)
	hud.show_stars(res["stars"])
	PlayLog.end("done", int(res["stars"]), got, area_total)
	# Bu tur alanın en iyi süresiyse hayalet olarak sakla
	if _ghost_ok and GameState.slot >= 0 and float(res["time"]) <= float(GameState.area_best(area_id).get("time", INF)) + 0.001:
		GhostRun.save_run(GameState.slot, area_id, _ghost_rec)
	Achievements.refresh(["hasarsiz"] if (_ghost_ok and not _hurt_this_run and not safe) else [])
	Daily.add("alan")
	Daily.add("yildiz", res["stars"], true)
	Daily.flush()
	await get_tree().create_timer(3.2).timeout
	var nxt := GameState.next_area(area_id)
	if nxt.is_empty():
		Scenes.go("res://scenes/ui/results.tscn")
		return
	GameState.data["area"] = nxt["id"]
	GameState.note_progress(nxt["id"])
	GameState.data["checkpoint_id"] = "start"
	GameState.data["checkpoint_ability"] = GameState.ability
	GameState.save(true)
	Scenes.go(nxt["scene"])


## Duraklatmadan "Atölye'ye dön": kaydet ve Atölye'ye git (kayıt kural 2).
func go_home() -> void:
	PlayLog.end("home")
	GameState.save(true)
	load("res://scripts/ui/hub.gd").skip_title = true
	Scenes.go("res://scenes/ui/hub.tscn")


func open_pause() -> void:
	if is_game_over:
		return
	touch.release_all()
	bip.clear_timers()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.open()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		# Android geri tuşu oyunu kapatmaz, duraklatır
		if not pause_menu.visible:
			open_pause()
		return
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



## İlerledikçe açılan yeni hareketleri alan başında duyur (her biri bir kez).
func _announce_moves() -> void:
	var moves := GameState.new_moves()
	if moves.is_empty():
		return
	GameState.mark_moves_seen()
	GameState.save(true)
	await get_tree().create_timer(3.0 if title != "" else 1.0, false).timeout
	for m in moves:
		if not is_inside_tree():
			return
		var info: String = tr(GameState.MOVES[m]["info"])
		if TouchInput.last_device == "gamepad":
			info = info.replace(tr("Vuruş butonu"), tr("B tuşu"))
		elif TouchInput.last_device == "keyboard":
			info = info.replace(tr("Vuruş butonu"), tr("F tuşu"))
		hud.banner(tr("Yeni hareket: ") + tr(GameState.MOVES[m]["name"]), info, 3.5)
		Sfx.play("secret", -4.0)
		await get_tree().create_timer(4.5, false).timeout



# ---------- Patron aşaması: ne yapılacağı (yazı + hedef okları) ----------

var _goal_markers := {}   # hedef düğüm → [ok, yükseklik farkı]
var _goal_t := 0.0


func _phase_hint(boss: Node, p: int) -> String:
	if boss == null:
		return ""
	var hints = boss.get("PHASE_HINTS")
	if hints is Array and p >= 1 and p <= hints.size():
		return hints[p - 1]
	return ""


## Sıradaki hedefin üstünde zıplayan sarı ok. Gereken yetenek yoksa önce o yeteneğin kaynağı gösterilir.
func _update_goals(delta: float) -> void:
	_goal_t -= delta
	var boss := get_tree().get_first_node_in_group("boss")
	var bp: int = int(boss.get("phase")) if boss and boss.get("phase") != null else 0
	if _goal_t <= 0.0:
		_goal_t = 0.3
		var goals: Array = []
		if boss and bp >= 1 and bp <= 3 and boss.has_method("goal_nodes"):
			var src: Node3D = null
			var best := INF
			for n in get_tree().get_nodes_in_group("boss_phase"):
				if not (n is Node3D) or int(n.get_meta("phase", 0)) != bp or not n.is_visible_in_tree():
					continue
				if "ability" in n and n.ability != GameState.ability:
					var d: float = n.global_position.distance_to(bip.global_position)
					if d < best:
						best = d
						src = n
				elif n.get("method_name") == "boss_event":
					goals.append(n)
			if src and not _ability_on_hand(bp, boss):
				goals.append(src)
			goals += boss.goal_nodes()
		for g in _goal_markers.keys():
			if not is_instance_valid(g) or not goals.has(g):
				if is_instance_valid(_goal_markers[g][0]):
					_goal_markers[g][0].queue_free()
				_goal_markers.erase(g)
		for g in goals:
			if is_instance_valid(g) and not _goal_markers.has(g):
				_goal_markers[g] = [_make_goal_marker(), _top_offset(g)]
	var t := Time.get_ticks_msec() / 1000.0
	for g in _goal_markers:
		var m: Node3D = _goal_markers[g][0]
		if is_instance_valid(g) and is_instance_valid(m):
			m.global_position = (g as Node3D).global_position + Vector3.UP * (_goal_markers[g][1] + 0.35 * sin(t * 4.0))
			m.rotation.y = t * 2.0


## Bu aşamada gereken yeteneklerden biri Bip'te varsa kaynağı göstermeye gerek yok.
func _ability_on_hand(p: int, _boss: Node) -> bool:
	for n in get_tree().get_nodes_in_group("boss_phase"):
		if int(n.get_meta("phase", 0)) == p and "ability" in n and n.ability == GameState.ability:
			return true
	return false


func _top_offset(n: Node3D) -> float:
	var top := -INF
	for mi in n.find_children("*", "VisualInstance3D", true, false):
		var vi := mi as VisualInstance3D
		var ab: AABB = vi.global_transform * vi.get_aabb()
		top = maxf(top, ab.end.y)
	if top == -INF:
		return 2.2
	return clampf(top - n.global_position.y, 0.5, 14.0) + 1.3


func _make_goal_marker() -> Node3D:
	var root := Node3D.new()
	var cone := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.45
	cm.bottom_radius = 0.0
	cm.height = 0.8
	cm.radial_segments = 4
	cm.rings = 1
	cone.mesh = cm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.85, 0.15)
	mat.no_depth_test = true          # duvarın arkasında da görünsün
	mat.render_priority = 10
	cm.material = mat
	cone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(cone)
	var edge := MeshInstance3D.new()
	var em := CylinderMesh.new()
	em.top_radius = 0.6
	em.bottom_radius = 0.0
	em.height = 1.05
	em.radial_segments = 4
	em.rings = 1
	var emat := StandardMaterial3D.new()
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	emat.albedo_color = Color(0.45, 0.2, 0.05)
	emat.no_depth_test = true
	emat.render_priority = 9
	em.material = emat
	edge.mesh = em
	edge.position.y = 0.05
	edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(edge)
	root.scale = Vector3.ONE * 1.5
	add_child(root)
	return root


## Telefon performansı: uzaktaki küçük nesneler çizilmez, küçük süsler ve bulutlar gölge düşürmez.
## Büyük nesneler (yer işaretleri, patronlar, platformlar) her mesafeden görünür kalır.
func _optimize_rendering() -> void:
	for group_name in ["Entities", "Decor", "Batteries", "Clouds"]:
		var g := get_node_or_null(group_name)
		if g == null:
			continue
		for n in g.find_children("*", "GeometryInstance3D", true, false):
			var gi := n as GeometryInstance3D
			if group_name == "Clouds":
				gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				continue
			var size := gi.get_aabb().size * gi.global_transform.basis.get_scale()
			var big := maxf(size.x, maxf(size.y, size.z))
			if big < 1.3:
				gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if big < 5.0:
				gi.visibility_range_end = 50.0 if group_name == "Batteries" else (60.0 if big < 2.0 else 85.0)
				gi.visibility_range_end_margin = 4.0
