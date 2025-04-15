@tool
extends ProcentControl
class_name DialoguePanel

@export var character_name_label : AdvancedTextLabel = null
@export var dialogue_label : AdvancedTextLabel = null

var markup : TextParser

func _ready():
	markup = load(VisualNovelKit.default_markup_setting)
	if character_name_label:
		character_name_label.parser = markup
	
	if dialogue_label:
		dialogue_label.parser = markup

	visibility_changed.connect(_on_visibility_changed)
	
	visible = Engine.is_editor_hint()
	set_process(false)

func set_labels(character:Dictionary, text:String):
	show()
	
	var character_name = character.get("name", "")

	if not character_name:
		character_name_label._text = ""
	
	else:
		var name_label = "[h1]%s[/h1]" % character_name

		if markup is MarkdownParser:
			name_label = "# %s\n" % character_name

		var character_color = character.get("color", null)
		
		if character_color:
			name_label = "[color=%s]%s[/color]" % [character_color, name_label]
		
		character_name_label._text = name_label
	
	dialogue_label._text = text

func _on_visibility_changed():
	set_process(visible)
