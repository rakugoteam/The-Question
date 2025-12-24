extends RKSExtension

var vnk = VisualNovelKit

const Show := "show"
const Hide := "hide"
const AtPrecise = "at precise"
const AtPercent = "at percent"
const AtAxis = "at axis"
const AtPredef = "at predef"
const ScaleAll = "scale all"
const ScalePrecise = "scale precise"
const ScaleAxis = "scale axis"
const Rotate2D = "rotate 2D"
const Rotate3D = "rotate 3D"

const regex := {
	Show:
		"^show(( +\\w+)+)$",
	Hide:
		"^hide(( +\\w+)+)$",
	AtPrecise:
		"^at +({NUMERIC}) +({NUMERIC})( +({NUMERIC}))?$",
	AtPercent:
		"^at% +({NUMERIC}) +({NUMERIC})$",
	AtAxis:
		"^at +([xyz]{1,3}) *([-+\\*\\/])?= *({NUMERIC})$",
	AtPredef:
		"^at +(\\w+)$",
	ScalePrecise:
		"^scale +({NUMERIC}) +({NUMERIC})( +({NUMERIC}))?$",
	ScaleAll:
		"^scale +({NUMERIC})$",
	ScaleAxis:
		"^scale +([xyz]{1,3}) *([-+\\*\\/])?= *({NUMERIC})$",
	Rotate2D:
		"^rotate +({NUMERIC})$",
	Rotate3D:
		"^rotate +({NUMERIC}) +(\\w+)$",
}

@onready
var at_predefs := {
	# center
	"center": vnk.at_center,
	"left": Vector2(vnk.at_left, vnk.at_center.y),
	"right": Vector2(vnk.at_right, vnk.at_center.y),

	# top
	"top": Vector2(vnk.at_center.x, vnk.at_top),
	"top_left": Vector2(vnk.at_left, vnk.at_top),
	"top_right": Vector2(vnk.at_right, vnk.at_top),
	
	# bottom
	"bottom": Vector2(vnk.at_center.x, vnk.at_bottom),
	"bottom_left": Vector2(vnk.at_left, vnk.at_bottom),
	"bottom_right": Vector2(vnk.at_right, vnk.at_bottom),
}

var last_node: Node

func _group_name() -> StringName:
	return Show

func _ready():
	for key in regex: Rakugo.add_custom_regex(key, regex[key])
	super._ready()

func _on_custom_regex(key: String, result: RegExMatch):
	if key not in regex: return
	var err_key := key
	if " " in err_key: err_key = err_key.split(" ", false)[0]
	
	if result.get_group_count() == 0:
		push_error(err_mess_01 % [err_key, group_name])
		return

	if key not in [Show, Hide] and not last_node:
			push_error(err_mess_04 % [err_key, Show])
			return

	match key:
		Show:
			var nodes := rk_get_nodes(result.get_string(1))
			if !nodes: return
			last_node = nodes[0]

			for node in nodes:
				for ch in node.get_children():
					try_call_method(ch, Hide)
				
				var err := err_mess_03 % [
					node.name, group_name, Show
				]
				try_call_method(node, Show, err)
		
		Hide:
			var nodes := rk_get_nodes(result.get_string(1))
			if !nodes: return
			
			for node in nodes:
				var err := err_mess_03 % [
					node.name, group_name, Hide
				]
				try_call_method(node, Hide, err)
		
		AtPrecise:
			var x := float(result.get_string(1))
			var y := float(result.get_string(2))

			if result.get_string(4):
				var z := float(result.get_string(4))
				last_node.position = Vector3(x, y, z)
				return
			
			last_node.position = Vector2(x, y)
		
		AtAxis:
			var axis := result.get_string(1)
			var operator := result.get_string(2)
			var value := float(result.get_string(3))
			last_node.position = calc_axis(
				last_node.position, operator, axis, value
			)
		
		AtPercent:
			var procent := Vector2()
			procent.x = float(result.get_string(1)) / 100
			procent.y = float(result.get_string(2)) / 100
			var vp_size := get_viewport().get_visible_rect().size
			last_node.position = procent * vp_size
		
		AtPredef:
			var predef := result.get_string(1)
			var procent: Vector2 = at_predefs[predef]
			var vp_size := get_viewport().get_visible_rect().size
			last_node.position = procent * vp_size

		ScaleAll:
			var scale := float(result.get_string(1))

			if last_node.scale is Vector2:
				last_node.scale = Vector2.ONE * scale
				return

			if last_node.scale is Vector3:
				last_node.scale = Vector3.ONE * scale
			
			return

		ScalePrecise:
			var x := float(result.get_string(1))
			var y := float(result.get_string(2))
	
			if result.get_string(4):
				var z := float(result.get_string(4))
				last_node.scale = Vector3(x, y, z)
				return
			
			last_node.scale = Vector2(x, y)
			return
		
		ScaleAxis:
			var axis := result.get_string(1)
			var operator := result.get_string(2)
			var value := float(result.get_string(3))

			last_node.scale = calc_axis(
				last_node.scale, operator, axis, value
			)
		
		Rotate2D:
			var angle := result.get_string(1)
			last_node.rotation_degrees = float(angle)
	
		Rotate3D:
			var angle := result.get_string(1)
			var axis_str := result.get_string(2)

			var axis := str_to_axis(axis_str)
			last_node.rotation = last_node.rotation.rotated(axis, float(angle))

func calc_axis(vector, operator: String, axis: String, value: float):
	if "x" in axis: vector.x = _axis(vector.x, operator, value)
	if "y" in axis: vector.y = _axis(vector.y, operator, value)
	if "z" in axis: vector.z = _axis(vector.z, operator, value)
	if axis == "":
		if vector is Vector2:
			return calc_axis(vector, operator, "xy", value)

		if vector is Vector3:
			return calc_axis(vector, operator, "xyz", value)
	
	return vector

func _axis(axis: float, operator: String, value: float) -> float:
	match operator:
		"-": return axis - value
		"+": return axis + value
		"*": return axis * value
		"/": return axis / value
		_: return value

func str_to_axis(axis_str: String) -> Vector3:
	match axis_str:
		"up": return Vector3.UP
		"down": return Vector3.DOWN
		"forward": return Vector3.FORWARD
		"back": return Vector3.BACK
		"left": return Vector3.LEFT
		"right": return Vector3.RIGHT
		
	push_error("rotate around %s axis_str isn't supported" % axis_str)
	return Vector3.ZERO
