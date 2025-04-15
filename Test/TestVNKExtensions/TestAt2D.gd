extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestAt2D.rk"
var file_base_name = get_file_base_name(file_path)
var nodes: Array[Node]

var at_predefs := RKSShow.at_predefs

func wait_test_show(xnodes: Array[Node]):
	await wait_for_custom_statement(RKSShow.Show, 0.2)
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
		assert_eq(n.position, Vector2.ZERO)

	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")

	await wait_test_show([parent])
	await wait_do_step()

	var vp_size := get_viewport().get_visible_rect().size
	await wait_for_custom_statement(RKSShow.AtPercent, 0.2)
	assert_eq(
		parent.position, Vector2.ONE * 0.5 * vp_size,
		"\n-- 'at% 50 50' %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPrecise, 0.2)
	assert_eq(
		parent.position, Vector2(148, -156),
		"\n-- 'at 148 156' at %d --" % line_num
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

	prev_x = parent.position.x
	await wait_for_custom_statement(RKSShow.AtAxis, 0.2)
	assert_eq(
		parent.position.x, prev_x - 25.0,
		"\n-- 'at x -25' at %d --" % line_num
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

	await wait_for_custom_statement("show", 0.2)
	assert_true(childA.visible)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPercent, 0.2)
	assert_not_same(
		childA.position, Vector2.ONE * 0.25 * vp_size,
		"\n-- 'at% 25 25' at %d --" % line_num
	)
	assert_eq(
		parent.position, Vector2.ONE * 0.25 * vp_size,
		"\n-- 'at% 25 25' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPrecise, 0.2)
	assert_eq(
		parent.position, Vector2.ZERO,
		"\n-- 'at 0 0' at %d --" % line_num
	)
	await wait_do_step()
	
	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["center"] * vp_size,
		"\n-- 'at center' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["left"] * vp_size,
		"\n-- 'at left' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["right"] * vp_size,
		"\n-- 'at right' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["top"] * vp_size,
		"\n-- 'at top' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["top_left"] * vp_size,
		"\n-- 'at top_left' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["top_right"] * vp_size,
		"\n-- 'at top_right' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["bottom"] * vp_size,
		"\n-- 'at bottom' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["bottom_left"] * vp_size,
		"\n-- 'at bottom_left' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.AtPredef, 0.2)
	assert_eq(
		parent.position, at_predefs["bottom_right"] * vp_size,
		"\n-- 'at bottom_right' at %d --" % line_num
	)
	await wait_do_step()

	await wait_for_custom_statement(RKSShow.Hide, 0.2)
	assert_false(parent.visible)
	await wait_do_step("end")

	await wait_execute_script_finished(file_base_name)

	if !nodes.is_empty():
		for n in nodes:
			n.queue_free()
