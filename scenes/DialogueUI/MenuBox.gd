class_name MenuBox
extends VBoxContainer

@export var root: Control
@export var choice_btn_scene: PackedScene

var markup : TextParser

signal menu_ready
signal menu_clean

func _ready():
	markup = load(VisualNovelKit.default_markup_setting)
	Rakugo.sg_menu.connect(_on_menu)
	if root: visibility_changed.connect(_on_visibility_changed)
	hide()

func _on_visibility_changed():
	root.visible = visible

func _on_menu(choices:Array):
	for id in choices.size():
		var choice_btn := choice_btn_scene.instantiate()
		add_child(choice_btn)
		choice_btn.parser = markup
		choice_btn.text = choices[id]
		choice_btn.pressed.connect(_on_choice.bind(id))
	
	menu_ready.emit()
	show()

func _on_choice(id: int):
	Rakugo.menu_return(id)
	hide()
	for ch in get_children(): ch.queue_free()
	menu_clean.emit()
