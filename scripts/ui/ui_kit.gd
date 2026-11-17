class_name UIKit
extends RefCounted
## Menülerde ortak görünüş: büyük, dokunmaya uygun butonlar ve yuvarlak paneller.

const BTN_HEIGHT := 78.0
const FONT_SIZE := 30
const BLUE := Color(0.25, 0.45, 0.8)
const GREEN := Color(0.3, 0.75, 0.4)
const RED := Color(0.85, 0.3, 0.3)


static func panel(parent: Node, min_width := 460.0) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.13, 0.2, 0.38, 0.95)
	sb.set_corner_radius_all(28)
	sb.set_content_margin_all(28)
	sb.border_color = Color(1, 1, 1, 0.25)
	sb.set_border_width_all(3)
	pc.add_theme_stylebox_override("panel", sb)
	center.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.custom_minimum_size = Vector2(min_width, 0)
	pc.add_child(v)
	return v


static func title(parent: Node, text: String, size := 38) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	parent.add_child(l)
	return l


static func button(parent: Node, text: String, cb: Callable, col := BLUE) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, BTN_HEIGHT)
	b.add_theme_font_size_override("font_size", FONT_SIZE)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var s := StyleBoxFlat.new()
		var c := col
		if state in ["hover", "focus"]:
			c = col.lightened(0.15)
		elif state == "pressed":
			c = col.darkened(0.2)
		elif state == "disabled":
			c = Color(0.35, 0.38, 0.45)
		s.bg_color = c
		s.set_corner_radius_all(20)
		if state == "focus":
			s.border_color = Color.WHITE
			s.set_border_width_all(3)
		b.add_theme_stylebox_override(state, s)
	b.pressed.connect(func(): Sfx.play("click", -4.0))
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


static func dim(parent: Node) -> ColorRect:
	var d := ColorRect.new()
	d.color = Color(0.05, 0.08, 0.18, 0.55)
	d.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(d)
	return d
