@tool
class_name SayPanel
extends DialoguePanel

@export var next_btn: FontIconButton

func _ready():
	super._ready()
	if Engine.is_editor_hint(): return
	Rakugo.sg_say.connect(_on_say)
	if next_btn: next_btn.pressed.connect(_on_next_btn_pressed)

func _on_say(character: Dictionary, text: String):
	VisualNovelKit.add_history_log(["say", character, text])
	set_labels(character, text)
	show()

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_accept"):
		_on_next_btn_pressed()

func _on_next_btn_pressed():
	Rakugo.do_step()
	hide()