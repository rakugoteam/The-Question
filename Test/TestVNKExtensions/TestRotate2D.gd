extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestRotate2D.rk"
var file_base_name = get_file_base_name(file_path)
var nodes: Array[Node]

func wait_test_show(xnodes: Array[Node]):
	await wait_for_custom_statement("show", 0.2)
	for node: Node in xnodes:
		assert_true(node.visible)

func test_node2d():
	await make_test(Node2D.new)

func test_control():
	await make_test(Control.new)

func make_test(constructor: Callable):
	var parent := add_node(constructor.call(), null, "Parent")
	parent.add_to_group("show")

	var childA := add_node(constructor.call(), parent, "ChildA")

	nodes = [parent, childA]
	for n in nodes:
		n.hide()
		assert_eq(n.rotation_degrees, 0.0)

	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")

	await wait_test_show([parent, childA])
	await wait_do_step()
	
	await wait_for_custom_statement(RKSShow.Rotate2D, 0.2)
	assert_eq(
		parent.rotation_degrees, 45.0,
		"\n-- 'rotate 45' at %d --" % line_num
	)
	assert_eq(
		childA.rotation_degrees, 0.0,
		"\n-- 'rotate 45' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.Hide, 0.2)
	assert_false(parent.visible)
	await wait_do_step("end")

	await wait_execute_script_finished(file_base_name)

	if !nodes.is_empty():
		for n in nodes:
			n.queue_free()
