extends Control
## Emeği Geçenler: oyunun finalinden sonra kayan yazı. Dokunmak/tuş hızlandırır, basılı tutmak geçer.
## Liste CREDITS.md ile aynı tutulmalı.

const LINES := [
	["BİP", 90], ["Kopyalayan Robot", 36], ["", 30],
	["Tasarım ve yapım", 40], ["Bip Ekibi", 30], ["Claude Code ile birlikte", 26], ["", 30],
	["Bip'in gövdesi", 34], ["Pixabay — Cute robot (Pixabay Content License)", 26], ["Animasyonlar: Mixamo (Adobe)", 26], ["Atölye robotları: Quaternius — Animated Robot (CC0)", 24], ["", 20],
	["Çevre, düşmanlar, Pırıl", 34], ["Quaternius — Ultimate Platformer Pack (CC0)", 26], ["", 20],
	["Zemin blokları", 34], ["Kay Lousberg — KayKit Platformer Pack (CC0)", 26], ["Kay Lousberg — KayKit Restaurant, Furniture, Forest, Space Base, Medieval, Holiday (CC0)", 26], ["Quaternius — Animated Fish, Pirate Pack, Easy Enemies (CC0)", 26], ["", 20],
	["Ağaçlar ve çiçekler", 34], ["Kenney — Platformer Kit, Factory Kit, Holiday Kit (CC0)", 26], ["", 20],
	["Paslı Kaptan modeli", 34], ["Pixabay — Fish mecha robot (Pixabay Content License)", 26], ["", 20],
	["Duvar ve zemin dokuları", 34], ["freegameassets.com — Painterly Fantasy Textures (CC0)", 26], ["", 20],
	["Ses efektleri", 34], ["Kenney — kenney.nl (CC0)", 26], ["", 20],
	["Arayüz", 34], ["pzUH — Free Game GUI (CC0)", 26], ["Kenney — Game Icons (CC0)", 26], ["", 20],
	["Yazı tipi", 34], ["Nunito — The Nunito Project Authors (SIL OFL 1.1)", 26], ["", 20],
	["Müzik (OpenGameArt, CC0)", 34],
	["owlishmedia — Happy Clappy Loop", 24], ["tinyworlds — Happy Adventure Loop", 24],
	["cleytonkauffman — Adventure Theme, Snow Theme", 24], ["hydrogene — 8-bit Mechanical Complex", 24],
	["nihilocrat — Upbeat Chiptune Theme", 24], ["mopz — Platformer Music", 24],
	["josepharaoh99 — Pacific Ocean", 24], ["zesona — Village of Snow", 24], ["", 20],
	["Ortam ve adım sesleri (OpenGameArt, CC0)", 34],
	["TinyWorlds, Thimras, JaggedStone, Kresiek The Furry, gmason, jasinski", 24], ["", 20],
	["Motor", 34], ["Godot Engine (MIT)", 26], ["", 40],
	["Oynadığın için teşekkürler!", 44], ["", 20], ["Dişli Adası yeniden ışıl ışıl.", 30], ["", 60],
]

var _scroll: VBoxContainer
var _speed := 60.0
var _hold := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.22)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_scroll = VBoxContainer.new()
	_scroll.add_theme_constant_override("separation", 10)
	add_child(_scroll)
	for l in LINES:
		var lab := Label.new()
		lab.text = l[0]
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.add_theme_font_size_override("font_size", l[1])
		lab.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.15))
		lab.add_theme_constant_override("outline_size", 8)
		if l[1] >= 34:
			lab.add_theme_color_override("font_color", Color(1.0, 0.8, 0.35))
		_scroll.add_child(lab)
	# Godot'nun MIT lisansı metnin ürünle birlikte verilmesini ister (docs/store/lisans-denetimi.md)
	var lic := Label.new()
	lic.text = Engine.get_license_text()
	lic.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	lic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lic.add_theme_font_size_override("font_size", 14)
	lic.add_theme_color_override("font_color", Color(0.75, 0.78, 0.9))
	lic.custom_minimum_size.x = 900
	lic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_scroll.add_child(lic)
	_scroll.position = Vector2(0, get_viewport_rect().size.y + 20)
	_scroll.size.x = get_viewport_rect().size.x
	var mp := AudioStreamPlayer.new()
	mp.bus = &"Music"
	mp.stream = load("res://assets/audio/opengameart/happy_adventure_loop.mp3")
	add_child(mp)
	mp.play()


func _process(delta: float) -> void:
	_scroll.size.x = get_viewport_rect().size.x
	var fast := Input.is_action_pressed("jump") or Input.is_action_pressed("ability") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	_hold = _hold + delta if fast else 0.0
	_scroll.position.y -= _speed * (4.0 if fast else 1.0) * delta
	if _scroll.position.y + _scroll.size.y < -20 or _hold > 2.5:
		set_process(false)
		Scenes.go("res://scenes/ui/results.tscn")
