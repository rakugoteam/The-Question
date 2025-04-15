extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestRotate3D.rk"
var file_base_name = get_file_base_name(file_path)
var nodes: Array[Node]

func wait_test_show(xnodes: Array[Node]):
	await wait_for_custom_statement("show", 0.2)
	for node: Node in xnodes:
		assert_true(node.visible)

func test_node3d():
	await make_test(Node3D.new)

func assert_3D_rotation(node: Node, angle: float, axis_str: String):
	await wait_for_custom_statement(RKSShow.Rotate3D, 0.2)
	var axis := RKSShow.str_to_axis(axis_str)
	assert_eq(
		node.rotation_degrees, node.rotation.rotated(axis, angle),
		"\n-- 'rotate %d %s' at %d --" % [angle, axis, line_num]
	)

func make_test(constructor: Callable):
	var parent := add_node(constructor.call(), null, "Parent")
	parent.add_to_group("show")

	var childA := add_node(constructor.call(), parent, "ChildA")

	nodes = [parent, childA]
	for n in nodes:
		n.hide()
		assert_eq(n.rotation_degrees, Vector3.ZERO)

	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")

	await wait_test_show([parent, childA])
	await wait_do_step()
	await assert_3D_rotation(parent, 45, "up")
	await wait_do_step()
	await assert_3D_rotation(parent, 45, "down")
	await wait_do_step()
	await assert_3D_rotation(parent, 45, "forward")
	await wait_do_step()
	await assert_3D_rotation(parent, 45, "back")
	await wait_do_step()
	await assert_3D_rotation(parent, 45, "left")
	await wait_do_step()
	await assert_3D_rotation(parent, 45, "right")
	await wait_do_step()
	
	await wait_for_custom_statement(RKSShow.Hide, 0.2)
	assert_false(parent.visible)
	await wait_do_step("end")

	await wait_execute_script_finished(file_base_name)

	if !nodes.is_empty():
		for n in nodes:
			n.queue_free()
