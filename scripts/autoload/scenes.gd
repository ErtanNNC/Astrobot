extends CanvasLayer
## Sahne geçişleri (autoload: Scenes): kararıp açılan perde. Yüklenirken Bip'in anteni döner.

var _rect: ColorRect
var _busy := false
var _spin := 0.0


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(0.06, 0.08, 0.16, 0.0)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_rect.draw.connect(_draw_loader)


func _process(delta: float) -> void:
	if _rect.color.a > 0.5:
		_spin += delta * 6.0
		_rect.queue_redraw()


func _draw_loader() -> void:
	if _rect.color.a < 0.5:
		return
	var s := _rect.size
	var c := Vector2(s.x - 70, s.y - 70)
	draw_antenna(c, s.y / 720.0)


func draw_antenna(c: Vector2, k: float) -> void:
	var r := 22.0 * k
	var p := c + Vector2(cos(_spin), sin(_spin)) * r
	_rect.draw_line(c, p, Color.WHITE, 4 * k)
	_rect.draw_circle(p, 8 * k, Color(0.4, 0.95, 1.0))
	_rect.draw_circle(c, 6 * k, Color.WHITE)


func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, 0.35)
	await tw.finished
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(_rect, "color:a", 0.0, 0.45)
	await tw2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


## Aynı sahnede kısa karartma (yeniden doğma).
func blink(callback: Callable) -> void:
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, 0.18)
	tw.tween_callback(callback)
	tw.tween_interval(0.1)
	tw.tween_property(_rect, "color:a", 0.0, 0.3)
