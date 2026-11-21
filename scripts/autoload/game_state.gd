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
	4: [
		{"id": "ch4_bulut", "scene": "res://scenes/chapter4/d1_bulut_basamaklari.tscn", "name": "Bulut Basamakları"},
		{"id": "ch4_kopru", "scene": "res://scenes/chapter4/d1b_firtina_kopruleri.tscn", "name": "Fırtına Köprüleri"},
		{"id": "ch4_kale", "scene": "res://scenes/chapter4/d2_kivilcim_kalesi.tscn", "name": "Kıvılcım Kalesi"},
		{"id": "ch4_patron", "scene": "res://scenes/chapter4/d3_patron.tscn", "name": "Statik"},
	],
	# Bonus bölüm (2026-11-21): final sonrası açılır, patron yok; bütün yetenekler karışık
	5: [
		{"id": "ch5_oyuncak", "scene": "res://scenes/chapter5/e1_oyuncak_kasabasi.tscn", "name": "Oyuncak Kasabası"},
		{"id": "ch5_gozlemevi", "scene": "res://scenes/chapter5/e2_yildiz_gozlemevi.tscn", "name": "Yıldız Gözlemevi"},
		{"id": "ch5_volkan", "scene": "res://scenes/chapter5/e3_volkan_adasi.tscn", "name": "Volkan Adası"},
		{"id": "ch5_top", "scene": "res://scenes/chapter5/e3b_top_adalari.tscn", "name": "Top Adaları"},
		{"id": "ch5_sampiyon", "scene": "res://scenes/chapter5/e4_sampiyon_yolu.tscn", "name": "Şampiyon Yolu"},
	],
}

## Bip'in kostümleri (renk). Kilit: kayıt yuvalarındaki en çok pil (ya da Altın Vida) sayısı.
## hue: ton kaydırma (0..1), sat/val: doygunluk/parlaklık çarpanı. Bkz. docs/features/kostum/design.md
const SKINS := [
	{"id": "klasik", "name": "Klasik Sarı", "hue": 0.0, "sat": 1.0, "val": 1.0, "need": 0},
	{"id": "gok", "name": "Gökyüzü", "hue": 0.45, "sat": 1.0, "val": 1.0, "need": 60},
	{"id": "nane", "name": "Nane", "hue": 0.22, "sat": 0.9, "val": 1.0, "need": 150},
	{"id": "seker", "name": "Pamuk Şeker", "hue": 0.78, "sat": 0.75, "val": 1.08, "need": 250},
	{"id": "lav", "name": "Lav", "hue": -0.11, "sat": 1.15, "val": 0.95, "need": 400},
	{"id": "gece", "name": "Gece", "hue": 0.6, "sat": 0.35, "val": 0.55, "need": 600},
	{"id": "altin", "name": "Altın", "hue": -0.02, "sat": 1.25, "val": 1.15, "need_screws": 10, "glow": 0.35},
]

## Koşu izleri: pille açılır, Kostüm Dolabı'ndan seçilir (docs/features/geri-donme/design.md)
const TRAILS := [
	{"id": "yok", "name": "İz yok", "need": 0},
	{"id": "kivilcim", "name": "Kıvılcım", "need": 100, "color": Color(1.0, 0.85, 0.3)},
	{"id": "buz", "name": "Buz Tozu", "need": 200, "color": Color(0.6, 0.9, 1.0)},
	{"id": "kalp", "name": "Şeker Pembe", "need": 350, "color": Color(1.0, 0.5, 0.75)},
	{"id": "gokkusagi", "name": "Gökkuşağı", "need": 500, "rainbow": true},
]

## Şapkalar: yıldızla açılır (herhangi bir yuvadaki en çok yıldız), Kostüm Dolabı'ndan seçilir (scripts/player/hat_models.gd)
const HATS := [
	{"id": "yok", "name": "Şapka yok", "need": 0},
	{"id": "parti", "name": "Parti Şapkası", "need": 5},
	{"id": "pervane", "name": "Pervaneli Şapka", "need": 12},
	{"id": "silindir", "name": "Silindir Şapka", "need": 20},
	{"id": "tac", "name": "Taç", "need": 35},
]

