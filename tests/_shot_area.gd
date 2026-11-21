extends Node
## Kullanım: SCENE=res://... SPOTS="x,y,z,yaw;..." godot --path . <bu sahne>
var level
func _ready() -> void:
	GameState.data = GameState.new_data()
	if OS.get_environment("STORE") != "":
		GameState.data["furthest"] = "ch5_volkan"      # bütün hareketler açık, tanıtım yazısı çıkmasın
		GameState.data["moves_seen"] = GameState.unlocked_moves().duplicate()
	level = load(OS.get_environment("SCENE")).instantiate()
	get_tree().root.add_child.call_deferred(level)
	await get_tree().process_frame
	await get_tree().process_frame
	var bip = level.get_node("GameRig/Bip")
	var i := 0
	for spot in OS.get_environment("SPOTS").split(";"):
		var v := spot.split(",")
		if v.size() >= 4:
			var dpos := Vector3(float(v[0]), float(v[1]), float(v[2]))      # tasarım uzayı (köşeli alanlarda çevrilir)
			var yw := float(v[3]) + Turns.yaw(level, dpos)
			bip.reset_state(Turns.world(level, dpos))
			bip.facing_yaw = yw; bip.rotation.y = yw
			if v.size() >= 5 and v[4] != "":
				GameState.set_ability(v[4])
			level.cam.snap_to_target()
		for k in 45: await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(OS.get_environment("SHOT_DIR") + "/%s_%d.png" % [OS.get_environment("PREFIX"), i])
		i += 1
	get_tree().quit()
