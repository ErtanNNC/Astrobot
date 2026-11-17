extends AnimatableBody3D
## İleri geri giden platform. Bip üstündeyken platformla birlikte taşınır.

@export var offset := Vector3(0, 0, -6)  ## m, başlangıçtan gidilecek uzaklık
@export var duration := 3.0              ## s, tek yön süresi

var _start: Vector3
var _t := 0.0


func _ready() -> void:
	_start = position
	sync_to_physics = true


func _physics_process(delta: float) -> void:
	_t += delta
	var phase := (1.0 - cos(_t / duration * PI)) * 0.5  # 0 → 1 → 0, yumuşak
	position = _start + offset * phase
