extends Node
## Oyunun durumu (autoload: GameState): kayıt yuvası, can, yetenek, toplananlar.
## Kayıt kuralları: docs/features/kayit/design.md
## Can ve hasar kuralları: docs/features/bolum-1/design.md (Rules 2-3)

signal lives_changed(lives: int)
signal batteries_changed(count: int)
signal screws_changed(count: int)
signal ability_changed(ability: String)
signal saving

const SAVE_VERSION := 1
const SLOT_COUNT := 3
const MAX_LIVES := 3
const MIN_SAVE_INTERVAL := 10.0  ## s, art arda kontrol noktalarında gereksiz yazmayı önler

## Bölümler ve alanları, sırasıyla. Sahne yolu ve kısa ad.
const CHAPTERS := {
	1: [
		{"id": "ch1_atolye", "scene": "res://scenes/chapter1/a0_atolye.tscn", "name": "Uyanış Atölyesi"},
		{"id": "ch1_yay", "scene": "res://scenes/chapter1/a1_yay_bahcesi.tscn", "name": "Yay Bahçesi"},
		{"id": "ch1_balon", "scene": "res://scenes/chapter1/a2_balon_kanyonu.tscn", "name": "Balon Kanyonu"},
		{"id": "ch1_miknatis", "scene": "res://scenes/chapter1/a3_miknatis_fabrikasi.tscn", "name": "Mıknatıs Fabrikası"},
		{"id": "ch1_kaya", "scene": "res://scenes/chapter1/a4_kaya_ocagi.tscn", "name": "Kaya Ocağı"},
		{"id": "ch1_patron", "scene": "res://scenes/chapter1/a5_patron.tscn", "name": "Hurdacı Vinç"},
	],
	2: [
		{"id": "ch2_rihtim", "scene": "res://scenes/chapter2/b1_rihtim.tscn", "name": "Liman Rıhtımı"},
		{"id": "ch2_fener", "scene": "res://scenes/chapter2/b2_fener.tscn", "name": "Fener Kulesi"},
		{"id": "ch2_gemi", "scene": "res://scenes/chapter2/b3_gemi_mezarligi.tscn", "name": "Gemi Mezarlığı"},
		{"id": "ch2_patron", "scene": "res://scenes/chapter2/b4_patron.tscn", "name": "Paslı Kaptan"},
	],
	3: [
		{"id": "ch3_magara", "scene": "res://scenes/chapter3/c1_buz_magarasi.tscn", "name": "Buz Mağarası"},
		{"id": "ch3_gol", "scene": "res://scenes/chapter3/c2_donmus_gol.tscn", "name": "Donmuş Göl"},
		{"id": "ch3_zirve", "scene": "res://scenes/chapter3/c3_zirve.tscn", "name": "Kar Zirvesi"},
		{"id": "ch3_patron", "scene": "res://scenes/chapter3/c4_patron.tscn", "name": "Kardan Dev"},
	],
}

const CHAPTER_NAMES := {1: "Uyanış", 2: "Fırtına Limanı", 3: "Buzul Tepesi"}

var slot := -1
var data := {}
var lives := MAX_LIVES
var ability := ""
## Bu oturumda alınan ama henüz kontrol noktasında kaydedilmemiş şeyler de data'ya hemen yazılır;
## pil ve vidalar ölünce kaybolmaz (Bölüm 1, kural 3).
var _last_save_time := -100.0
var _session_start := 0.0
var area_batteries := 0  ## şu anki alanda toplanan pil (sonuç ekranı için)
var safe_mode := false   ## öğretici: can gitmez


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_session_start = Time.get_unix_time_from_system()


static func new_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"chapter": 1,
		"area": "ch1_atolye",
		"checkpoint_id": "start",
		"ability": "",
		"unlocked_abilities": [],
		"batteries": {},
		"golden_screws": [],
		"core_cells": [],
		"seen_cutscenes": [],
		"play_time": 0.0,
		"last_played": 0,
	}


# ---------- Yuvalar ----------

func slot_path(i: int) -> String:
	return "user://slot_%d.json" % i


func slot_summary(i: int) -> Dictionary:
	## Kapsül hologramı için: boşsa {}.
	var d := _read(slot_path(i))
	if d.is_empty():
		d = _read(slot_path(i) + ".bak")
	return d


func start_slot(i: int, fresh: bool) -> void:
	slot = i
	if fresh:
		data = new_data()
	else:
		data = slot_summary(i)
		if data.is_empty():
			data = new_data()
	data = _migrate(data)
	lives = MAX_LIVES
	ability = data.get("ability", "")
	_session_start = Time.get_unix_time_from_system()
	_last_save_time = -100.0
	save(true)


