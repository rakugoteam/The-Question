extends Control

@onready var sylvie: Control = $"../sylvie"

var _last_sprite: Sprite2D

func _ready():
	# React to viewport changes so the character stays aligned at any resolution.
	get_viewport().size_changed.connect(_on_viewport_resized)
	_update_position()

func _process(_delta: float) -> void:
	# Detect expression changes and realign for the newly visible sprite.
	var sprite := _get_visible_sprite()
	if sprite != _last_sprite and sprite != null:
		_update_position(sprite)

func _on_viewport_resized() -> void:
	_update_position()

func _update_position(forced_sprite: Sprite2D = null) -> void:
	# Align the sprite's bottom edge to the bottom of the viewport and center it.
	var sprite := forced_sprite if forced_sprite else _get_visible_sprite()
	if sprite == null:
		return

	_last_sprite = sprite
	sylvie.set_anchors_preset(Control.PRESET_TOP_LEFT, false)

	var viewport_size := get_viewport_rect().size
	var sprite_size := _get_sprite_size(sprite)
	var target_x := viewport_size.x * 0.5
	var target_y := viewport_size.y - (sprite_size.y * 0.5)

	sylvie.offset_left = target_x
	sylvie.offset_top = target_y
	sylvie.offset_right = target_x
	sylvie.offset_bottom = target_y

func _get_visible_sprite() -> Sprite2D:
	# Choose the first visible sprite; fall back to the first found.
	var fallback: Sprite2D = null
	for group in sylvie.get_children():
		if group is Node2D:
			for child in group.get_children():
				if child is Sprite2D:
					if child.visible:
						return child
					if fallback == null:
						fallback = child
	return fallback

func _get_sprite_size(sprite: Sprite2D) -> Vector2:
	# Use the rect size when available, otherwise fall back to texture size.
	var _size := sprite.get_rect().size
	if _size == Vector2.ZERO and sprite.texture:
		_size = sprite.texture.get_size()
	var _scale := sprite.get_global_transform().get_scale()
	return Vector2(_size.x * _scale.x, _size.y * _scale.y)
