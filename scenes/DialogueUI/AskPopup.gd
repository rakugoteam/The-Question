@tool
class_name AskPopup
extends ProcentControl

@export var say_panel: SayPanel
@export var line_edit: LineEdit

func _ready():
	if Engine.is_editor_hint(): return
	Rakugo.sg_ask.connect(_on_ask)
	visibility_changed.connect(_on_visibility_changed)
	visible = Engine.is_editor_hint()
	set_process(false)

func _on_ask(character: Dictionary, question: String, default_answer: String):
	line_edit.placeholder_text = default_answer
	say_panel.set_labels(character, question)
	say_panel.show()
	say_panel.set_process(false)
	show()

func _process(_delta: float):
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("ui_accept"):
		_on_ok_btn_pressed()
	if Input.is_action_just_pressed("ui_cancel"):
		_on_default_answer_btn_pressed()

func _on_default_answer_btn_pressed():
	Rakugo.ask_return(line_edit.placeholder_text)
	hide()

func _on_ok_btn_pressed():
	if line_edit.text: Rakugo.ask_return(line_edit.text)
	else: Rakugo.ask_return(line_edit.placeholder_text)
	hide()

func _on_text_submitted(new_text: String):
	Rakugo.ask_return(new_text)
	hide()

func _on_visibility_changed():
	set_process(visible)
