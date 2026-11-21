extends Node
## Oyuncu ayarları (autoload: Settings). Kayıt yuvalarından ayrı bir dosyada tutulur.
## Bkz. docs/features/mobil-kontroller/design.md ve docs/features/ana-menu/design.md

signal changed

const PATH := "user://settings.cfg"
const BUTTON_SCALES := [0.85, 1.0, 1.2]

var button_size := 1          ## 0 Küçük, 1 Orta, 2 Büyük
var button_opacity := 0.8
var left_handed := false
var vibration := true
var music_on := true
var sfx_on := true
var hints_on := true          ## Pırıl ipuçları
var shake_on := true          ## ekran sarsıntısı
var master_vol := 1.0         ## 0..1
var music_vol := 0.8
var sfx_vol := 1.0
var quality := 2              ## 0 Düşük, 1 Orta, 2 Yüksek (3B çözünürlük ölçeği)
var shadows_on := true
var skin := "klasik"          ## Bip'in kostümü (GameState.SKINS)
var language := ""            ## "" = cihaz diline göre (Türkçe cihazda tr, diğerlerinde en), "tr", "en"
var show_fps := false         ## ekranda kare hızı (performans testi için)
var ui_big := false           ## büyük arayüz: yazılar, butonlar ve göstergeler %15 büyür
var hat := "yok"              ## Bip'in şapkası (GameState.HATS)
var easy_mode := false        ## kolay mod: düşünce can gitmez, her kontrol noktası canları doldurur
var achievements: Array = []  ## kazanılan başarım kimlikleri (scripts/autoload/achievements.gd)
var ghost_on := true          ## hayalet yarışı: rekor turun saydam Bip'i seninle koşar
var trail := "yok"            ## koşu izi (GameState.TRAILS)
var daily_day := -1           ## günlük görev (scripts/autoload/daily.gd): hangi gün
var daily_progress := 0
var daily_done := false
var daily_streak := 0         ## art arda bitirilen gün
var bonus_batteries := 0      ## günlük görevlerden kazanılan pil (kostüm/iz açmaya sayılır)
var dev_all_areas := false    ## test: Alan Seç'te bütün alanlar açık; yalnızca test sürümünde görünür (dev_mode)


## Test sürümü mü? Editörde ve "dev" özellik etiketiyle dışa aktarılan APK'da doğru. Mağaza sürümünde
## export_presets.cfg içindeki custom_features="dev" silinir; test seçenekleri kendiliğinden kaybolur.
func dev_mode() -> bool:
	return OS.has_feature("dev") or OS.has_feature("editor")


func all_areas_open() -> bool:
	return dev_mode() and dev_all_areas


## Tek seferlik temiz başlangıç (geliştirici isteği, 2026-11-22): bu kimliği taşımayan kurulumda ilk açılışta bütün
## ilerleme silinir. Yeni bir temiz başlangıç gerekirse kimliği değiştir; mağaza sürümünde "" yap (silme yapılmaz).
const CLEAN_START_ID := "2026-11-22"
var _clean_start_done := ""


func _ready() -> void:
	load_settings()
	if CLEAN_START_ID != "" and _clean_start_done != CLEAN_START_ID:
		_clean_start_done = CLEAN_START_ID
		reset_progress()
	apply_language()
	apply()
	get_tree().root.theme = UIKit.make_theme()   # tüm arayüzün görünüşü (scripts/ui/ui_kit.gd)


## Kaynak dil Türkçe; İngilizce çeviri tablosu scripts/ui/lang_en.gd
func current_language() -> String:
	if language in ["tr", "en"]:
		return language
	return "tr" if OS.get_locale_language() == "tr" else "en"


var _en: Translation


## İngilizce tablo yalnızca dil İngilizceyken kayıtlıdır: motor, Türkçe çeviri bulamayınca İngilizceye
## düştüğü için tablo hep kayıtlı kalırsa Türkçe seçiliyken de İngilizce çıkar.
func apply_language() -> void:
	var lang := current_language()
	if _en == null:
		_en = LangEn.translation()
	TranslationServer.remove_translation(_en)
	if lang == "en":
		TranslationServer.add_translation(_en)
	TranslationServer.set_locale(lang)


func button_scale() -> float:
	return BUTTON_SCALES[clampi(button_size, 0, 2)]


func set_value(key: String, value: Variant) -> void:
	set(key, value)
	apply()
	save_settings()
	changed.emit()


const QUALITY_SCALES := [0.7, 0.85, 1.0]


## Temiz başlangıç: bütün kayıt yuvaları, hayaletler, başarımlar, günlük görev, bonus pil, kostüm seçimi ve oynanış
## kaydı silinir. Ses, kontrol, dil ve görüntü ayarları kalır.
func reset_progress() -> void:
	for i in GameState.SLOT_COUNT:
		GameState.delete_slot(i)
	GameState.slot = -1
	GameState.data = GameState.new_data()
	GameState.set_ability("")
	GameState.refill_lives()
	achievements = []
	bonus_batteries = 0
	daily_day = -1
	daily_progress = 0
	daily_done = false
	daily_streak = 0
	skin = "klasik"
	hat = "yok"
	trail = "yok"
	dev_all_areas = false
	PlayLog.clear()
	save_settings()
	changed.emit()


const UI_BIG_SCALE := 1.15


