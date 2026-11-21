class_name PlayLog
extends RefCounted
## Oynanış kaydı: her alan turunda ne olduğunu (süre, düşülen/hasar alınan yerler, kaybetme, kare hızı) telefonda
## bir dosyaya yazar. Hiçbir yere gönderilmez; geliştirici Ayarlar → "Oynanış kaydını kopyala" ile panoya alıp
## kendisi paylaşır. İçinde kişisel bilgi yoktur (telefon modeli ve ekran boyu dışında).
## Kurallar: docs/features/oynanis-kaydi/design.md

const PATH := "user://playlog.json"
const MAX_RUNS := 300
const MAX_POINTS := 40            ## tur başına en çok düşme/hasar noktası
const PREFIX := "BIPLOG1:"

static var _runs: Array = []
static var _loaded := false
static var _cur: Dictionary = {}
static var _fps_sum := 0.0
static var _fps_n := 0
static var _fps_t := 0.0


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	if FileAccess.file_exists(PATH):
		var j = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if j is Array:
			_runs = j


static func _save() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_runs))
		f.close()


static func count() -> int:
	_load()
	return _runs.size()


static func clear() -> void:
	_runs = []
	_cur = {}
	_loaded = true
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


## Alan açıldı (yeni tur). from_start: alanın başından mı, kontrol noktasından mı.
static func begin(area_id: String, from_start: bool) -> void:
	_load()
	end("leave")                   # yarım kalan tur varsa kapat
	_cur = {"a": area_id, "t": int(Time.get_unix_time_from_system()), "s": from_start, "easy": Settings.easy_mode,
			"falls": [], "hits": [], "cp": [], "over": 0, "dur": 0.0, "fmin": 999, "favg": 0}
	_fps_sum = 0.0
	_fps_n = 0
	_fps_t = -3.0                  # ilk üç saniye (yükleme takılması) sayılmaz


static func _pt(p: Vector3) -> Array:
	return [snappedf(p.x, 0.1), snappedf(p.y, 0.1), snappedf(p.z, 0.1)]


static func fall(at: Vector3) -> void:
	if not _cur.is_empty() and _cur["falls"].size() < MAX_POINTS:
		_cur["falls"].append(_pt(at))


static func hit(at: Vector3, result: String) -> void:
	if not _cur.is_empty() and _cur["hits"].size() < MAX_POINTS:
		_cur["hits"].append(_pt(at) + [result.left(1)])        # a = yetenek gitti, l = can gitti, d = son can


static func checkpoint(id: String, t: float) -> void:
	if not _cur.is_empty():
		_cur["cp"].append([id, snappedf(t, 0.1)])


static func game_over() -> void:
	if not _cur.is_empty():
		_cur["over"] = int(_cur["over"]) + 1


## Her karede: saniyede bir kare hızı örneği.
static func tick(delta: float, area_time: float) -> void:
	if _cur.is_empty():
		return
	_cur["dur"] = snappedf(area_time, 0.1)
	_fps_t += delta
	if _fps_t >= 1.0:
		_fps_t = 0.0
		var f := Engine.get_frames_per_second()
		_fps_sum += f
		_fps_n += 1
		_cur["fmin"] = mini(int(_cur["fmin"]), int(f))
		_cur["favg"] = int(_fps_sum / _fps_n)


## Tur bitti. how: "done" (alan tamam), "over" (pil bitti → baştan), "home" (Atölye'ye dönüldü), "leave" (başka).
static func end(how: String, stars := 0, batteries := 0, total := 0) -> void:
	if _cur.is_empty():
		return
	_cur["end"] = how
	if how == "done":
		_cur["stars"] = stars
		_cur["bat"] = [batteries, total]
	if int(_cur["fmin"]) == 999:
		_cur["fmin"] = 0
	_runs.append(_cur)
	_cur = {}
	while _runs.size() > MAX_RUNS:
		_runs.pop_front()
	_save()


## Paylaşılacak metin: sıkıştırılmış, tek satır. Çözmek için: tools/playlog/decode.py
static func export_text() -> String:
	_load()
	var info := {
		"v": ProjectSettings.get_setting("application/config/version", ""),
		"dev": OS.get_model_name(), "os": OS.get_name(),
		"scr": [DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y],
		"q": Settings.quality, "shadows": Settings.shadows_on, "lang": Settings.current_language(),
		"runs": _runs,
	}
	var raw := JSON.stringify(info).to_utf8_buffer()
	return PREFIX + Marshalls.raw_to_base64(raw.compress(FileAccess.COMPRESSION_GZIP))
