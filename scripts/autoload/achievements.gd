class_name Achievements
extends RefCounted
## Başarımlar: çoğu kayıt verisinden hesaplanır (ayrı sayaç tutmaya gerek yok). Kazanılanlar Settings'te saklanır
## (oyuncuya aittir). Her başarım REWARD bonus pil verir. Kurallar: docs/features/basarimlar/design.md

const REWARD := 10               ## bonus pil
## kimlik, ad, açıklama
const LIST := [
	["ilk_adim", "İlk Adım", "Uyanış Atölyesi'ni bitir"],
	["bolum1", "Vinç Avcısı", "Hurdacı Vinç'i yen"],
	["bolum2", "Kaptan Kim?", "Paslı Kaptan'ı yen"],
	["bolum3", "Kar Erir", "Kardan Dev'i yen"],
	["bolum4", "Fırtına Dindi", "Statik'i ikna et"],
	["bonus", "Şampiyon", "Şampiyon Yolu'nu bitir"],
	["vida_5", "Vida Meraklısı", "5 Altın Vida bul"],
	["vida_hepsi", "Vida Ustası", "Bütün Altın Vidaları bul"],
	["gizli_10", "Meraklı Robot", "10 gizli köşe bul"],
	["gizli_hepsi", "Hiçbir Köşe Gizli Kalmaz", "Bütün gizli köşeleri bul"],
	["pil_250", "Dolu Batarya", "250 pil topla"],
	["pil_600", "Enerji Santrali", "600 pil topla"],
	["uc_yildiz", "Parlak Tur", "Bir alanı 3 yıldızla bitir"],
	["yildiz_10", "Yıldız Toplayıcı", "10 yıldız kazan"],
	["yildiz_30", "Yıldız Yağmuru", "30 yıldız kazan"],
	["yildiz_hepsi", "Gökyüzü Senin", "Bütün yıldızları kazan"],
	["hizli", "Rüzgâr Gibi", "Bir alanı hedef sürenin dörtte üçünde bitir"],
	["hasarsiz", "Çizik Bile Yok", "Bir alanı hiç hasar almadan bitir"],
	["seri_3", "Alışkanlık", "3 gün üst üste günlük görevi bitir"],
	["seri_7", "Bir Hafta!", "7 gün üst üste günlük görevi bitir"],
	["kostum", "Yeni Ben", "Başka bir kostüm giy"],
	["iz", "İz Bırak", "Bir koşu izi seç"],
]


static func has(id: String) -> bool:
	return Settings.achievements.has(id)


static func count() -> int:
	return Settings.achievements.size()


## Kayıt verisine göre şu an hak edilen başarımlar ("hasarsiz" hariç; o olayla verilir).
static func earned(d: Dictionary) -> Array:
	var out := []
	var best: Dictionary = d.get("best", {})
	var cells: Array = d.get("core_cells", [])
	var stars := 0
	var areas := 0
	var three := false
	var fast := false
	for k in best:
		var st := int(best[k].get("stars", 0))
		stars += st
		three = three or st >= 3
		fast = fast or float(best[k].get("time", INF)) <= GameState.area_par(k) * 0.75
	for c in GameState.CHAPTERS:
		areas += GameState.CHAPTERS[c].size()
	var pil := 0
	for k in d.get("batteries", {}):
		pil += d["batteries"][k].size()
	var screws: int = d.get("golden_screws", []).size()
	var secrets: int = d.get("secrets", []).size()
	var checks := {
		"ilk_adim": best.has("ch1_atolye"),
		"bolum1": cells.has("ch1"), "bolum2": cells.has("ch2"), "bolum3": cells.has("ch3"), "bolum4": cells.has("ch4"),
		"bonus": best.has("ch5_sampiyon"),
		"vida_5": screws >= 5, "vida_hepsi": screws >= GameState.screw_total(),
		"gizli_10": secrets >= 10, "gizli_hepsi": secrets >= GameState.SECRET_TOTAL,
		"pil_250": pil >= 250, "pil_600": pil >= 600,
		"uc_yildiz": three, "yildiz_10": stars >= 10, "yildiz_30": stars >= 30, "yildiz_hepsi": stars >= areas * 3,
		"hizli": fast,
		"seri_3": Settings.daily_streak >= 3, "seri_7": Settings.daily_streak >= 7,
		"kostum": Settings.skin != "klasik", "iz": Settings.trail != "yok",
	}
	for id in checks:
		if checks[id]:
			out.append(id)
	return out


## Yeni kazanılanları kaydet, ödülü ver, afiş göster. Dönen: yeni kazanılan kimlikler.
static func refresh(extra: Array = []) -> Array:
	var fresh := []
	for id in earned(GameState.data) + extra:
		if not Settings.achievements.has(id):
			Settings.achievements.append(id)
			fresh.append(id)
	if fresh.is_empty():
		return fresh
	Settings.bonus_batteries += REWARD * fresh.size()
	Settings.save_settings()
	var sc := (Engine.get_main_loop() as SceneTree).current_scene
	if sc and sc.get("hud") and sc.hud.has_method("toast"):
		for id in fresh:
			sc.hud.toast(TranslationServer.translate("Başarım: %s") % TranslationServer.translate(name_of(id)))
	return fresh


static func name_of(id: String) -> String:
	for a in LIST:
		if a[0] == id:
			return a[1]
	return id
