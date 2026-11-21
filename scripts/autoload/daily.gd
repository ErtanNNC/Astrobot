class_name Daily
extends RefCounted
## Günlük görev: her gün havuzdan bir görev; bitince bonus pil (kostüm ve iz açmaya sayılır) ve seri artar.
## Durum Settings'te tutulur (oyuncuya aittir, kayıt yuvasına değil). Bkz. docs/features/geri-donme/design.md

const REWARD := 15               ## bonus pil
const QUESTS := [
	{"id": "pil", "text": "Bugün %d pil topla", "goal": 40},
	{"id": "dusman", "text": "Bugün %d düşman yen", "goal": 8},
	{"id": "alan", "text": "Bugün %d alan bitir", "goal": 2},
	{"id": "yildiz", "text": "Bir alanı %d yıldızla bitir", "goal": 3},
]


static func _day() -> int:
	var tz: int = Time.get_time_zone_from_system().get("bias", 0) * 60
	return int((Time.get_unix_time_from_system() + tz) / 86400.0)


## Gün değiştiyse yeni görevi kur; dün bitirilmediyse seri sıfırlanır.
static func refresh() -> void:
	var d := _day()
	if Settings.daily_day == d:
		return
	if not (Settings.daily_day == d - 1 and Settings.daily_done):
		Settings.daily_streak = 0
	Settings.daily_day = d
	Settings.daily_progress = 0
	Settings.daily_done = false
	Settings.save_settings()


static func quest() -> Dictionary:
	refresh()
	return QUESTS[posmod(Settings.daily_day, QUESTS.size())]


## Menüde gösterilen satır.
static func line() -> String:
	var q := quest()
	var t: String = TranslationServer.translate(q["text"]) % int(q["goal"])
	if Settings.daily_done:
		return TranslationServer.translate("Günlük görev tamam! Seri: %d gün") % Settings.daily_streak
	return TranslationServer.translate("Günlük görev: %s (%d/%d)") % [t, mini(Settings.daily_progress, int(q["goal"])), int(q["goal"])]


## İlerleme bildir. best=true ise sayaç toplanmaz, en yüksek değer tutulur (yıldız görevi).
static func add(kind: String, n := 1, best := false) -> void:
	var q := quest()
	if Settings.daily_done or q["id"] != kind:
		return
	Settings.daily_progress = maxi(Settings.daily_progress, n) if best else Settings.daily_progress + n
	if Settings.daily_progress < int(q["goal"]):
		return
	Settings.daily_done = true
	Settings.daily_streak += 1
	Settings.bonus_batteries += REWARD
	Settings.save_settings()
	Sfx.play("secret")
	var sc := (Engine.get_main_loop() as SceneTree).current_scene
	if sc and sc.get("hud") and sc.hud.has_method("banner"):
		sc.hud.banner("Günlük görev tamam!", TranslationServer.translate("+%d pil") % REWARD, 2.4)


## Yarım kalan ilerlemeyi diske yaz (alan sonu, kontrol noktası).
static func flush() -> void:
	Settings.save_settings()
