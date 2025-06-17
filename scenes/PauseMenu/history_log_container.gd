class_name HistoryContainer
extends VBoxContainer

signal add_history_log(args: Array)

@export var history_log_scene: PackedScene
@export var scroll: ScrollContainer

var log_ui: HistoryLog

func _ready():
	VisualNovelKit.history_container = self
	add_history_log.connect(_on_history_log)

func _on_history_log(args: Array):
	prints("log hist:", args)
	match args[0]:
		"say": _on_say(args[1], args[2])
		"ask": _on_ask_return(args[1], args[2], args[3])
		"menu": _on_menu_return(args[1])
		"notify": _on_notify(args[1])

func _on_say(character: Dictionary, text: String):
	log_ui = history_log_scene.instantiate()
	add_child(log_ui)
	log_ui.show()
	log_ui.say_icon.show()
	log_ui.set_labels(character, text)
	log_ui.answer_label.hide()

func _on_ask_return(character: Dictionary, question: String, answer: String):
	log_ui = history_log_scene.instantiate()
	add_child(log_ui)
	log_ui.show()
	log_ui.ask_icon.show()
	log_ui.set_labels(character, question)
	log_ui.answer_label.advanced_text = "[b]Answer[\b]: _%s_ " % answer
	log_ui.answer_label.show()

func _on_menu_return(choice_text: String):
	if !log_ui:
		log_ui = history_log_scene.instantiate()
		add_child(log_ui)
		log_ui.show()

	# ! we use here last crated log ui for say
	log_ui.menu_icon.show()
	log_ui.answer_label.show()
	log_ui.answer_label.advanced_text = "[b]Choice:[/b] _%s_ " % choice_text
	log_ui.answer_label.show()

func _on_notify(notify_text: String):
	log_ui = history_log_scene.instantiate()
	add_child(log_ui)
	log_ui.show()
	log_ui.notify_icon.show()
	log_ui.character_name_label.advanced_text = "[h1]Notification[/h1] "
	log_ui.dialogue_label.advanced_text = notify_text
	log_ui.answer_label.hide()

func _on_visibility_changed() -> void:
	if visible: scroll.ensure_control_visible(log_ui)
