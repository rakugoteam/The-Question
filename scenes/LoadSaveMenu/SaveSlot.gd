class_name SaveSlot
extends Panel

var save_mode := true
var save_screenshot: Image
var save_file: String

func _ready() -> void:
	%NewSave.pressed.connect(_on_new_save)
	%ExistingSave.pressed.connect(_on_existing_save)
	%DeleteButton.pressed.connect(_on_delete_save)

func _on_new_save():
	# crate new save file
	# set_save(_save_file)
	pass

func set_save(_save_file: String):
	save_file = _save_file
	%ExistingSave.show()
	# set screenshot
	%SaveData.advanced_text = "# SaveName\n"
	%SaveData.advanced_text += "## SaveData\n"

func _on_existing_save():
	if save_file:
		# do you want to override this save?
		return
	
	# load save_file

func _on_delete_save():
	# delete save file
	queue_free()