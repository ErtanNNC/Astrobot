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
var quality := 2              ## 0 Düşük, 1 Orta, 2 Yüksek (3B çözünürlük ölçeği)
var shadows_on := true


func _ready() -> void:
	load_settings()
	apply()


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
		AudioServer.set_bus_mute(m, not music_on)
	if s >= 0:
		AudioServer.set_bus_mute(s, not sfx_on)


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
	shadows_on = cfg.get_value("graphics", "shadows_on", shadows_on)


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
	cfg.set_value("graphics", "shadows_on", shadows_on)
	# Güvenli yazma: önce geçici dosya, sonra yerine koy (kayıt dokümanı kural 7).
	var tmp := PATH + ".tmp"
	if cfg.save(tmp) == OK:
		DirAccess.rename_absolute(tmp, PATH)
