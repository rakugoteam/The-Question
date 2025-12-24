@tool
extends ProcentControl
class_name DialoguePanel

@export var character_name_label: AdvancedTextLabel = null
@export var dialogue_label: AdvancedTextLabel = null

var markup: TextParser

func _ready():
	markup = load(VisualNovelKit.default_markup_setting)
	if character_name_label: character_name_label.parser = markup
	if dialogue_label: dialogue_label.parser = markup
	visible = Engine.is_editor_hint()

func set_labels(character: Dictionary, text: String):
	await get_tree().create_timer(0.1).timeout
	if !visible: show()
	var character_name = character.get("name", "")
	var character_color = character.get("color", null)
	
	var name_label := "[h1]%s[/h1]" % character_name
	if character_color: name_label = "[color=%s]%s[/color]" % [character_color, name_label]
	
	if markup is MarkdownParser:
		if !character_name: name_label = ""
		else:
			name_label = "# %s\n" % character_name
			if character_color:
				name_label = "# [color=%s]%s[/color]\n" % [character_color, character_name]

	character_name_label.advanced_text = name_label
	dialogue_label.advanced_text = text