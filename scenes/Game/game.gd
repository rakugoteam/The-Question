extends Node
class_name Game

@onready var pause_menu: Control = %PauseMenu
@onready var end_menu: Control = %EndMenu
@onready var dialogue_ui: Control = %DialogueUI

func _ready() -> void:
	if SaveHelper.save_file_name_to_load.is_empty():
		return
	
	if not SaveHelper.load_saved_file_name() == OK:
		return

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu.set_process(false)
			get_tree().paused = false
			pause_menu.hide()
			dialogue_ui.show()
			
		else:
			dialogue_ui.hide()
			pause_menu.show()
			pause_menu.set_process(true)
			get_tree().paused = true