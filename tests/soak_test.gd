extends Node
## Dayanıklılık testi: her alanda Bip rastgele koşar, zıplar, yetenek kullanır; çalışma hatası aranır.
## Çalıştırma: godot --headless --path . tests/soak_test.tscn  (çıktıda SCRIPT ERROR olmamalı)
const ACTIONS := ["move_forward", "move_left", "move_right", "move_back", "jump", "ability", "camera_left"]
const ABILITIES := ["", "yay", "balon", "miknatis", "kaya", "pervane", "buz"]

func _ready() -> void:
	seed(42)
	var scenes := ["res://scenes/ui/hub.tscn"]
	for ch in GameState.CHAPTERS:
		for a in GameState.CHAPTERS[ch]:
			scenes.append(a["scene"])
	if OS.has_environment("SOAK_ONLY"):
		scenes = Array(OS.get_environment("SOAK_ONLY").split(","))
	var frames := int(OS.get_environment("SOAK_FRAMES")) if OS.has_environment("SOAK_FRAMES") else 1200
	for path in scenes:
		GameState.data = GameState.new_data()
		GameState.slot = -1
		var level = load(path).instantiate()
		get_tree().root.add_child.call_deferred(level)
		await get_tree().process_frame
		await get_tree().process_frame
		get_tree().current_scene = level
		var bip = level.get_node_or_null("GameRig/Bip")
		if level.has_method("start_boss"):
			level.start_boss()
		for t in frames:
			await get_tree().physics_frame
			if t % 20 == 0:
				for a in ACTIONS:
					Input.action_release(a)
				Input.action_press(ACTIONS[randi() % ACTIONS.size()])
				if randf() < 0.5:
					Input.action_press("move_forward")
			if t % 240 == 0 and bip:
				GameState.set_ability(ABILITIES[randi() % ABILITIES.size()])
				bip.invuln = 0.0
		for a in ACTIONS:
			Input.action_release(a)
		print("bitti: ", path.get_file(), " bip ", bip.global_position.snapped(Vector3.ONE) if bip else "-", " can ", GameState.lives)
		level.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	print("SOAK BİTTİ")
	get_tree().quit()
