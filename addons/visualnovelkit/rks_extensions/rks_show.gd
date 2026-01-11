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
	"default": vnk.at_center,
	"truecenter": Vector2(0.5, 0.5),
	"left": Vector2(vnk.at_left, vnk.at_center.y),
	"right": Vector2(vnk.at_right, vnk.at_center.y),

	# top
	"top": Vector2(vnk.at_center.x, vnk.at_top),
	"top_left": Vector2(vnk.at_left, vnk.at_top),
	"topleft": Vector2(vnk.at_left, vnk.at_top),
	"top_right": Vector2(vnk.at_right, vnk.at_top),
	"topright": Vector2(vnk.at_right, vnk.at_top),
	
	# bottom
	"bottom": Vector2(vnk.at_center.x, vnk.at_bottom),
	"bottom_left": Vector2(vnk.at_left, vnk.at_bottom),
	"bottomleft": Vector2(vnk.at_left, vnk.at_bottom),
	"bottom_right": Vector2(vnk.at_right, vnk.at_bottom),
	"bottomright": Vector2(vnk.at_right, vnk.at_bottom),
}

var last_node: Node
var character_positioner: Node = null

func _group_name() -> StringName:
	return Show

func _ready():
	for key in regex: Rakugo.add_custom_regex(key, regex[key])
	super._ready()
	_find_character_positioner()

func _find_character_positioner() -> void:
	# Find the CharacterPositioner node in the scene tree
	var root := get_tree().get_root()
	var found := root.find_child("CharacterPositioner", true, false)
	if found != null:
		character_positioner = found

func _ensure_character_positioner() -> void:
	if character_positioner == null or !is_instance_valid(character_positioner):
		_find_character_positioner()

func _get_character_positioner(node: Node) -> Node:
	if node != null and node.has_method("set_default_positioning"):
		return node
	if node != null:
		var child := node.find_child("CharacterPositioner", true, false)
		if child != null and child.has_method("set_default_positioning"):
			return child
	_ensure_character_positioner()
	if character_positioner != null and character_positioner.has_method("set_default_positioning"):
		return character_positioner
	return null

func _is_character(node: Node) -> bool:
	return node != null and node.is_in_group(&"character")

func _normalize_percent(percent: Vector2) -> Vector2:
	var x := percent.x
	var y := percent.y
	if x > 1.0: x /= 100.0
	if y > 1.0: y /= 100.0
	return Vector2(x, y)

func _apply_at_precise(x: float, y: float, z_str: String = "") -> void:
	var is_character := _is_character(last_node)
	if not is_character:
		if z_str != "":
			var z := float(z_str)
			last_node.position = Vector3(x, y, z)
		else:
			last_node.position = Vector2(x, y)

	if is_character:
		var positioner := _get_character_positioner(last_node)
		if positioner != null and positioner.has_method("set_explicit_position"):
			var vp_size := get_viewport().get_visible_rect().size
			var percent_pos := Vector2(x / vp_size.x, y / vp_size.y)
			positioner.set_explicit_position(percent_pos, false)

func _apply_at_percent(percent: Vector2) -> void:
	var normalized := _normalize_percent(percent)
	if not _is_character(last_node):
		var vp_size := get_viewport().get_visible_rect().size
		last_node.position = normalized * vp_size

	if _is_character(last_node):
		var positioner := _get_character_positioner(last_node)
		if positioner != null and positioner.has_method("set_explicit_position"):
			positioner.set_explicit_position(normalized, false)

func _apply_at_predef(predef: String) -> void:
	var key := predef.to_lower()
	var is_character := _is_character(last_node)
	if is_character and key == "reset":
		var positioner := _get_character_positioner(last_node)
		if positioner != null and positioner.has_method("set_default_positioning"):
			positioner.set_default_positioning()
		return

	if not is_character:
		if key not in at_predefs:
			push_error("predef %s isn't supported" % key)
			return
		var procent: Vector2 = _normalize_percent(at_predefs[key])
		var vp_size := get_viewport().get_visible_rect().size
		last_node.position = procent * vp_size

	if is_character:
		var positioner := _get_character_positioner(last_node)
		if positioner != null and positioner.has_method("set_explicit_position"):
			var procent := Vector2.ZERO
			if key in at_predefs:
				procent = _normalize_percent(at_predefs[key])
			positioner.set_explicit_position(procent, true, key)

func _parse_show_with_at(raw: String) -> Dictionary:
	var tokens := raw.strip_edges().split(" ", false)
	var show_tokens: PackedStringArray = tokens
	var at_tokens := PackedStringArray()

	var at_index := tokens.find("at")
	if at_index == -1:
		at_index = tokens.find("at%")

	if at_index != -1:
		show_tokens = tokens.slice(0, at_index)
		at_tokens = tokens.slice(at_index, tokens.size())

	return {
		"show_tokens": show_tokens,
		"at_tokens": at_tokens,
	}

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

	_ensure_character_positioner()

	match key:
		Show:
			var parsed := _parse_show_with_at(result.get_string(1))
			var show_tokens: PackedStringArray = parsed.get("show_tokens", PackedStringArray())
			var at_tokens: PackedStringArray = parsed.get("at_tokens", PackedStringArray())
			var show_path := " ".join(show_tokens)
			var nodes := rk_get_nodes(show_path)
			if !nodes: return
			last_node = nodes[0]

			for node in nodes:
				for ch in node.get_children():
					try_call_method(ch, Hide)

				var err := err_mess_03 % [
					node.name, group_name, Show
				]
				try_call_method(node, Show, err)

			if at_tokens.is_empty():
				# Reset to default positioning when showing a character without explicit position
				if _is_character(last_node):
					var positioner := _get_character_positioner(last_node)
					if positioner != null and positioner.has_method("set_default_positioning"):
						positioner.set_default_positioning()
			else:
				var at_key := at_tokens[0]
				if at_key == "at":
					if at_tokens.size() == 2:
						_apply_at_predef(at_tokens[1])
					elif at_tokens.size() >= 4 and at_tokens[1].to_lower() == "percent" and at_tokens[2].is_valid_float() and at_tokens[3].is_valid_float():
						_apply_at_percent(Vector2(float(at_tokens[2]), float(at_tokens[3])))
					elif at_tokens.size() >= 3 and at_tokens[1].is_valid_float() and at_tokens[2].is_valid_float():
						var z_str := ""
						if at_tokens.size() >= 4 and at_tokens[3].is_valid_float():
							z_str = at_tokens[3]
						_apply_at_precise(float(at_tokens[1]), float(at_tokens[2]), z_str)
				elif at_key == "at%":
					if at_tokens.size() >= 3 and at_tokens[1].is_valid_float() and at_tokens[2].is_valid_float():
						_apply_at_percent(Vector2(float(at_tokens[1]), float(at_tokens[2])))
		
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
			var z_str := result.get_string(4)
			_apply_at_precise(x, y, z_str)
			return
		
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
			_apply_at_percent(procent)
		
		AtPredef:
			var predef := result.get_string(1)
			_apply_at_predef(predef)

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