## Hedef süre (s): altında bitiren üçüncü yıldızı alır. Yol uzunluğundan hesaplandı (25 + 0,8 × metre), telefonda
## oynanarak ayarlanmalı [ASSUMPTION]. Patron alanları 180.
const AREA_PAR := {
	"ch1_atolye": 110, "ch1_yay": 180, "ch1_balon": 120, "ch1_miknatis": 170, "ch1_kaya": 160,
	"ch2_rihtim": 125, "ch2_fener": 150, "ch2_gemi": 135,
	"ch3_magara": 110, "ch3_gol": 135, "ch3_zirve": 180,
	"ch4_bulut": 140, "ch4_kopru": 140, "ch4_kale": 130,
	"ch5_oyuncak": 115, "ch5_gozlemevi": 130, "ch5_volkan": 140, "ch5_top": 90, "ch5_sampiyon": 165,
}
const PAR_DEFAULT := 180
const STAR_BATTERY_SHARE := 0.8  ## ikinci yıldız: alandaki pillerin bu kadarı

## Gizli köşe tetikleyicisi sayısı (tools/level/*.py içindeki L.secret çağrıları; yeni ekleyince güncelle)
const SECRET_TOTAL := 30

const CHAPTER_NAMES := {1: "Uyanış", 2: "Fırtına Limanı", 3: "Buzul Tepesi", 4: "Fırtınanın Gözü", 5: "Gizli Adalar"}

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
		"secrets": [],
		"best": {},              # alan → {"time": s, "stars": 0-3}
		"area_time": 0.0,        # şu anki alanda geçen süre (kontrol noktasıyla birlikte kaydedilir)
		"golden_screws": [],
		"core_cells": [],
		"seen_cutscenes": [],
		"furthest": "ch1_atolye",
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
	GhostRun.delete_slot(i)
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


## Toplam Altın Vida sayısı: patron dışındaki her alanda bir tane.
func screw_total() -> int:
	var n := 0
	for ch in CHAPTERS:
		for a in CHAPTERS[ch]:
			if not String(a["id"]).ends_with("patron"):
				n += 1
	return n


func skin_info(id: String) -> Dictionary:
	for sk in SKINS:
		if sk["id"] == id:
			return sk
	return SKINS[0]


## Kostüm açık mı? Herhangi bir kayıt yuvasındaki en iyi ilerlemeye bakar (kostüm oyuncunundur, yuvanın değil).
func skin_unlocked(id: String) -> bool:
	var sk := skin_info(id)
	var best_b := 0
	var best_s := 0
	for i in SLOT_COUNT:
		var d := slot_summary(i)
		var b := 0
		for k in d.get("batteries", {}):
			b += d["batteries"][k].size()
		best_b = maxi(best_b, b)
		best_s = maxi(best_s, d.get("golden_screws", []).size())
	if data.has("batteries"):
		best_b = maxi(best_b, total_batteries())
		best_s = maxi(best_s, data.get("golden_screws", []).size())
	if sk.has("need_screws"):
		return best_s >= int(sk["need_screws"])
	return best_b + Settings.bonus_batteries >= int(sk.get("need", 0))


## Kostüm ve iz açmada sayılan pil: yuvalardaki en iyi toplam + günlük görev bonusu.
func best_batteries() -> int:
	var best_b := 0
	for i in SLOT_COUNT:
		var d := slot_summary(i)
		var b := 0
		for k in d.get("batteries", {}):
			b += d["batteries"][k].size()
		best_b = maxi(best_b, b)
	if data.has("batteries"):
		best_b = maxi(best_b, total_batteries())
	return best_b + Settings.bonus_batteries


func trail_info(id: String) -> Dictionary:
	for t in TRAILS:
		if t["id"] == id:
			return t
	return TRAILS[0]


func trail_unlocked(id: String) -> bool:
	return best_batteries() >= int(trail_info(id).get("need", 0))


## Şapka açmada sayılan yıldız: yuvalardaki en çok toplam yıldız.
func best_stars() -> int:
	var best_n := total_stars() if data.has("best") else 0
	for i in SLOT_COUNT:
		var n := 0
		var b: Dictionary = slot_summary(i).get("best", {})
		for k in b:
			n += int(b[k].get("stars", 0))
		best_n = maxi(best_n, n)
	return best_n


func hat_info(id: String) -> Dictionary:
	for h in HATS:
		if h["id"] == id:
			return h
	return HATS[0]


func hat_unlocked(id: String) -> bool:
	return best_stars() >= int(hat_info(id).get("need", 0))


# ---------- Yıldızlar ve rekor süre ----------

func area_par(area_id: String) -> int:
	return int(AREA_PAR.get(area_id, PAR_DEFAULT))


func area_best(area_id: String) -> Dictionary:
	return data.get("best", {}).get(area_id, {})


func total_stars() -> int:
	var n := 0
	for k in data.get("best", {}):
		n += int(data["best"][k].get("stars", 0))
	return n


static func time_text(seconds: float) -> String:
	var s := int(round(seconds))
	return "%d:%02d" % [s / 60, s % 60]


