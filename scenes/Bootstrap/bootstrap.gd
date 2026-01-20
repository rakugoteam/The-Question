extends Node

#only here to load the first scene
#you can use this scene to show your splashscreen

func _ready():
	_log_viewport("ready")
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	#Current version of Godot seems to need this to force the user's saved window setting (review on future versions.
	call_deferred("_force_window_refresh")
	SceneLoader.change_scene(RGT_Globals.main_menu_setting, true, false)

func _on_viewport_size_changed() -> void:
	_log_viewport("size_changed")

#debug for window/viewport issues
func _log_viewport(tag: String) -> void:
	var vp := get_viewport()
	var win := get_window()
	var win_id := win.get_window_id()
	prints(
		"[ViewportDebug][Bootstrap]",
		tag,
		"viewport_size=", vp.size,
		"visible_rect=", vp.get_visible_rect(),
		"window_size=", win.size,
		"window_size_os=", DisplayServer.window_get_size(win_id),
		"display_scale=", DisplayServer.screen_get_scale(DisplayServer.window_get_current_screen())
	)

#forces an update to window sizing
func _force_window_refresh() -> void:
	var win := get_window()
	if win.mode != Window.MODE_WINDOWED:
		_log_viewport("force_refresh_skip")
		return
	var win_id := win.get_window_id()
	var os_size := DisplayServer.window_get_size(win_id)
	if os_size != win.size:
		win.size = os_size
		DisplayServer.window_set_size(os_size, win_id)
		_log_viewport("force_refresh_os_sync")
		return
	var bump := os_size + Vector2i(1, 0)
	DisplayServer.window_set_size(bump, win_id)
	DisplayServer.window_set_size(os_size, win_id)
	win.size = os_size
	_log_viewport("force_refresh")
