extends Control
## Bölüm sonu sonuç ekranı: pil, altın vida, süre. Bkz. GDD Core loop (Oturum).

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.2, 0.42)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var v := UIKit.panel(self, 620)
	UIKit.title(v, "Bölüm 1 Tamamlandı!", 46)
	UIKit.title(v, "Uyanış", 30)
	var total := 0
	var lines := []
	for a in GameState.CHAPTERS[1]:
		var n := GameState.area_battery_count(a["id"])
		total += n
		lines.append("%s · %d pil" % [a["name"], n])
	var l := UIKit.title(v, "\n".join(lines), 24)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	UIKit.title(v, "Toplam pil: %d" % total, 32)
	UIKit.title(v, "Altın Vida: %d / 5" % GameState.data.get("golden_screws", []).size(), 32)
	UIKit.title(v, "Çekirdek Pil: %d / 4" % GameState.data.get("core_cells", []).size(), 32)
	var mins := int(float(GameState.data.get("play_time", 0.0)) / 60.0)
	UIKit.title(v, "Süre: %d dk" % mins, 26)
	var b := UIKit.button(v, "Atölye'ye dön", _home, UIKit.GREEN)
	b.grab_focus.call_deferred()
	Sfx.play("clear")
	GameState.save(true)


func _home() -> void:
	load("res://scripts/ui/hub.gd").skip_title = true
	Scenes.go("res://scenes/ui/hub.tscn")
