class_name MenuBox
extends VBoxContainer

@export var root: Control
@export var choice_btn_scene: PackedScene

var markup: TextParser
var _choices: Array

signal menu_ready
signal menu_clean

func _ready():
	markup = load(VisualNovelKit.default_markup_setting)
	Rakugo.sg_menu.connect(_on_menu)
	if root: visibility_changed.connect(_on_visibility_changed)
	visible = Engine.is_editor_hint()

func _on_visibility_changed():
	root.visible = visible
	set_process(visible)
	set_process_input(visible)

func _on_menu(choices: Array):
	_choices = choices
	for id in choices.size():
		var choice_btn := choice_btn_scene.instantiate()
		add_child(choice_btn)
		choice_btn.parser = markup
		choice_btn.text = choices[id]
		choice_btn.pressed.connect(_on_choice.bind(id))
	
	menu_ready.emit()
	show()

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.as_text().is_valid_int():
				var id := int(event.as_text())
				if id in range(0, get_child_count()):
					_on_choice(id)
					return

func _on_choice(id: int):
	Rakugo.menu_return(id)
	VisualNovelKit.add_history_log(["menu", _choices[id]])
	hide()
	for ch in get_children(): ch.queue_free()
	menu_clean.emit()
