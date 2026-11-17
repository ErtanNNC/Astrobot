extends Node
## Telefonda titreşim (autoload: Haptics). PC'de hiçbir şey yapmaz.

var enabled := true


func vibrate(ms: int) -> void:
	if not enabled:
		return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)
