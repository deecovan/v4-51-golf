extends Control

var curve_array: Array

## Draw the curve in the graph box. 
## Input: Array[float(0.0..1.0)]
func draw_curve(curve: Array):
	draw_rect(Rect2(
		Vector2(0.0,0.0), Vector2(20 + float(curve.size() * 10), 120.0)), 
		Color.GRAY, false, 2)
	for n in curve.size():
		draw_line(
			Vector2(20 + (n-1)*10, 110 - curve[n-1] * 100), 
			Vector2(20 + n*10, 110 - curve[n] * 100),
			Color.WHEAT, 2)
	
func _draw():
	draw_curve(curve_array)
	
