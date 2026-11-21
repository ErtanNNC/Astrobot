class_name Turns
## Köşeli/kıvrımlı alanlarda testler için: tasarım uzayı (yol dümdüz -Z) ↔ dünya uzayı.
## Alan kökündeki metadata/turns listesini okur (üretici: tools/level/lvl.py, Level.turns).
## Dönüşsüz alanlarda hiçbir şeyi değiştirmez.


static func _list(level: Node) -> Array:
	return level.get_meta("turns", []) if level else []


## Tasarım noktası → dünya noktası
static func world(level: Node, p: Vector3) -> Vector3:
	var ts := _list(level)
	for i in range(ts.size() - 1, -1, -1):
		var t: Vector3 = ts[i]           # (pivot_x, pivot_z, derece); pivot_z büyükten küçüğe
		if p.z < t.y:
			var a := deg_to_rad(t.z)
			var dx := p.x - t.x
			var dz := p.z - t.y
			p = Vector3(t.x + dx * cos(a) + dz * sin(a), p.y, t.y - dx * sin(a) + dz * cos(a))
	return p


## O tasarım noktasındaki toplam dönüş (radyan): yönlere eklenir
static func yaw(level: Node, p: Vector3) -> float:
	var a := 0.0
	for t in _list(level):
		if p.z < (t as Vector3).y:
			a += deg_to_rad((t as Vector3).z)
	return a


## Dünya noktası → tasarım noktası (hangi bölgede olduğu tutarlılıkla bulunur)
static func design(level: Node, w: Vector3) -> Vector3:
	var ts := _list(level)
	for k in range(ts.size(), -1, -1):      # ilk k dönüşün uygulandığını varsay
		var p := w
		for i in k:
			var t: Vector3 = ts[i]
			var a := -deg_to_rad(t.z)
			var dx := p.x - t.x
			var dz := p.z - t.y
			p = Vector3(t.x + dx * cos(a) + dz * sin(a), p.y, t.y - dx * sin(a) + dz * cos(a))
		var ok := true
		if k > 0 and p.z >= (ts[k - 1] as Vector3).y + 0.5:
			ok = false
		if k < ts.size() and p.z < (ts[k] as Vector3).y - 0.5:
			ok = false
		if ok:
			return p
	return w
