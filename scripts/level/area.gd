extends Node3D
## Bir alanın yöneticisi: başlangıç/kontrol noktası, düşünce can kaybı, yeniden doğma,
## alan sonu, müzik, duraklatma. Kurallar: docs/features/bolum-1/design.md

@export var area_id := "ch1_yay"
@export var title := ""
@export var music: AudioStream
@export var kill_height := -12.0
@export var safe := false       ## öğretici: düşme ölümü ve can yok
@export var start_ability := "" ## alan bu yetenekle başlar (ör. test)

var area_total := 0
var bip: Bip
var cam
var hud
var touch
var pause_menu
var _start: Node3D
var _respawn: Node3D
var _completing := false


func _ready() -> void:
	var rig := $GameRig
	bip = rig.get_node("Bip")
	cam = rig.get_node("FollowCamera")
	hud = rig.get_node("UI/HUD")
	touch = rig.get_node("UI/TouchControls")
	pause_menu = rig.get_node("UI/PauseMenu")
	_start = get_node_or_null("Start")
	if GameState.data.is_empty():
		GameState.data = GameState.new_data()  # sahne doğrudan açıldıysa (editörde F6)
	touch.pause_pressed.connect(open_pause)
	pause_menu.restart_requested.connect(func(): respawn(false))
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
	if safe:
		respawn(false)
		return
	var r := GameState.lose_life()
	respawn(r == "dead")


func _on_hurt(result: String) -> void:
	if result == "dead":
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


func on_checkpoint(cp: Node3D) -> void:
	_respawn = cp
	GameState.reach_checkpoint(area_id, cp.checkpoint_id)


func on_screw_found() -> void:
	hud.banner("Altın Vida!", "%d / 5" % GameState.data["golden_screws"].size(), 1.6)


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
