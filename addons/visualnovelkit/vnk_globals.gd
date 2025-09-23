@tool
extends Node
class_name VisualNovelKit

const setting_path = "application/addons/visual_novel_kit"
const default_markup_setting_path = setting_path + "/default_markup_setting"
const default_markup = "res://addons/visualnovelkit/default_markups/def_markdown.tres"

const rks_extesion_dir := "res://addons/visualnovelkit/rks_extensions"
const rks_extesions := {
	RKSShow = rks_extesion_dir + "/rks_show.gd",
}

const at_setting_path = setting_path + "/at_predefind/"
const at_center_setting_path = at_setting_path + "center"
const at_left_setting_path = at_setting_path + "left"
const at_right_setting_path = at_setting_path + "right"
const at_top_setting_path = at_setting_path + "top"
const at_bottom_setting_path = at_setting_path + "bottom"

static var history_container: HistoryContainer
static func add_history_log(args: Array):
	history_container.add_history_log.emit(args)

static var default_markup_setting: String:
	set (value):
		ProjectSettings.set_setting(default_markup_setting_path, value)
	get:
		return ProjectSettings.get_setting(default_markup_setting_path)

static var at_center : Vector2:
	set (value):
		ProjectSettings.set_setting(at_center_setting_path, value)
	get:
		return ProjectSettings.get_setting(at_center_setting_path)

static var at_left : float:
	set (value):
		ProjectSettings.set_setting(at_left_setting_path, value)
	get:
		return ProjectSettings.get_setting(at_left_setting_path)

static var at_right : float:
	set (value):
		ProjectSettings.set_setting(at_right_setting_path, value)
	get:
		return ProjectSettings.get_setting(at_right_setting_path)

static var at_top : float:
	set (value):
		ProjectSettings.set_setting(at_top_setting_path, value)
	get:
		return ProjectSettings.get_setting(at_top_setting_path)

static var at_bottom : float:
	set (value):
		ProjectSettings.set_setting(at_bottom_setting_path, value)
	get:
		return ProjectSettings.get_setting(at_bottom_setting_path)
