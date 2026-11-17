extends Node
## Kısa efekt sesleri (autoload: Sfx). Sfx.play("pickup") gibi kullanılır.
## Tüm sesler CC0 (Kenney), bkz. CREDITS.md

const SOUNDS := {
	"pickup": "res://assets/audio/kenney/coin.ogg",
	"copy": "res://assets/audio/kenney/powerUp2.mp3",
	"ability_lost": "res://assets/audio/kenney/phaserDown2.mp3",
	"hurt": "res://assets/audio/kenney/lowDown.mp3",
	"spring": "res://assets/audio/kenney/phaseJump1.mp3",
	"charge": "res://assets/audio/kenney/phaserUp1.mp3",
	"pop": "res://assets/audio/kenney/break.ogg",
	"break": "res://assets/audio/kenney/break.ogg",
	"magnet": "res://assets/audio/kenney/zapThreeToneUp.mp3",
	"glide": "res://assets/audio/kenney/pepSound2.mp3",
	"core": "res://assets/audio/kenney/powerUp11.mp3",
	"bounce": "res://assets/audio/kenney/highUp.mp3",
	"same": "res://assets/audio/kenney/twoTone1.mp3",
	"checkpoint": "res://assets/audio/kenney/confirmation_002.ogg",
	"screw": "res://assets/audio/kenney/jingles_NES13.ogg",
	"clear": "res://assets/audio/kenney/jingles_SAX07.ogg",
	"secret": "res://assets/audio/kenney/jingles_NES03.ogg",
	"click": "res://assets/audio/kenney/click_002.ogg",
	"select": "res://assets/audio/kenney/select_003.ogg",
	"back": "res://assets/audio/kenney/back_002.ogg",
	"wake": "res://assets/audio/kenney/maximize_003.ogg",
	"drop": "res://assets/audio/kenney/drop_002.ogg",
	"open": "res://assets/audio/kenney/open_001.ogg",
	"glass": "res://assets/audio/kenney/glass_002.ogg",
	"land": "res://assets/audio/kenney/land.ogg",
	"fall": "res://assets/audio/kenney/fall.ogg",
}

var _cache := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _last_time := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 12:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_pool.append(p)


func play(sound: String, volume_db := 0.0, pitch := 1.0, pitch_random := 0.05) -> void:
	if not SOUNDS.has(sound):
		push_warning("Bilinmeyen ses: " + sound)
		return
	# Aynı ses aynı karede üst üste çalmasın (ör. 10 pil birden toplanınca)
	var now := Time.get_ticks_msec()
	if _last_time.get(sound, -1000) > now - 40:
		return
	_last_time[sound] = now
	if not _cache.has(sound):
		_cache[sound] = load(SOUNDS[sound])
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = _cache[sound]
	p.volume_db = volume_db
	p.pitch_scale = pitch * randf_range(1.0 - pitch_random, 1.0 + pitch_random)
	p.play()
