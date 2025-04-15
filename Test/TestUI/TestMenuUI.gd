extends KitTest

const menu_box_scene = "res://scenes/DialogueUI/menu_container.tscn"
const file_path = "res://Test/TestUI/TestMenu.rk"

var file_base_name = get_file_base_name(file_path)

func assert_menu_ui_choices(menu_box:Node, choices:Array):
	for id in choices.size():
		var choice := menu_box.get_child(id) as AdvancedTextButton
		assert_not_null(choice)
		assert_eq(choices[id], choice._text)

func assert_menu_ui_return(menu_box:Node, choice_id:int):
	var choice := menu_box.get_child(choice_id) as AdvancedTextButton
	assert_not_null(choice)
	choice.pressed.emit()

func test_menu_ui():
	var menu_container = add_from_scene(menu_box_scene)
	assert_not_null(menu_container)
	var menu_box = menu_container.get_node("MenuBox")
	assert_not_null(menu_box)
	
	watch_rakugo_signals()
	await wait_parse_and_execute_script(file_path)
	
	var choices := ["Loop0", "End", "Loop1"]
	await wait_menu(choices)
	await wait_for_signal(menu_box.menu_ready, 0.2)
	await wait_visblity(menu_box)
	assert_menu_ui_choices(menu_box, choices)
	assert_eq(menu_box.get_child_count(), choices.size())
	
	assert_menu_ui_return(menu_box, 0)
	await wait_for_signal(menu_box.menu_clean, 0.2)
	
	await wait_menu(choices)
	await wait_for_signal(menu_box.menu_ready, 0.2)
	await wait_visblity(menu_box)
	assert_menu_ui_choices(menu_box, choices)
	assert_eq(menu_box.get_child_count(), choices.size())

	assert_menu_ui_return(menu_box, 1)
	await wait_for_signal(menu_box.menu_clean, 0.2)
	await wait_visblity(menu_box, false)
	assert_eq(menu_box.get_child_count(), 0)

	await wait_execute_script_finished(file_base_name)
