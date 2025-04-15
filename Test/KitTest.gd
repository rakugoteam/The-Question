extends RakugoTest
class_name KitTest

var last_statement: String

func watch_custom_statments():
	if !Rakugo.sg_custom_regex.is_connected(_on_custom_regex):
		Rakugo.sg_custom_regex.connect(_on_custom_regex)

func _on_custom_regex(key: String, _result: RegExMatch):
	last_statement = key

func wait_for_custom_statement(statement_id: String, max_wait: float):
	await wait_for_signal(
		Rakugo.sg_custom_regex, max_wait,
		"\n-- '%s' at line: %d --" % [
			statement_id, line_num]
	)
	assert_eq(last_statement, statement_id)
	last_statement = ""
	line_num += 1

func add_from_scene(path: String) -> Node:
	var scene = load(path)
	return add_node(scene.instantiate())

func add_node(node: Node, parent: Node = null, node_name := "") -> Node:
	if !parent:
		parent = get_tree().current_scene
	parent.add_child(node)
	assert_not_null(node)
	if node_name:
		node.name = node_name
	return node

func assert_dialogue_panel(dialogue_panel: DialoguePanel):
	var nodes := [
		dialogue_panel,
		dialogue_panel.character_name_label,
		dialogue_panel.dialogue_label
	]
	for node in nodes:
		assert_not_null(node)

func assert_dialogue_panel_text(dialogue_panel: DialoguePanel, character_name, dialogue_text):
	assert_adv_text(dialogue_panel.character_name_label, character_name)
	assert_adv_text(dialogue_panel.dialogue_label, dialogue_text)

func wait_visblity(visible_node: Node, visibility := true):
	await wait_for_signal(visible_node.visibility_changed, 0.2)
	if visibility:
		assert_true(visible_node.visible, visible_node.name + " visibility")
	else:
		assert_false(visible_node.visible, visible_node.name + " visibility")

func wait_do_step(say_text := "step"):
	await wait_say({}, say_text)
	assert_do_step()

func assert_adv_text(adv_text: AdvancedTextLabel, text: String):
	assert_eq(adv_text._text, text)
