extends Node
## Geri dönme sebepleri: yıldız/rekor, günlük görev, pille açılan izler. (docs/features/geri-donme/design.md)
var fails := 0

func check(name: String, ok: bool, info := "") -> void:
	print(("GEÇTİ  " if ok else "KALDI  ") + name + "  " + info)
	if not ok:
		fails += 1

func _ready() -> void:
	# Oyuncunun gerçek ayarlarını bozma: test sonunda geri koy.
	var keep := [Settings.daily_day, Settings.daily_progress, Settings.daily_done, Settings.daily_streak, Settings.bonus_batteries, Settings.trail]
	GameState.data = GameState.new_data()
	var par := GameState.area_par("ch1_yay")

	var r := GameState.finish_area("ch1_yay", par + 30.0, 10, 100)
	check("yavaş ve az pilli bitiş: 1 yıldız", r["stars"] == 1 and not r["record"], str(r))
	r = GameState.finish_area("ch1_yay", par + 20.0, 80, 100)
	check("pillerin %80'i: 2 yıldız, daha hızlı: rekor", r["stars"] == 2 and r["record"], str(r))
	r = GameState.finish_area("ch1_yay", par - 1.0, 80, 100)
	check("hedef sürenin altı: 3 yıldız", r["stars"] == 3, str(r))
	r = GameState.finish_area("ch1_yay", par + 60.0, 0, 100)
	var best := GameState.area_best("ch1_yay")
	check("kötü tur rekoru ve yıldızı bozmaz", int(best["stars"]) == 3 and absf(float(best["time"]) - (par - 1.0)) < 0.01, str(best))
	check("toplam yıldız", GameState.total_stars() == 3)
	check("süre yazısı", GameState.time_text(102.0) == "1:42", GameState.time_text(102.0))
	r = GameState.finish_area("ch1_patron", 100.0, 0, 0)
	check("pilsiz alan (patron): pil yıldızı kendiliğinden", r["stars"] == 3, str(r))

	# Günlük görev
	Settings.daily_day = -5
	Settings.daily_done = false
	Settings.daily_streak = 4
	Settings.bonus_batteries = 0
	var q := Daily.quest()
	check("gün değişince görev sıfırlanır, kaçan gün seriyi bozar", Settings.daily_progress == 0 and Settings.daily_streak == 0)
	Daily.add("olmayan_tur", 99)
	check("başka türden ilerleme sayılmaz", Settings.daily_progress == 0 and not Settings.daily_done)
	var best_mode: bool = q["id"] == "yildiz"
	Daily.add(q["id"], int(q["goal"]) - 1, best_mode)
	check("hedefe varmadan bitmez", not Settings.daily_done, Daily.line())
	Daily.add(q["id"], int(q["goal"]) if best_mode else 1, best_mode)
	check("hedefte biter, bonus pil ve seri gelir", Settings.daily_done and Settings.bonus_batteries == Daily.REWARD and Settings.daily_streak == 1, Daily.line())
	Daily.add(q["id"], 50, best_mode)
	check("aynı gün ikinci ödül yok", Settings.bonus_batteries == Daily.REWARD)

	# İzler
	Settings.bonus_batteries = 0
	var base := GameState.best_batteries()
	check("ilk iz açık", GameState.trail_unlocked("yok"))
	Settings.bonus_batteries = maxi(0, 100 - base)
	check("100 pilde Kıvılcım açılır", GameState.trail_unlocked("kivilcim"))
	if base < 500:
		check("Gökkuşağı 500 pilden önce kilitli", not GameState.trail_unlocked("gokkusagi") or GameState.best_batteries() >= 500)

	# Hayalet: kaydet, yükle, aradaki anı doğru hesapla, yuva silinince dosya da gider
	var run := PackedFloat32Array()
	for i in 30:
		run.append_array(PackedFloat32Array([i * 0.5, 1.0, -i * 1.0, 0.0]))
	check("hayalet kaydedildi", GhostRun.save_run(2, "test_alan", run))
	var back := GhostRun.load_run(2, "test_alan")
	check("hayalet aynı geri yüklendi", back.size() == run.size() and is_equal_approx(back[run.size() - 2], -29.0))
	var mid: Array = GhostRun.sample_at(back, 1.05)
	check("hayalet iki örnek arasını doğru hesaplar", (mid[0] as Vector3).distance_to(Vector3(5.25, 1.0, -10.5)) < 0.01, str(mid[0]))
	check("hayalet süresi", is_equal_approx(GhostRun.duration(back), 2.9), str(GhostRun.duration(back)))
	check("çok kısa tur kaydedilmez", not GhostRun.save_run(2, "bos", PackedFloat32Array([0, 0, 0, 0])))
	GhostRun.delete_slot(2)
	check("yuva silinince hayalet de silindi", GhostRun.load_run(2, "test_alan").is_empty())

	# Başarımlar: veriden hesaplanır, bir kez verilir, bonus pil kazandırır
	var keep_ach: Array = Settings.achievements.duplicate()
	Settings.achievements = []
	Settings.bonus_batteries = 0
	Settings.daily_streak = 0
	GameState.data = GameState.new_data()
	check("boş kayıtta veri başarımı yok", Achievements.earned(GameState.data).filter(func(x): return x not in ["kostum", "iz"]).is_empty())
	GameState.data["core_cells"] = ["ch1"]
	GameState.data["golden_screws"] = ["a", "b", "c", "d", "e"]
	GameState.finish_area("ch1_atolye", 50.0, 0, 0)
	var e := Achievements.earned(GameState.data)
	check("patron, vida, ilk adım, 3 yıldız ve hız başarımları hesaplandı", e.has("bolum1") and e.has("vida_5") and e.has("ilk_adim") and e.has("uc_yildiz") and e.has("hizli") and not e.has("bolum2"), str(e))
	var got_new := Achievements.refresh(["hasarsiz"])
	check("yeni başarımlar kaydedildi ve ödül verildi", got_new.has("hasarsiz") and Settings.bonus_batteries == Achievements.REWARD * got_new.size(), str(got_new))
	check("aynı başarım ikinci kez verilmez", Achievements.refresh(["hasarsiz"]).is_empty())
	Settings.achievements = keep_ach

	# Şapkalar: yıldızla açılır, her biri kurulabilir
	GameState.data = GameState.new_data()
	var base_stars := GameState.best_stars()
	check("şapkasız her zaman açık", GameState.hat_unlocked("yok"))
	if base_stars < 5:
		check("Parti Şapkası 5 yıldızdan önce kilitli", not GameState.hat_unlocked("parti"))
		GameState.finish_area("ch1_patron", 10.0, 0, 0); GameState.finish_area("ch2_patron", 10.0, 0, 0)
		check("6 yıldızla Parti Şapkası açılır", GameState.hat_unlocked("parti"), str(GameState.best_stars()))
	for h in GameState.HATS:
		var hn := HatModels.make(h["id"])
		check("şapka modeli kuruldu: " + h["id"], hn != null and (h["id"] == "yok" or hn.get_child_count() > 0))
		hn.free()

	# Oynanış kaydı: tur yazılır, dışa aktarılır, geri çözülür
	PlayLog.clear()
	PlayLog.begin("test_alan", true)
	PlayLog.fall(Vector3(1.23, 4.0, -56.78))
	PlayLog.hit(Vector3(2, 0, -3), "life")
	PlayLog.checkpoint("orta", 12.34)
	PlayLog.tick(0.5, 20.0)
	PlayLog.end("done", 2, 30, 40)
	check("kayıtta bir tur var", PlayLog.count() == 1)
	var txt := PlayLog.export_text()
	check("dışa aktarma BIPLOG1 ile başlar", txt.begins_with("BIPLOG1:") and txt.length() > 40)
	var raw := Marshalls.base64_to_raw(txt.substr(8)).decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	var back_log = JSON.parse_string(raw.get_string_from_utf8())
	var run0: Dictionary = back_log["runs"][0] if back_log is Dictionary and back_log["runs"].size() > 0 else {}
	check("kayıt geri çözüldü: alan, düşme yeri, yıldız", run0.get("a", "") == "test_alan" and run0.get("falls", []).size() == 1 and is_equal_approx(run0["falls"][0][2], -56.8) and int(run0.get("stars", 0)) == 2, str(run0))
	PlayLog.clear()
	check("kayıt silindi", PlayLog.count() == 0)

	Settings.daily_day = keep[0]; Settings.daily_progress = keep[1]; Settings.daily_done = keep[2]
	Settings.daily_streak = keep[3]; Settings.bonus_batteries = keep[4]; Settings.trail = keep[5]
	Settings.save_settings()
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
