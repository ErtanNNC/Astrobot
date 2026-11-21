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
var dev_all_areas := false    ## test: Alan Seç'te bütün alanlar açık (mağaza sürümünden önce kaldırılacak)


func _ready() -> void:
	load_settings()
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


func apply() -> void:
	Haptics.enabled = vibration
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
	# Güvenli yazma: önce geçici dosya, sonra yerine koy (kayıt dokümanı kural 7).
	var tmp := PATH + ".tmp"
	if cfg.save(tmp) == OK:
		DirAccess.rename_absolute(tmp, PATH)
