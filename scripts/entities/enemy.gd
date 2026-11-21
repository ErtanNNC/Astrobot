extends CharacterBody3D
## Düşmanlar. Üstüne zıplanınca ya da Kaya ile ezilince yenilir; yandan değerse Bip hasar alır.
## Türler:
##  vidabocek – Vidaböcek: bir çizgide ileri geri yürür, kenarda döner.
##  zipzip    – Zıpzıp: yerinde zıplar, Bip yaklaşınca ona doğru seker.
##  hurdaci   – Hurda Goblin: Bip'i görünce kovalar, uzaklaşınca evine döner.
## Görünüş bölüme göre değişir (CHAPTER_SKINS): yengeç/kurukafa → kurbağa, örümcek, sıçan, eşek arısı.

@export_enum("vidabocek", "zipzip", "hurdaci") var kind := "vidabocek"
@export var patrol := 3.0        ## m, başlangıçtan her iki yöne
@export var speed := 1.6         ## m/s
@export var batteries := 3       ## yenilince saçılan pil
@export_enum("auto", "crab", "skull", "goblin", "frog", "spider", "rat", "wasp") var skin := "auto"   ## auto: bölüme göre seçilir

## Görünüş (davranış türden gelir). Bölümlere göre çeşit: her bölümün kendi yaratıkları olsun.
const SKINS := {
	"crab": ["res://assets/models/quaternius/enemies/Crab.gltf", 0.42],
	"skull": ["res://assets/models/quaternius/enemies/Skull.gltf", 0.38],
	"goblin": ["res://assets/models/quaternius/enemies/Enemy.gltf", 0.38],
	"frog": ["res://assets/models/quaternius/easy_enemies/Frog.fbx", 0.3],
	"spider": ["res://assets/models/quaternius/easy_enemies/Spider.fbx", 0.26],
	"rat": ["res://assets/models/quaternius/easy_enemies/Rat.fbx", 0.34],
	"wasp": ["res://assets/models/quaternius/easy_enemies/Wasp.fbx", 0.28],
}
## Bölüm → [vidabocek, zipzip, hurdaci] görünüşü
const CHAPTER_SKINS := {
	"chapter1": ["crab", "skull", "goblin"],
	"chapter2": ["crab", "frog", "goblin"],
	"chapter3": ["spider", "frog", "goblin"],
	"chapter4": ["rat", "wasp", "goblin"],
}


var _home := Vector3.ZERO
var _dir := 1.0
var _dead := false
var _model: Node3D
var _anim: AnimationPlayer
var _hop_timer := 1.0
var _gravity := 30.0
var _hurt_area: Area3D
var _axis := Vector3.RIGHT
var _frozen := 0.0
var _ice: StaticBody3D


func _ready() -> void:
	add_to_group("enemy")
	add_to_group("stompable")
	add_to_group("poundable")
	_home = global_position
	_axis = global_basis.x.normalized()
	rotation = Vector3.ZERO
	collision_layer = 4
	collision_mask = 1 | 2
	var cs := CollisionShape3D.new()
	var sh := CapsuleShape3D.new()
	sh.radius = 0.45
	sh.height = 1.0
	cs.shape = sh
	cs.position.y = 0.5
	add_child(cs)
	var sk := skin if skin != "auto" else _chapter_skin()
	_model = load(SKINS[sk][0]).instantiate()
	_model.scale = Vector3.ONE * float(SKINS[sk][1])
	add_child(_model)
	_anim = _model.find_child("AnimationPlayer", true, false)
	if _anim:
		for n in _anim.get_animation_list():
			if n.ends_with("Walk") or n.ends_with("Idle") or n.ends_with("Flying"):
				_anim.get_animation(n).loop_mode = Animation.LOOP_LINEAR
		_play("Walk" if kind != "zipzip" else "Idle")
		_play_fallback()
	# Bip'e değme alanı (yandan hasar)
	_hurt_area = Area3D.new()
	_hurt_area.collision_layer = 0
	_hurt_area.collision_mask = 1
	var hs := CollisionShape3D.new()
	var hsh := SphereShape3D.new()
	hsh.radius = 0.62
	hs.shape = hsh
	hs.position.y = 0.45
	_hurt_area.add_child(hs)
	add_child(_hurt_area)
	_hurt_area.body_entered.connect(_on_touch)
	_hop_timer = randf_range(0.5, 1.5)


func _chapter_skin() -> String:
	var path := ""
	var n: Node = self
	while n:
		if n.scene_file_path != "" and "/chapter" in n.scene_file_path:
			path = n.scene_file_path
			break
		n = n.get_parent()
	var i := ["vidabocek", "zipzip", "hurdaci"].find(kind)
	for ch in CHAPTER_SKINS:
		if "/" + ch + "/" in path:
			return CHAPTER_SKINS[ch][i]
	return CHAPTER_SKINS["chapter1"][i]


## Yürüme/bekleme animasyonu olmayan modeller (eşek arısı) uçma animasyonunu oynatır.
func _play_fallback() -> void:
	if _anim and _anim.current_animation == "":
		for a in _anim.get_animation_list():
			if a.ends_with("Flying") or a.ends_with("Idle"):
				_anim.play(a)
				return


func _play(n: String) -> void:
	if not _anim:
		return
	for a in _anim.get_animation_list():
		if a.ends_with(n):
			if _anim.current_animation != a:
				_anim.play(a, 0.15)
			return


