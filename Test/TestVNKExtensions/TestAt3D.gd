extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestAt3D.rk"
var file_base_name = get_file_base_name(file_path)
var nodes: Array[Node]

var at_predefs := RKSShow.at_predefs

func wait_test_show(xnodes: Array[Node]):
	await wait_for_custom_statement(RKSShow.Show, 0.2)
	for node: Node in xnodes:
		assert_true(node.visible)

func test_node3d():
	await make_test(Node3D.new)

func make_test(constructor: Callable):
	var parent := add_node(constructor.call(), null, "Parent")
	parent.add_to_group("show")

	var childA := add_node(constructor.call(), parent, "ChildA")

	nodes = [parent, childA]
	for n in nodes:
		n.hide()
		assert_eq(n.position, Vector3.ZERO)

	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")

	await wait_test_show([parent, childA])
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPrecise, 0.2)
	assert_eq(
		parent.position, Vector3(148, -156, 265),
		"\n-- 'at 148 -156 265' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtAxis, 0.2)
	assert_eq(
		parent.position.y, 200.0,
		"\n-- 'at y = 200' at %d --" % line_num
	)
	await wait_do_step()

	var prev_x = parent.position.x
	await wait_for_custom_statement(RKSShow.AtAxis, 0.2)
	assert_eq(
		parent.position.x, prev_x + 50.0,
		"\n-- 'at x + 50' at %d --" % line_num
	)

	await wait_do_step()

	var prev_z = parent.position.z
	await wait_for_custom_statement(RKSShow.AtAxis, 0.2)
	assert_eq(
		parent.position.z, prev_z - 25.0,
		"\n-- 'at z -25' at %d --" % line_num
	)
	await wait_do_step()

	prev_x = parent.position.x
	await wait_for_custom_statement(RKSShow.AtAxis, 0.2)
	assert_eq(
		parent.position.x, prev_x / 2.0,
		"\n-- 'at x /2' at %d --" % line_num
	)
	await wait_do_step()

	prev_x = parent.position.x
	await wait_for_custom_statement(RKSShow.AtAxis, 0.2)
	assert_eq(
		parent.position.x, prev_x * 3.0,
		"\n-- 'at x *3' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement("hide", 0.2)
	assert_false(parent.visible)
	await wait_do_step("end")

	await wait_execute_script_finished(file_base_name)

	if !nodes.is_empty():
		for n in nodes:
			n.queue_free()
