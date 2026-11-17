extends Node
## Tüm betikleri ve sahneleri yüklemeyi dener; hata varsa listeler.
## Çalıştırma: godot --headless --path . tests/compile_check.tscn

func _ready() -> void:
	var bad := 0
	for path in _walk("res://scripts", ".gd") + _walk("res://scenes", ".tscn"):
		var r = load(path)
		if r == null or (r is GDScript and not r.can_instantiate()):
			print("HATA: ", path)
			bad += 1
		elif r is PackedScene:
			var inst = r.instantiate()
			if inst == null:
				print("HATA (sahne): ", path)
				bad += 1
			else:
				inst.free()
	print("KONTROL BİTTİ, hatalı: ", bad)
	get_tree().quit(1 if bad > 0 else 0)


func _walk(dir: String, ext: String) -> Array:
	var out := []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(ext):
			out.append(dir + "/" + f)
	for sub in d.get_directories():
		out += _walk(dir + "/" + sub, ext)
	return out
