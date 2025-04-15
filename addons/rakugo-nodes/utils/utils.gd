class_name Utils
extends Object

## Is shortcut of:
## [code]
## if !object.is_connected(signal_name, method):
##  	object.connect(signal_name, method)
## [/code]
static func connect_if_possible(
	object:Object, signal_name:StringName, method:Callable):
	if !object.is_connected(signal_name, method):
		object.connect(signal_name, method)

## Is shortcut of:
## [code]
## if object.is_connected(signal_name, method):
##  	object.disconnect(signal_name, method)
## [/code]
static func disconnect_if_possible(
	object:Object, signal_name:StringName, method:Callable):
	if object.is_connected(signal_name, method):
		object.disconnect(signal_name, method)

## Is shortcut of:
## [code]
## disconnect_if_possible(object, signal_name, old_method)
## connect_if_possible(object, signal_name, new_method)
## [/code]
static func change_signal(
	object:Object, signal_name:StringName,
	old_method:Callable, new_method:Callable):
	disconnect_if_possible(object, signal_name, old_method)
	connect_if_possible(object, signal_name, new_method)

## This shortcut for:
## [code]
## if control.has_theme_<override_type>_override(name):
##	control.remove_theme_<override_type>_override(name)
## [/code]
static func rm_theme_override_if_possible(control: Control, override_type: StringName, name: StringName):
	match override_type:
		&"constant":
			if control.has_theme_constant_override(name):
				control.remove_theme_constant_override(name)
		&"color":
			if control.has_theme_color_override(name):
				control.remove_theme_color_override(name)
		&"font":
			if control.has_theme_font_override(name):
				control.remove_theme_font_override(name)
		&"font_size":
			if control.has_theme_font_size_override(name):
				control.remove_theme_font_size_override(name)
		&"icon":
			if control.has_theme_icon_override(name):
				control.remove_theme_icon_override(name)
		&"stylebox":
			if control.has_theme_stylebox_override(name):
				control.remove_theme_stylebox_override(name)


