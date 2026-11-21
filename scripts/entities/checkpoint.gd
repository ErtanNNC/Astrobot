extends Area3D
## Kontrol noktası: bayrak; Bip değince yanar, otomatik kayıt yapılır ([kayıt]).
## Yeniden doğma noktası: bu düğümün konumu ve yönü.

@export var checkpoint_id := "cp1"

var active := false
var _flag: Node3D
var _bulb_mat: StandardMaterial3D


func _ready() -> void:
	add_to_group("checkpoint")
	collision_layer = 0
	collision_mask = 1
	var cs := CollisionShape3D.new()
	var sh := CylinderShape3D.new()
	sh.radius = 1.4
	sh.height = 3.0
	cs.shape = sh
	cs.position.y = 1.5
	add_child(cs)
	# Direk + parlayan antenli lamba (Bip'in anteni gibi)
	var pole := CylinderMesh.new()
	pole.radial_segments = 16
	pole.rings = 1
	pole.top_radius = 0.06
	pole.bottom_radius = 0.09
	pole.height = 2.0
	add_child(AbilityModels.mesh_node(pole, AbilityModels.mat(Color(0.75, 0.78, 0.85), 0.3), Vector3(1.0, 1.0, 0)))
	var base := CylinderMesh.new()
	base.radial_segments = 16
	base.rings = 1
	base.top_radius = 0.3
	base.bottom_radius = 0.4
	base.height = 0.2
	add_child(AbilityModels.mesh_node(base, AbilityModels.mat(Color(0.35, 0.4, 0.5)), Vector3(1.0, 0.1, 0)))
	_bulb_mat = AbilityModels.mat(Color(0.5, 0.5, 0.55), 0.3)
	var bulb := SphereMesh.new()
	bulb.radial_segments = 12
	bulb.rings = 6
	bulb.radius = 0.22
	bulb.height = 0.44
	add_child(AbilityModels.mesh_node(bulb, _bulb_mat, Vector3(1.0, 2.15, 0)))
	var fl := BoxMesh.new()
	fl.size = Vector3(0.7, 0.45, 0.04)
	_flag = AbilityModels.mesh_node(fl, AbilityModels.mat(Color(0.6, 0.6, 0.65)), Vector3(1.4, 1.6, 0))
	add_child(_flag)
	body_entered.connect(_on_body)
	var lvl := get_tree().current_scene
	if lvl and "area_id" in lvl and GameState.data.get("area", "") == lvl.area_id \
			and GameState.data.get("checkpoint_id", "") == checkpoint_id:
		_light_up(false)


func _on_body(b: Node) -> void:
	if b is Bip and not active:
		_light_up(true)
		var lvl := get_tree().current_scene
		if lvl and lvl.has_method("on_checkpoint"):
			lvl.on_checkpoint(self)


func _light_up(fx: bool) -> void:
	active = true
	_bulb_mat.albedo_color = Color(0.4, 0.95, 1.0)
	_bulb_mat.emission_enabled = true
	_bulb_mat.emission = Color(0.3, 0.9, 1.0)
	_bulb_mat.emission_energy_multiplier = 3.0
	(_flag.material_override as StandardMaterial3D).albedo_color = Color(0.3, 0.85, 1.0)
	if fx:
		Sfx.play("checkpoint")
		Fx.ring(global_position, Color(0.4, 0.9, 1.0), 2.4, 0.5)
		Fx.confetti(global_position + Vector3.UP * 1.6)
		Haptics.vibrate(40)
		var tw := create_tween()
		tw.tween_property(_flag, "scale", Vector3(1.4, 1.4, 1), 0.12)
		tw.tween_property(_flag, "scale", Vector3.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