func delete_slot(i: int) -> void:
	for p in [slot_path(i), slot_path(i) + ".bak", slot_path(i) + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


func has_any_save() -> bool:
	for i in SLOT_COUNT:
		if not slot_summary(i).is_empty():
			return true
	return false


func last_played_slot() -> int:
	var best := -1
	var t := -1
	for i in SLOT_COUNT:
		var d := slot_summary(i)
		if not d.is_empty() and int(d.get("last_played", 0)) > t:
			t = int(d.get("last_played", 0))
			best = i
	return best


# ---------- Kaydetme (güvenli yazma: tmp → bak → yerine koy) ----------

func save(force := false) -> void:
	if slot < 0:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if not force and now - _last_save_time < MIN_SAVE_INTERVAL:
		return
	_last_save_time = now
	var t := Time.get_unix_time_from_system()
	data["play_time"] = float(data.get("play_time", 0.0)) + (t - _session_start)
	_session_start = t
	data["last_played"] = int(t)
	data["ability"] = ability
	var path := slot_path(slot)
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("Kayıt yazılamadı: %s" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(path, path + ".bak")
	DirAccess.rename_absolute(tmp, path)
	saving.emit()


func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var txt := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	if int(parsed.get("version", 0)) > SAVE_VERSION:
		return {}  # daha yeni sürümden gelen kayıt reddedilir
	return parsed


func _migrate(d: Dictionary) -> Dictionary:
	# Sürüm 1 ilk sürüm; ileride burada adım adım dönüştürme yapılacak.
	var base := new_data()
	for k in base:
		if not d.has(k):
			d[k] = base[k]
	d["version"] = SAVE_VERSION
	return d


# ---------- Oyun içi ----------

func set_ability(a: String) -> void:
	ability = a
	if a != "" and not data.get("unlocked_abilities", []).has(a):
		data["unlocked_abilities"].append(a)
	ability_changed.emit(a)


func reach_checkpoint(area_id: String, cp_id: String) -> void:
	data["area"] = area_id
	data["checkpoint_id"] = cp_id
	data["checkpoint_ability"] = ability
	save()


func has_battery(area_id: String, id: String) -> bool:
	return data.get("batteries", {}).get(area_id, []).has(id)


func add_battery(area_id: String, id: String) -> void:
	var b: Dictionary = data["batteries"]
	if not b.has(area_id):
		b[area_id] = []
	if not b[area_id].has(id):
		b[area_id].append(id)
	area_batteries += 1
	batteries_changed.emit(total_batteries())


func total_batteries() -> int:
	var n := 0
	for k in data.get("batteries", {}):
		n += data["batteries"][k].size()
	return n


func area_battery_count(area_id: String) -> int:
	return data.get("batteries", {}).get(area_id, []).size()


func has_screw(id: String) -> bool:
	return data.get("golden_screws", []).has(id)


func add_screw(id: String) -> void:
	if not data["golden_screws"].has(id):
		data["golden_screws"].append(id)
	screws_changed.emit(data["golden_screws"].size())
	save(true)


func add_core_cell(id: String) -> void:
	if not data["core_cells"].has(id):
		data["core_cells"].append(id)
	save(true)


func mark_seen(cutscene: String) -> void:
	if not data["seen_cutscenes"].has(cutscene):
		data["seen_cutscenes"].append(cutscene)


## Hasar: önce yetenek gider, yetenek yoksa can (kopyalama kural 5).
## Dönüş: "ability" | "life" | "dead"
func take_damage() -> String:
	if ability != "":
		set_ability("")
		return "ability"
	if safe_mode:
		return "none"
	return lose_life()


func lose_life() -> String:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		return "dead"
	return "life"


func refill_lives() -> void:
	lives = MAX_LIVES
	lives_changed.emit(lives)


# ---------- Alanlar arası ----------

static func chapter_of(area_id: String) -> int:
	if area_id.begins_with("ch") and area_id.length() > 2:
		return clampi(int(area_id.substr(2, 1)), 1, 3)
	return 1


func area_index(area_id: String) -> int:
	var list: Array = CHAPTERS[chapter_of(area_id)]
	for i in list.size():
		if list[i]["id"] == area_id:
			return i
	return 0


func area_info(area_id: String) -> Dictionary:
	return CHAPTERS[chapter_of(area_id)][area_index(area_id)]


## Bölümün sıradaki alanı; bölüm bittiyse {} (sonuç ekranı gelir).
func next_area(area_id: String) -> Dictionary:
	var ch := chapter_of(area_id)
	var i := area_index(area_id) + 1
	if i < CHAPTERS[ch].size():
		return CHAPTERS[ch][i]
	return {}


## Bir sonraki bölümün ilk alanı (yoksa {}).
func first_area_of_next_chapter(area_id: String) -> Dictionary:
	var ch := chapter_of(area_id) + 1
	if CHAPTERS.has(ch) and ResourceLoader.exists(CHAPTERS[ch][0]["scene"]):
		return CHAPTERS[ch][0]
	return {}


func percent_complete() -> int:
	## Kapsül hologramı: alanlar + vidalar + çekirdek piller (tüm oyun).
	var screws: int = data.get("golden_screws", []).size()
	var cores: int = data.get("core_cells", []).size()
	var area: String = data.get("area", "ch1_atolye")
	var ch := chapter_of(area)
	var done_areas := area_index(area)
	for c in range(1, ch):
		done_areas += CHAPTERS[c].size()
	var total_areas := 0
	var total_screws := 0
	for c in CHAPTERS:
		total_areas += CHAPTERS[c].size()
		total_screws += CHAPTERS[c].size() - 1
	return clampi(int(round(done_areas * 50.0 / total_areas + screws * 30.0 / total_screws + cores * 20.0 / 3.0)), 0, 100)
