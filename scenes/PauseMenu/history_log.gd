@tool
class_name HistoryLog
extends DialoguePanel

@onready var say_icon: Label = %SayIcon
@onready var ask_icon: Label = %AskIcon
@onready var menu_icon: Label = %MenuIcon
@onready var notify_icon: Label = %NotifyIcon

@onready var speaker_label: AdvancedTextLabel = %SpeakerLabel
@onready var answer_label: AdvancedTextLabel = %AnswerLabel