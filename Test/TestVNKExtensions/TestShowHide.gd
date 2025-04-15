extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestShowHide.rk"
var file_base_name = get_file_base_name(file_path)
var nodes: Array[Node]

func wait_test_show(xnodes: Array[Node]):
	await wait_for_custom_statement(RKSShow.Show, 0.2)
	for node: Node in xnodes:
		assert_true(node.visible)

func test_node2d():
	await make_test(Node2D.new)

func test_control():
	await make_test(Control.new)

func test_node3d():
	await make_test(Node3D.new)

func make_test(constructor: Callable):
	var parent := add_node(constructor.call(), null, "Parent")
	parent.add_to_group("show")

	var childA := add_node(constructor.call(), parent, "ChildA")
	var childAA := add_node(constructor.call(), childA, "ChildAA")
	var childAB := add_node(constructor.call(), childA, "ChildAB")
	var childAC := add_node(constructor.call(), childA, "ChildAC")

	nodes = [parent, childA, childAA, childAB, childAB, childAC]
	for n in nodes:
		n.hide()

	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")

	await wait_test_show([parent])
	await wait_do_step()

	for node in [childA, childAA]:
		assert_false(node.visible)
	await wait_test_show([parent, childA, childAA])
	await wait_do_step()

	assert_false(childAB.visible)
	await wait_test_show([parent, childA, childAB])
	assert_false(childAA.visible)
	await wait_do_step()

	assert_false(childAC.visible)
	await wait_test_show([parent, childA, childAC])
	assert_false(childAB.visible)
	await wait_do_step()
	
	await wait_for_custom_statement(RKSShow.Hide, 0.2)
	assert_false(childAC.visible)
	await wait_do_step()
	
	await wait_for_custom_statement(RKSShow.Hide, 0.2)
	assert_false(parent.visible)
	await wait_do_step("end")

	await wait_execute_script_finished(file_base_name)

	if !nodes.is_empty():
		for n in nodes:
			n.queue_free()
