extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestScale3D.rk"
var file_base_name = get_file_base_name(file_path)
var nodes: Array[Node]

var at_predefs := RKSShow.at_predefs

func wait_test_show(xnodes: Array[Node]):
	await wait_for_custom_statement("show", 0.2)
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
		assert_eq(n.scale, Vector3.ONE)

	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")

	await wait_test_show([parent, childA])
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.ScalePrecise, 0.2)
	assert_eq(
		parent.scale, Vector3(0.2, -0.4, 0.6),
		"\n-- 'scale 0.2 -0.4 0.6' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.ScaleAll, 0.2)
	assert_eq(
		parent.scale, Vector3.ONE * 2,
		"\n-- 'scale 2' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.ScaleAxis, 0.2)
	assert_eq(
		parent.scale.x, -2.0,
		"\n-- 'scale xy = -2' at %d --" % line_num
	)
	assert_eq(
		parent.scale.y, -2.0,
		"\n-- 'scale xy = -2' at %d --" % line_num
	)
	await wait_do_step()

	var prev_x: float = parent.scale.x
	await wait_for_custom_statement(RKSShow.ScaleAxis, 0.2)
	assert_almost_eq(
		parent.scale.x, prev_x + 0.5, 0.01,
		"\n-- 'scale x += 0.5' at %d --" % line_num
	)
	await wait_do_step()

	var prev_y: float = parent.scale.y
	await wait_for_custom_statement(RKSShow.ScaleAxis, 0.2)
	assert_almost_eq(
		parent.scale.y, prev_y - 2.5, 0.01,
		"\n-- 'scale y -= 2.5' at %d --" % line_num
	)
	await wait_do_step()

	prev_x = parent.scale.x
	await wait_for_custom_statement(RKSShow.ScaleAxis, 0.2)
	assert_almost_eq(
		parent.scale.x, prev_x / 2.0, 0.01,
		"\n-- 'scale x /= 2' at %d --" % line_num
	)
	await wait_do_step()

	var prev_z: float = parent.scale.z
	await wait_for_custom_statement(RKSShow.ScaleAxis, 0.2)
	assert_almost_eq(
		parent.scale.z, prev_z * 3.0, 0.1,
		"\n-- 'scale z *= 3' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.Hide, 0.2)
	assert_false(parent.visible)
	await wait_do_step("end")

	await wait_execute_script_finished(file_base_name)

	if !nodes.is_empty():
		for n in nodes:
			n.queue_free()
