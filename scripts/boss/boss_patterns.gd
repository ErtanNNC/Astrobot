class_name BossPatterns
extends RefCounted
## Patronların ikinci saldırısı: tek mermi yerine desenli yaylım. Her mermi kendi uyarı diskiyle (WarnMark) gelir,
## her desenin güvenli bir yeri vardır. Kurallar: docs/features/dusmanlar/design.md ("Patron saldırı desenleri")

const EVERY := 3          ## 2. aşamadan itibaren her 3. saldırı desenlidir


## pattern: "line" (patrondan oyuncuya doğru 4'lü sıra; yana kaç), "ring" (oyuncunun çevresinde 6'lı halka; ortada kal),
## "cross" (artı; çapraza kaç). from: patronun konumu, at: oyuncunun yerdeki konumu.
static func volley(parent: Node, script_path: String, pattern: String, from: Vector3, at: Vector3) -> int:
	var pts: Array[Vector3] = []
	var dir := Vector3(at.x - from.x, 0, at.z - from.z)
	dir = dir.normalized() if dir.length() > 0.1 else Vector3.FORWARD
	var side := Vector3(-dir.z, 0, dir.x)
	match pattern:
		"line":
			for i in 4:
				pts.append(at + dir * (i - 1.5) * 2.4)
		"ring":
			for i in 6:
				var a := TAU * i / 6.0
				pts.append(at + Vector3(cos(a), 0, sin(a)) * 3.2)
		"cross":
			pts.append(at)
			for v in [dir, -dir, side, -side]:
				pts.append(at + v * 2.6)
				pts.append(at + v * 5.2)
	var sc: Script = load(script_path)
	for p in pts:
		var n := sc.new() as Node3D
		parent.add_child(n)
		n.global_position = Vector3(p.x, at.y, p.z)
	return pts.size()
