extends KitTest

const say_panel_scene = "res://scenes/DialogueUI/say_panel.tscn"
const file_path = "res://Test/TestUI/TestSay.rk"

var file_base_name = get_file_base_name(file_path)

func test_say_ui():
	var say_panel := add_from_scene(say_panel_scene) as DialoguePanel
	assert_dialogue_panel(say_panel)
	watch_rakugo_signals()
	await wait_parse_and_execute_script(file_path)

	await wait_say({}, "Hello, world !")
	assert_dialogue_panel_text(say_panel, "", "Hello, world !")
	await wait_visblity(say_panel)
	say_panel.next_btn.pressed.emit()
	
	await wait_say({"name": "Sylvie"}, "Hello !")
	assert_dialogue_panel_text(say_panel, "# Sylvie\n", "Hello !")
	await wait_visblity(say_panel)
	say_panel.next_btn.pressed.emit()

	await wait_say({}, "My name is Sylvie")
	assert_dialogue_panel_text(say_panel, "", "My name is Sylvie")
	await wait_visblity(say_panel)
	say_panel.next_btn.pressed.emit()

	await wait_say({}, "I am 18")
	assert_dialogue_panel_text(say_panel, "", "I am 18")
	await wait_visblity(say_panel)
	
	say_panel.next_btn.pressed.emit()
	await wait_visblity(say_panel, false)

	await wait_execute_script_finished(file_base_name)