## Alan bitti: yıldızları hesapla, rekoru sakla. Dönen: {"stars", "time", "record", "par"}
##   1. yıldız: alanı bitir · 2. yıldız: pillerin %80'i · 3. yıldız: hedef sürenin altı
func finish_area(area_id: String, seconds: float, got: int, total: int) -> Dictionary:
	var stars := 1
	if total <= 0 or got >= int(ceil(total * STAR_BATTERY_SHARE)):
		stars += 1
	if seconds <= area_par(area_id):
		stars += 1
	if not data.has("best"):
		data["best"] = {}
	var old: Dictionary = data["best"].get(area_id, {})
	var record: bool = old.is_empty() or seconds < float(old.get("time", INF))
	data["best"][area_id] = {
		"time": seconds if record else float(old["time"]),
		"stars": maxi(stars, int(old.get("stars", 0))),
	}
	return {"stars": stars, "time": seconds, "record": record and not old.is_empty(), "par": area_par(area_id)}


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


## Bir can geri kazan (yeni kontrol noktası). Zaten doluysa bir şey olmaz.
func gain_life() -> bool:
	if lives >= MAX_LIVES:
		return false
	lives += 1
	lives_changed.emit(lives)
	return true


func refill_lives() -> void:
	lives = MAX_LIVES
	lives_changed.emit(lives)


# ---------- Alanlar arası ----------

static func chapter_of(area_id: String) -> int:
	if area_id.begins_with("ch") and area_id.length() > 2:
		return clampi(int(area_id.substr(2, 1)), 1, CHAPTERS.size())
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


## Tüm oyundaki sıra numarası (Bölüm 1'in ilk alanı 0).
func global_index(area_id: String) -> int:
	var n := 0
	for ch in CHAPTERS:
		for a in CHAPTERS[ch]:
			if a["id"] == area_id:
				return n
			n += 1
	return 0


# ---------- Temel hareketler (ilerledikçe açılır) ----------
## Sıra ve açıldığı yer: tutunma baştan, dönme Atölye'den sonra, atılma Bölüm 1 sonu,
## duvar zıplaması Bölüm 2 sonu, çift zıplama Bölüm 3 sonu. Bkz. docs/features/hareket/design.md
const MOVES := {
	"ledge": {"name": "Kenara Tutunma", "after": "", "info": "Zıplaman kısa kalırsa kenara tutun; zıpla ya da ileri bas, yukarı çık."},
	"spin": {"name": "Dönme Saldırısı", "after": "ch1_yay", "info": "Vuruş butonu: dönerek düşmanları ve sandıkları vur. Havada kısa süre asılı kalırsın."},
	"dash": {"name": "Havada Atılma", "after": "ch2_rihtim", "info": "Havadayken Vuruş butonu: ileri doğru hamle yap."},
	"wall": {"name": "Duvar Zıplaması", "after": "ch3_magara", "info": "Duvara doğru düşerken kayarsın; zıpla, karşıya sek."},
	"double": {"name": "Çift Zıplama", "after": "ch4_bulut", "info": "Havadayken bir kez daha zıpla."},
}

var _moves_key := ""
var _moves_cache: Array = []


func unlocked_moves() -> Array:
	var f: String = data.get("furthest", data.get("area", "ch1_atolye"))
	var done: bool = data.get("game_complete", false)
	var key := f + str(done)
	if key != _moves_key:
		_moves_key = key
		_moves_cache = []
		var fi := global_index(f)
		for m in MOVES:
			var after: String = MOVES[m]["after"]
			if after == "" or done or fi >= global_index(after):
				_moves_cache.append(m)
	return _moves_cache


func has_move(m: String) -> bool:
	return unlocked_moves().has(m)


## Henüz duyurulmamış açılmış hareketler (alan başında "Yeni hareket!" için).
func new_moves() -> Array:
	var seen: Array = data.get("moves_seen", [])
	var out := []
	for m in unlocked_moves():
		if m != "ledge" and not seen.has(m):
			out.append(m)
	return out


func mark_moves_seen() -> void:
	data["moves_seen"] = unlocked_moves().duplicate()


## Ulaşılan en ileri alanı güncelle (alan seçimi ve "Devam" için).
func note_progress(area_id: String) -> void:
	var f: String = data.get("furthest", "ch1_atolye")
	if global_index(area_id) > global_index(f):
		data["furthest"] = area_id


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
	total_screws = screw_total()
	return clampi(int(round(done_areas * 50.0 / total_areas + screws * 30.0 / total_screws + cores * 20.0 / 4.0)), 0, 100)
