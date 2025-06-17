extends Node
class_name RKSExtension

const err_mess_01 := "%s statement is missing any node name from `%s` group"
const err_mess_02 := "no node called %s is in %s group"
const err_mess_03 := "node %s in %s group doesn't have method %s"
const err_mess_04 := "statement %s must be after %s statement"

var group_name: StringName:
	get: return _group_name()

func _group_name() -> StringName:
	return &"some_group_name"

func _ready():
	Rakugo.sg_custom_regex.connect(_on_custom_regex)

func rk_get_nodes(rk_node_path: String) -> Array[Node]:
	var path_elements := Array(rk_node_path.split(" ", false))
	var root_node_name := path_elements.pop_front()
	var root_node: Node

	for node in get_tree().get_nodes_in_group(group_name):
		if node.name == root_node_name:
			root_node = node
			break
	
	if not root_node:
		push_error(err_mess_02 % [root_node_name, group_name])
		return []
	
	if path_elements.is_empty(): return [root_node]
	
	var node := root_node
	var nodes: Array[Node] = [root_node]
	for element in path_elements:
		var n := node.get_node(element)
		nodes.append(n)
		node = n

	return nodes

func rk_get_node(rk_node_name: String) -> Node:
	for node in get_tree().get_nodes_in_group(group_name):
		if node.name == rk_node_name: return node
	
	push_error(err_mess_02 % [rk_node_name, group_name])
	return null

func try_call_method(node: Node, method: String, err_mess := "") -> void:
	if node.has_method(method):
		node.call(method)
	
	elif err_mess:
		push_error(err_mess)

func _on_custom_regex(key: String, result: RegExMatch):
	pass