func _physics_process(delta: float) -> void:
	if _dead:
		return
	if _frozen > 0.0:
		_frozen -= delta
		if _frozen <= 0.0:
			_unfreeze()
		return
	var bip := get_tree().get_first_node_in_group("player") as Node3D
	match kind:
		"vidabocek":
			var off := (global_position - _home).dot(_axis)
			if (off > patrol and _dir > 0) or (off < -patrol and _dir < 0) or is_on_wall() or (is_on_floor() and not _ground_ahead()):
				_dir = -_dir
			var v := _axis * _dir * speed
			velocity.x = v.x
			velocity.z = v.z
			_model.rotation.y = lerp_angle(_model.rotation.y, atan2(v.x, v.z), 8 * delta)
		"zipzip":
			velocity.x = move_toward(velocity.x, 0, 4 * delta)
			velocity.z = move_toward(velocity.z, 0, 4 * delta)
			if is_on_floor():
				_hop_timer -= delta
				if _hop_timer <= 0.0:
					_hop_timer = randf_range(0.9, 1.4)
					velocity.y = 8.0
					if bip and bip.global_position.distance_to(global_position) < 7.0:
						var to := (bip.global_position - global_position)
						to.y = 0
						velocity += to.normalized() * 3.0
						_model.rotation.y = atan2(to.x, to.z)
					_play("Jump")
			elif velocity.y < 0 and _anim:
				_play("Idle")
		"hurdaci":
			var target := _home
			if bip and bip.global_position.distance_to(global_position) < 8.0 and absf(bip.global_position.y - global_position.y) < 2.0:
				target = bip.global_position
			var to := target - global_position
			to.y = 0
			if to.length() > 0.3 and (target != _home or to.length() > 0.5):
				var v := to.normalized() * speed * (1.6 if target != _home else 1.0)
				if is_on_floor() and not _ground_ahead_dir(v.normalized()):
					v = Vector3.ZERO
				velocity.x = v.x
				velocity.z = v.z
				_model.rotation.y = lerp_angle(_model.rotation.y, atan2(to.x, to.z), 8 * delta)
				_play("Walk")
			else:
				velocity.x = 0
				velocity.z = 0
				_play("Idle")
	if not is_on_floor():
		velocity.y -= _gravity * delta
	move_and_slide()
	if global_position.y < _home.y - 20:
		queue_free()


func _ground_ahead() -> bool:
	return _ground_ahead_dir(_axis * _dir)


func _ground_ahead_dir(d: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var from := global_position + d * 0.6 + Vector3.UP * 0.4
	var q := PhysicsRayQueryParameters3D.create(from, from + Vector3.DOWN * 1.4, 1, [get_rid()])
	return not space.intersect_ray(q).is_empty()


## Buz yeteneği: düşman buz kütlesine dönüşür; üstüne çıkılabilir, zarar vermez.
func freeze(t: float) -> void:
	_frozen = t
	velocity = Vector3.ZERO
	if _anim:
		_anim.pause()
	if _ice == null:
		_ice = StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var b := BoxShape3D.new()
		b.size = Vector3(1.5, 1.3, 1.5)
		cs.shape = b
		cs.position.y = 0.65
		_ice.add_child(cs)
		var m := BoxMesh.new()
		m.size = Vector3(1.55, 1.35, 1.55)
		var mat := AbilityModels.mat(Color(0.65, 0.9, 1.0, 0.55), 0.05, 0.4)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_ice.add_child(AbilityModels.mesh_node(m, mat, Vector3(0, 0.65, 0)))
		add_child(_ice)
	_ice.scale = Vector3.ZERO
	create_tween().tween_property(_ice, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK)


func _unfreeze() -> void:
	if _anim:
		_anim.play()
	if _ice:
		_ice.queue_free()
		_ice = null
	Sfx.play("glass", -6.0, 0.7)


func _on_touch(b: Node) -> void:
	if _dead or not (b is Bip) or _frozen > 0.0:
		return
	var bip: Bip = b
	if bip.spin_left > 0.0:
		on_spin(bip)
		return
	if bip.pounding or (bip.global_position.y > global_position.y + 0.55 and bip.velocity.y < 1.0):
		on_stomp(bip)
	else:
		bip.take_hit(global_position)


func on_stomp(bip: Node) -> void:
	if _dead:
		return
	if bip.has_method("bounce"):
		bip.bounce(11.0)
	die()


func on_pound(_bip: Node) -> void:
	die()


## Bip'in dönme saldırısı.
func on_spin(_bip: Node) -> void:
	if _dead or _frozen > 0.0:
		return
	die()


func die() -> void:
	if _dead:
		return
	_dead = true
	collision_layer = 0
	_hurt_area.set_deferred("monitoring", false)
	Sfx.play("pop")
	Haptics.vibrate(40)
	Fx.burst(global_position + Vector3.UP * 0.5, Color(1, 0.9, 0.4), 16, 4.0)
	Fx.hitstop(0.06)
	var cam := get_tree().get_first_node_in_group("follow_camera")
	if cam and cam.has_method("shake"):
		cam.shake(0.15)
	Battery.burst(get_parent(), global_position, batteries, String(name))
	var tw := create_tween()
	tw.tween_property(_model, "scale", _model.scale * Vector3(1.5, 0.2, 1.5), 0.1)
	tw.tween_property(_model, "scale", Vector3.ZERO, 0.25)
	tw.tween_callback(queue_free)
