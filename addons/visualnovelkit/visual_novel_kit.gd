@tool
extends EditorPlugin

func _enter_tree():
	VisualNovelKit.default_markup_setting = VisualNovelKit.default_markup
	
	VisualNovelKit.at_center = Vector2(50, 50)
	VisualNovelKit.at_left = 25
	VisualNovelKit.at_right = 75
	VisualNovelKit.at_top = 25
	VisualNovelKit.at_bottom = 75

	for ext in VisualNovelKit.rks_extesions:
		var ext_script : String = VisualNovelKit.rks_extesions[ext]
		add_autoload_singleton(ext, ext_script)

func _exit_tree():
	for ext in VisualNovelKit.rks_extesions:
		remove_autoload_singleton(ext)

	var settings := [
		VisualNovelKit.default_markup_setting_path,
		VisualNovelKit.at_center_setting_path,
		VisualNovelKit.at_left_setting_path,
		VisualNovelKit.at_right_setting_path,
		VisualNovelKit.at_top_setting_path,
		VisualNovelKit.at_bottom_setting_path,
	]
	for setting in settings:
		ProjectSettings.set_setting(setting, null)
