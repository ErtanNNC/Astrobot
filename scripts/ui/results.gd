extends Control
## Bölüm sonu sonuç ekranı: pil, altın vida, süre. Bkz. GDD Core loop (Oturum).

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.2, 0.42)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var v := UIKit.panel(self, 620)
	var area: String = GameState.data.get("area", "ch1_patron")
	var ch := GameState.chapter_of(area)
	UIKit.title(v, "Bölüm %d Tamamlandı!" % ch, 46)
	UIKit.title(v, GameState.CHAPTER_NAMES.get(ch, ""), 30)
	var total := 0
	var lines := []
	for a in GameState.CHAPTERS[ch]:
		var n := GameState.area_battery_count(a["id"])
		total += n
		lines.append("%s · %d pil" % [a["name"], n])
	var l := UIKit.title(v, "\n".join(lines), 24)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	UIKit.title(v, "Toplam pil: %d" % total, 32)
	var chapter_screws := 0
	for a in GameState.CHAPTERS[ch]:
		if GameState.has_screw(a["id"] + "_vida"):
			chapter_screws += 1
	UIKit.title(v, "Altın Vida: %d / %d" % [chapter_screws, GameState.CHAPTERS[ch].size() - 1], 32)
	UIKit.title(v, "Çekirdek Pil: %d / 4" % GameState.data.get("core_cells", []).size(), 32)
	if GameState.data.get("game_complete", false):
		UIKit.title(v, "Tüm oyun: %d pil · Altın Vida %d / 13" % [GameState.total_batteries(), GameState.data.get("golden_screws", []).size()], 26)
	var mins := int(float(GameState.data.get("play_time", 0.0)) / 60.0)
	UIKit.title(v, "Süre: %d dk" % mins, 26)
	var b := UIKit.button(v, "Atölye'ye dön", _home, UIKit.GREEN)
	b.grab_focus.call_deferred()
	Sfx.play("clear")
	# Sıradaki bölüm varsa Atölye kapısı oradan devam eder
	var nxt := GameState.first_area_of_next_chapter(area)
	if not nxt.is_empty():
		GameState.data["area"] = nxt["id"]
		GameState.note_progress(nxt["id"])
		GameState.data["chapter"] = ch + 1
		GameState.data["checkpoint_id"] = "start"
		GameState.data["checkpoint_ability"] = ""
		GameState.set_ability("")
		var b2 := UIKit.button(v, "Bölüm %d: %s" % [ch + 1, GameState.CHAPTER_NAMES[ch + 1]], func(): Scenes.go(nxt["scene"]), UIKit.BLUE)
		v.move_child(b2, v.get_child_count() - 2)
	GameState.save(true)


func _home() -> void:
	load("res://scripts/ui/hub.gd").skip_title = true
	Scenes.go("res://scenes/ui/hub.tscn")
