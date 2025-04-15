@tool
class_name ChoiceButton
extends ButtonContainer

@export var label: AdvancedTextLabel:
	set(value):
		label = value
		if !is_node_ready(): await ready
		if label:
			label.parser = parser
			label.advanced_text = text

@export var parser: TextParser:
	set(value):
		parser = value
		if !is_node_ready(): await ready
		if label: label.parser = value

@export_multiline var text := "":
	set(value):
		text = value
		if !is_node_ready(): await ready
		if label: label.advanced_text = value

func _ready() -> void:
	super._ready()
	if label:
		label.parser = parser
		label.advanced_text = text