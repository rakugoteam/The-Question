extends Control

signal ask_to_save

const confirm_menu = "Do you want to save before go back to Main Menu ?"
const confirm_restart = "Restart the Game ?"
const confirm_quit = "Do you want to save before quit the Game ?"

@onready var confirm_dialog: RGT_ConfirmationDialog = %RGT_ConfirmationDialog
@onready var yesno_dialog: RGT_YesNoDialog = %RGT_YesNoDialog
@onready var resume_button: Button = %ResumeButton
@onready var save_button: Button = %SaveButton
@onready var accept_dialog: AcceptDialog = %AcceptDialog
@onready var accept_dialog_ok_button: Button = accept_dialog.get_ok_button()
@onready var tab_container: TabContainer = $BoxContainer/TabContainer
@onready var options_container: MarginContainer = %OptionsContainer
@onready var history_scroll_container: ScrollContainer = %HistoryScrollContainer
@onready var load_save_menu = %LoadSaveMenu

enum After_Save {do_nothing, quit, go_back_to_main_menu}

var after_save := After_Save.do_nothing

func _ready():
	if OS.has_feature("web"): %ExitButton.hide()

	var accept_dialog_label: Label = accept_dialog.get_label()
	accept_dialog_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	accept_dialog_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	set_process(false)

func _on_resume_button_pressed():
	RGT_Globals.game.hide_pause_menu()

func _on_restart_button_pressed():
	confirm_dialog.dialog_text = confirm_restart
	confirm_dialog.force_ok_pressed_callable(_on_confirm_restart_confirmed)
	confirm_dialog.popup_centered()

func _on_main_menu_button_pressed():
	yesno_dialog.dialog_text = confirm_menu
	yesno_dialog.force_ok_pressed_callable(_on_confirm_main_menu_confirmed)
	yesno_dialog.force_no_pressed_callable(return_to_main_menu)
	yesno_dialog.popup_centered()

func _on_exit_button_pressed():
	yesno_dialog.dialog_text = confirm_quit
	yesno_dialog.force_ok_pressed_callable(_on_confirm_exit_confirmed)
	yesno_dialog.force_no_pressed_callable(quit)
	yesno_dialog.popup_centered()

func _on_confirm_restart_confirmed():
	hide()
	SceneLoader.change_scene(get_tree().current_scene.scene_file_path)

func _on_confirm_main_menu_confirmed():
	after_save = After_Save.go_back_to_main_menu
	_on_save_button_pressed()

func return_to_main_menu():
	hide()
	SceneLoader.change_scene(RGT_Globals.main_menu_setting)

func _on_confirm_exit_confirmed():
	after_save = After_Save.quit
	_on_save_button_pressed()

func quit():
	get_tree().quit()

func _on_save_button_pressed() -> void:
	save_button.disabled = true
	accept_dialog.dialog_text = "Saving..."
	accept_dialog_ok_button.disabled = true
	accept_dialog.popup_centered()
	ask_to_save.emit()

func save_this_please(data: Dictionary):
	if SaveHelper.save(data) == OK:
		accept_dialog.hide()
		hide()
		
		#Take screenshot and save it
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(
			SaveHelper.get_save_file_path_without_extension(
				SaveHelper.last_saved_file_name
			) + ".png"
		)
		
		show()
		accept_dialog.dialog_text = "The game is saved !"
		accept_dialog.popup_centered()

	else:
		accept_dialog.dialog_text = "Cannot save the game !
			(you do not have enough space or permission rights do to it)"
		after_save = After_Save.do_nothing
	
	accept_dialog_ok_button.disabled = false

func _on_accept_dialog_confirmed() -> void:
	match (after_save):
		After_Save.quit:
			quit()
			
		After_Save.go_back_to_main_menu:
			return_to_main_menu()
	
	save_button.disabled = false

func _on_history_button_toggled(toggled_on: bool) -> void:
	tab_container.visible = toggled_on
	history_scroll_container.visible = toggled_on

func _on_options_button_toggled(toggled_on: bool) -> void:
	tab_container.visible = toggled_on
	options_container.visible = toggled_on

func _on_load_button_toggled(toggled_on: bool) -> void:
	tab_container.visible = toggled_on
	# load_save_menu.mode = "load" 
	load_save_menu.visible = toggled_on

func _on_save_button_toggled(toggled_on: bool) -> void:
	tab_container.visible = toggled_on
	# load_save_menu.mode = "save"
	load_save_menu.visible = toggled_on
