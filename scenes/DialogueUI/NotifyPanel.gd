@tool
extends ProcentControl
class_name NotificationPanel

@export var notification_label: AdvancedTextLabel

@export_subgroup("Time")
@export var timer: Timer
@export var default_notification_time := 0.5

var markup: TextParser

signal notify_ready

func _ready():
	markup = load(VisualNovelKit.default_markup_setting)
	notification_label.parser = markup
	timer.one_shot = true
	visible = Engine.is_editor_hint()

	if !Engine.is_editor_hint():
		Rakugo.add_custom_regex("notification",
			"^notify( +({NUMERIC}) *)? *: *({STRING})$")
		Rakugo.sg_custom_regex.connect(_on_custom_regex)

func _on_custom_regex(key: String, result: RegExMatch):
	match key:
		"notification":
			var text := result.get_string(3)
			text = Rakugo.parser.treat_string(text)
			notification_label.advanced_text = text
			var time := default_notification_time
			if result.get_string(2):
				time = float(result.get_string(2))
			
			if !visible: show()
			notify_ready.emit()
			VisualNovelKit.add_history_log(["notify", text])
			
			timer.start(time)
			await timer.timeout
			hide()
