@tool
class_name AskPopup
extends ProcentControl

@export var say_panel: SayPanel
@export var line_edit: LineEdit

var _question := ""

func _ready():
	if Engine.is_editor_hint(): return
	Rakugo.sg_ask.connect(_on_ask)
	visibility_changed.connect(_on_visibility_changed)
	visible = Engine.is_editor_hint()
	set_process(false)

func _on_ask(character: Dictionary, question: String, default_answer: String):
	_question = question
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

func ask_return(answer := ""):
	Rakugo.ask_return(answer)
	VisualNovelKit.add_history_log(["ask", _question, answer])
	hide()

func _on_default_answer_btn_pressed():
	ask_return(line_edit.placeholder_text)

func _on_ok_btn_pressed():
	if line_edit.text: ask_return(line_edit.text)
	else: ask_return(line_edit.placeholder_text)

func _on_text_submitted(new_text: String):
	ask_return(new_text)

func _on_visibility_changed():
	set_process(visible)
