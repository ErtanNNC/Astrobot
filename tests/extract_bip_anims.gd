extends SceneTree
## Mixamo FBX'lerinden yalnızca animasyonları çıkarıp tek kütüphaneye yazar (APK küçük kalsın:
## her FBX'te modelin ve dokunun bir kopyası var). Kaynaklar assets/models/pixabay/bip/src/ içinde,
## orada .gdignore olduğu için oyuna girmezler.
## Yeniden çalıştırmak için: src/.gdignore'u geçici kaldır, `godot --headless --path . --import`,
## sonra `godot --headless --path . -s tests/extract_bip_anims.gd`, en son .gdignore'u geri koy.
const DIR := "res://assets/models/pixabay/bip/"
const LOOPING := ["idle", "walk", "run", "fall", "hang", "victory"]


func _init() -> void:
	var lib := AnimationLibrary.new()
	for f in ["idle", "walk", "run", "jump", "fall", "hang", "wave", "victory"]:
		var sc: Node = load(DIR + "src/" + f + ".fbx").instantiate()
		var a: Animation = (sc.get_node("AnimationPlayer") as AnimationPlayer).get_animation("mixamo_com").duplicate()
		a.loop_mode = Animation.LOOP_LINEAR if f in LOOPING else Animation.LOOP_NONE
		lib.add_animation(f, a)
		sc.free()
	print("kaydedildi: ", ResourceSaver.save(lib, DIR + "bip_anims.res"))
	quit()
