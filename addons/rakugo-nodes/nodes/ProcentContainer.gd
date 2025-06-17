@tool
## This is simple class that set Control minimal_size base on root size procent
class_name ProcentControl
extends Control

## Node that which size will be used as 100 procent
@export var root: Control = null

@export var disabled := false

## Set it from 1 to 100
## It changing this works only in Editor
@export var procent_size := Vector2(100, 100):
	set(value):
		if disabled: return
		if !is_node_ready(): await ready
		if !Engine.is_editor_hint(): return
		
		procent_size = value
		if root: custom_minimum_size = root.size * (procent_size / 100.0)
		else: push_warning("ProcentControl: root is not set")