func apply() -> void:
	Haptics.enabled = vibration
	get_tree().root.content_scale_factor = UI_BIG_SCALE if ui_big else 1.0
	apply_graphics()
	var m := AudioServer.get_bus_index("Music")
	var s := AudioServer.get_bus_index("SFX")
	if m >= 0:
		AudioServer.set_bus_mute(m, not music_on or music_vol <= 0.01)
		AudioServer.set_bus_volume_db(m, linear_to_db(maxf(music_vol, 0.01)) - 6.0)
	if s >= 0:
		AudioServer.set_bus_mute(s, not sfx_on or sfx_vol <= 0.01)
		AudioServer.set_bus_volume_db(s, linear_to_db(maxf(sfx_vol, 0.01)))
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_vol, 0.01)))
	AudioServer.set_bus_mute(0, master_vol <= 0.01)


## Kalite ve gölgeler: sahne değişince de çağrılır (alan yöneticisi).
func apply_graphics() -> void:
	var tree := get_tree()
	if tree == null:
		return
	tree.root.scaling_3d_scale = QUALITY_SCALES[clampi(quality, 0, 2)]
	var scene := tree.current_scene
	if scene:
		for l in scene.find_children("*", "DirectionalLight3D", true, false):
			l.shadow_enabled = shadows_on


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	button_size = cfg.get_value("controls", "button_size", button_size)
	button_opacity = cfg.get_value("controls", "button_opacity", button_opacity)
	left_handed = cfg.get_value("controls", "left_handed", left_handed)
	vibration = cfg.get_value("controls", "vibration", vibration)
	music_on = cfg.get_value("audio", "music_on", music_on)
	sfx_on = cfg.get_value("audio", "sfx_on", sfx_on)
	hints_on = cfg.get_value("access", "hints_on", hints_on)
	shake_on = cfg.get_value("access", "shake_on", shake_on)
	quality = cfg.get_value("graphics", "quality", quality)
	master_vol = cfg.get_value("audio", "master_vol", master_vol)
	music_vol = cfg.get_value("audio", "music_vol", music_vol)
	sfx_vol = cfg.get_value("audio", "sfx_vol", sfx_vol)
	# Eski sürümdeki aç/kapa düğmeleri artık kaydırıcı: "kapalı" → ses 0
	if not music_on:
		music_vol = 0.0
		music_on = true
	if not sfx_on:
		sfx_vol = 0.0
		sfx_on = true
	shadows_on = cfg.get_value("graphics", "shadows_on", shadows_on)
	skin = cfg.get_value("player", "skin", skin)
	dev_all_areas = cfg.get_value("dev", "all_areas", dev_all_areas)
	show_fps = cfg.get_value("graphics", "show_fps", show_fps)
	language = cfg.get_value("player", "language", language)
	trail = cfg.get_value("player", "trail", trail)
	ghost_on = cfg.get_value("player", "ghost_on", ghost_on)
	achievements = cfg.get_value("player", "achievements", achievements)
	easy_mode = cfg.get_value("access", "easy_mode", easy_mode)
	hat = cfg.get_value("player", "hat", hat)
	ui_big = cfg.get_value("access", "ui_big", ui_big)
	_clean_start_done = cfg.get_value("meta", "clean_start", _clean_start_done)
	daily_day = cfg.get_value("daily", "day", daily_day)
	daily_progress = cfg.get_value("daily", "progress", daily_progress)
	daily_done = cfg.get_value("daily", "done", daily_done)
	daily_streak = cfg.get_value("daily", "streak", daily_streak)
	bonus_batteries = cfg.get_value("daily", "bonus_batteries", bonus_batteries)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("controls", "button_size", button_size)
	cfg.set_value("controls", "button_opacity", button_opacity)
	cfg.set_value("controls", "left_handed", left_handed)
	cfg.set_value("controls", "vibration", vibration)
	cfg.set_value("audio", "music_on", music_on)
	cfg.set_value("audio", "sfx_on", sfx_on)
	cfg.set_value("access", "hints_on", hints_on)
	cfg.set_value("access", "shake_on", shake_on)
	cfg.set_value("graphics", "quality", quality)
	cfg.set_value("audio", "master_vol", master_vol)
	cfg.set_value("audio", "music_vol", music_vol)
	cfg.set_value("audio", "sfx_vol", sfx_vol)
	cfg.set_value("graphics", "shadows_on", shadows_on)
	cfg.set_value("player", "skin", skin)
	cfg.set_value("dev", "all_areas", dev_all_areas)
	cfg.set_value("graphics", "show_fps", show_fps)
	cfg.set_value("player", "language", language)
	cfg.set_value("player", "trail", trail)
	cfg.set_value("player", "ghost_on", ghost_on)
	cfg.set_value("player", "achievements", achievements)
	cfg.set_value("access", "easy_mode", easy_mode)
	cfg.set_value("player", "hat", hat)
	cfg.set_value("access", "ui_big", ui_big)
	cfg.set_value("meta", "clean_start", _clean_start_done)
	cfg.set_value("daily", "day", daily_day)
	cfg.set_value("daily", "progress", daily_progress)
	cfg.set_value("daily", "done", daily_done)
	cfg.set_value("daily", "streak", daily_streak)
	cfg.set_value("daily", "bonus_batteries", bonus_batteries)
	# Güvenli yazma: önce geçici dosya, sonra yerine koy (kayıt dokümanı kural 7).
	var tmp := PATH + ".tmp"
	if cfg.save(tmp) == OK:
		DirAccess.rename_absolute(tmp, PATH)
