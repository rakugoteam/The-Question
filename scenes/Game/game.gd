extends Node
class_name Game

@onready var pause_menu: Control = %PauseMenu
@onready var end_menu: Control = %EndMenu
@onready var dialogue_ui: Control = %DialogueUI

func _ready() -> void:
	RGT_Globals.game = self
	if SaveHelper.save_file_name_to_load.is_empty(): return
	if SaveHelper.load_saved_file_name() != OK: return

func show_pause_menu():
	dialogue_ui.hide()
	pause_menu.show()
	pause_menu.set_process(true)
	get_tree().paused = true

func hide_pause_menu():
		pause_menu.set_process(false)
		get_tree().paused = false
		pause_menu.hide()
		await get_tree().process_frame
		dialogue_ui.show()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !pause_menu.visible: show_pause_menu()
		else: hide_pause_menu()
