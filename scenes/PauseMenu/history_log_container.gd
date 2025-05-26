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
	match args[0]:
		"say": _on_say(args[1], args[2])
		"ask": _on_ask_return(args[1], args[2], args[3])
		"menu": _on_menu_return(args[1])
		"notify": _on_notify(args[1])

func _on_say(character: Dictionary, text: String):
	log_ui = history_log_scene.instantiate()
	log_ui.icon.icon_settings.icon_name = "chat"
	log_ui.set_labels(character, text)
	log_ui.answer_label.hide()
	add_child(log_ui)
	await get_tree().process_frame
	scroll.ensure_control_visible(log_ui)

func _on_ask_return(character: Dictionary, question: String, answer: String):
	log_ui = history_log_scene.instantiate()
	log_ui.icon.icon_settings.icon_name = "chat-question"
	log_ui.set_labels(character, question)
	log_ui.answer_label.advanced_text = " **Answer:** _%s_ " % answer
	add_child(log_ui)
	await get_tree().process_frame
	scroll.ensure_control_visible(log_ui)

func _on_menu_return(choice_text: String):
	# ! we use here last crated log ui for say
	log_ui.icon.icon_settings.icon_name = "menu"
	log_ui.answer_label.show()
	log_ui.answer_label.advanced_text = " **Choice:** _%s_ " % choice_text

func _on_notify(notify_text: String):
	log_ui.character_name_label.advanced_text = "# Notification "
	log_ui.dialogue_label.advanced_text = notify_text
	log_ui.icon.icon_settings.icon_name = "alert"
	log_ui.answer_label.hide()
	add_child(log_ui)
	await get_tree().process_frame
	scroll.ensure_control_visible(log_ui)