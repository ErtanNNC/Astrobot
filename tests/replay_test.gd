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

	Settings.daily_day = keep[0]; Settings.daily_progress = keep[1]; Settings.daily_done = keep[2]
	Settings.daily_streak = keep[3]; Settings.bonus_batteries = keep[4]; Settings.trail = keep[5]
	Settings.save_settings()
	print("SONUÇ: %s" % ("TÜM TESTLER GEÇTİ" if fails == 0 else "%d test kaldı" % fails))
	get_tree().quit(1 if fails else 0)
