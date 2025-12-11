extends Control

var curve_array: Array
var graph_width = 170
var graph_height = 170
var curve_point = 0.2
var p = true

## Draw the curve in the graph box. 
## Input: Array[100] of Curve values
func draw_curve(curve: Array):
	var curve_size = curve.size()
	if curve_size == 0:
		curve_size = 100
	var x_mod = (graph_width - 20) / float(curve_size)
	
	draw_rect(Rect2(
		Vector2(0.0,0.0), Vector2(
			float(graph_width), 
			float(graph_height - 10))), 
		Color.GRAY, false, 2)
	for n in (curve.size()-1):
		if p:
			p = false
		draw_line(
			Vector2(10 + (n) * x_mod , graph_height - curve[n] * curve_point), 
			Vector2(10 + (n+1) * x_mod , graph_height - curve[(n+1)] * curve_point),
			Color.WHEAT, 2)
	
func _draw():
	draw_curve(curve_array)
	
