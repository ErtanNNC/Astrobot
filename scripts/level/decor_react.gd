extends Node
## Canlı dünya (Astro Bot hissi): çalı, ot ve bitkiler Bip içinden geçince sallanır;
## dönme saldırısıyla vurulan çalı/bitki bir kez pil düşürür, ağaçlar sarsılır.
## area.gd her alana bunu ekler. Bkz. docs/features/oyun-hissi/design.md

const TOUCH_KINDS := ["Grass", "Bush", "Plant", "KGrass", "KFlowers", "KPlant", "KMushrooms"]   ## içinden geçince sallanır
const DROP_KINDS := ["Bush", "Plant", "KFlowersTall", "KMushrooms", "KPlant"]   ## vurunca pil düşürür
const TOUCH_RADIUS := 0.9                        ## m
const BATTERIES_PER_BUSH := 1

var _items: Array = []      # [düğüm, model, tür, özgün ölçek, sallanma zamanı]
var _bip: Bip
var _area_id := ""
var _given: Dictionary = {}


func setup(decor: Node, bip: Bip, area_id: String) -> void:
	_bip = bip
	_area_id = area_id
	for n in decor.get_children():
		if not (n is Node3D):
			continue
		var kind := ""
		for k in TOUCH_KINDS + ["Tree", "KTree", "KPine"]:
			if String(n.name).begins_with(k):
				kind = k
				break
		if kind == "":
			continue
		var model: Node3D = n.get_node_or_null("Model") if n is StaticBody3D else n
		if model == null:
			continue
		_items.append({"node": n, "model": model, "kind": kind, "scale": model.scale, "t": 0.0})
	bip.spun.connect(_on_spun)


func _physics_process(delta: float) -> void:
	if _bip == null:
		return
	var p := _bip.global_position
	var moving := Vector2(_bip.velocity.x, _bip.velocity.z).length() > 1.0 or not _bip.is_on_floor()
	for it in _items:
		it["t"] = maxf(it["t"] - delta, 0.0)
		if not moving or it["t"] > 0.0 or not TOUCH_KINDS.has(it["kind"]):
			continue
		var d: Vector3 = it["node"].global_position - p
		if absf(d.y) < 1.5 and d.x * d.x + d.z * d.z < TOUCH_RADIUS * TOUCH_RADIUS:
			_wobble(it, 0.25)
			if it["kind"] != "Grass" and randf() < 0.5:
				Fx.burst(it["node"].global_position + Vector3.UP * 0.4, Color(0.45, 0.8, 0.35), 3, 1.2)


func _on_spun() -> void:
	var p := _bip.global_position
	var r := _bip.spin_radius + 0.6
	for it in _items:
		var n: Node3D = it["node"]
		var d: Vector3 = n.global_position - p
		var tree: bool = it["kind"] in ["Tree", "KTree", "KPine"]
		var reach := r + (0.8 if tree else 0.0)
		if absf(d.y) > 2.0 or Vector2(d.x, d.z).length() > reach:
			continue
		_wobble(it, 0.45)
		Fx.burst(n.global_position + Vector3.UP * (1.5 if tree else 0.4), Color(0.45, 0.8, 0.35), 6, 2.0)
		if _drops(String(n.name)) and not _given.has(n.name):
			_given[n.name] = true
			Battery.burst(n.get_parent(), n.global_position, BATTERIES_PER_BUSH, "cali_" + String(n.name))


func _drops(nm: String) -> bool:
	for k in DROP_KINDS:
		if nm.begins_with(k):
			return true
	return false


func _wobble(it: Dictionary, amount: float) -> void:
	it["t"] = 0.5
	var m: Node3D = it["model"]
	var s: Vector3 = it["scale"]
	var tw := m.create_tween()
	tw.tween_property(m, "scale", s * Vector3(1.0 + amount * 0.6, 1.0 - amount, 1.0 + amount * 0.6), 0.07)
	tw.tween_property(m, "scale", s, 0.45).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
