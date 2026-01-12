extends Control

# Keeps the character aligned to the screen based on Ren'Py-style positioning
# while remaining resolution-independent.

# Enable to print positioning diagnostics on updates.
@export var debug_positioning := false

@onready var character_root: Control = self

var _last_sprite: Sprite2D

# Positioning mode enum
enum PositioningMode {
	DEFAULT,      # Use default center-bottom positioning
	EXPLICIT_PREDEF, # Using predefined positions (left, right, center, etc.)
	EXPLICIT_CUSTOM  # Using custom coordinates
}

var _positioning_mode: PositioningMode = PositioningMode.DEFAULT
var _explicit_position: Vector2 = Vector2.ZERO
var _explicit_predef := ""

# Signal for when positioning mode changes
signal positioning_mode_changed(mode: PositioningMode)

func _ready():
	# React to viewport changes so the character stays aligned at any resolution.
	_log_viewport("ready")
	get_viewport().size_changed.connect(_on_viewport_resized)
	_update_position()

func _process(_delta: float) -> void:
	# Detect expression changes and realign for the newly visible sprite.
	var sprite := _get_visible_sprite()
	if sprite != _last_sprite and sprite != null:
		_update_position(sprite)

func _on_viewport_resized() -> void:
	_log_viewport("size_changed")
	_update_position()

# Public methods to control positioning mode.
func set_default_positioning() -> void:
	_positioning_mode = PositioningMode.DEFAULT
	_explicit_predef = ""
	_explicit_position = Vector2.ZERO
	emit_signal("positioning_mode_changed", _positioning_mode)
	_update_position()

func set_explicit_position(e_position: Vector2, is_predef: bool = false, predef: String = "") -> void:
	_positioning_mode = PositioningMode.EXPLICIT_CUSTOM if not is_predef else PositioningMode.EXPLICIT_PREDEF
	_explicit_position = e_position
	_explicit_predef = predef
	emit_signal("positioning_mode_changed", _positioning_mode)
	_update_position()

func _update_position(forced_sprite: Sprite2D = null) -> void:
	# Align the character based on the current mode and sprite bounds.
	var sprite := forced_sprite if forced_sprite else _get_visible_sprite()
	if sprite == null:
		return

	_last_sprite = sprite
	character_root.set_anchors_preset(Control.PRESET_TOP_LEFT, false)

	match _positioning_mode:
		PositioningMode.DEFAULT:
			# Apply default center-bottom positioning
			var visible_rect := get_viewport().get_visible_rect()
			_log_viewport("update_default")
			var sprite_rect := _get_sprite_rect(sprite)
			var target := _align_to(Vector2(0.5, 1.0), sprite_rect, visible_rect)
			_apply_offsets(target)

		PositioningMode.EXPLICIT_PREDEF:
			# Use explicit predefined position (Ren'Py-style)
			var visible_rect := get_viewport().get_visible_rect()
			_log_viewport("update_predef")
			var sprite_rect := _get_sprite_rect(sprite)
			var target: Vector2 = _get_predef_target(sprite_rect, visible_rect)
			_apply_offsets(target)

		PositioningMode.EXPLICIT_CUSTOM:
			# Explicit positions are stored as percent-of-viewport coordinates.
			var visible_rect := get_viewport().get_visible_rect()
			_log_viewport("update_custom")
			var target_x := visible_rect.position.x + _explicit_position.x * visible_rect.size.x
			var target_y := visible_rect.position.y + _explicit_position.y * visible_rect.size.y
			_apply_offsets(Vector2(target_x, target_y))

	if debug_positioning:
		_print_debug(sprite)

func _get_visible_sprite() -> Sprite2D:
	# Choose the first visible sprite; fall back to the first found.
	var fallback: Sprite2D = null
	for group in character_root.get_children():
		if group is Node2D:
			for child in group.get_children():
				if child is Sprite2D:
					if child.visible:
						return child
					if fallback == null:
						fallback = child
	return fallback

func _get_sprite_rect(sprite: Sprite2D) -> Rect2:
	# Return the sprite's local rect, scaled to its current transform.
	var rect := sprite.get_rect()
	if rect.size == Vector2.ZERO and sprite.texture:
		var _size := sprite.texture.get_size()
		rect = Rect2(-_size * 0.5, _size)
	var _scale := sprite.get_global_transform().get_scale()
	rect.position *= _scale
	rect.size *= _scale
	return rect

func _apply_offsets(target: Vector2) -> void:
	# Treat the control as a point by keeping all offsets identical.
	character_root.offset_left = target.x
	character_root.offset_top = target.y
	character_root.offset_right = target.x
	character_root.offset_bottom = target.y

func _get_predef_target(sprite_rect: Rect2, visible_rect: Rect2) -> Vector2:
	# Map Ren'Py-style keywords to a target point.
	var predef := _explicit_predef.to_lower()

	match predef:
		"default", "center", "bottom":
			return _align_to(Vector2(0.5, 1.0), sprite_rect, visible_rect)
		"left":
			return _align_to(Vector2(0.0, 1.0), sprite_rect, visible_rect)
		"right":
			return _align_to(Vector2(1.0, 1.0), sprite_rect, visible_rect)
		"top":
			return _align_to(Vector2(0.5, 0.0), sprite_rect, visible_rect)
		"topleft", "top_left":
			return _align_to_anchors(Vector2(0.25, 0.0), Vector2(0.5, 0.0), sprite_rect, visible_rect)
		"topright", "top_right":
			return _align_to_anchors(Vector2(0.75, 0.0), Vector2(0.5, 0.0), sprite_rect, visible_rect)
		"bottomleft", "bottom_left":
			return _align_to_anchors(Vector2(0.25, 1.0), Vector2(0.5, 1.0), sprite_rect, visible_rect)
		"bottomright", "bottom_right":
			return _align_to_anchors(Vector2(0.75, 1.0), Vector2(0.5, 1.0), sprite_rect, visible_rect)
		"truecenter":
			return _align_to(Vector2(0.5, 0.5), sprite_rect, visible_rect)
		"offscreenleft":
			return Vector2(visible_rect.position.x - (sprite_rect.position.x + sprite_rect.size.x), visible_rect.position.y + visible_rect.size.y - (sprite_rect.position.y + sprite_rect.size.y))
		"offscreenright":
			return Vector2(visible_rect.position.x + visible_rect.size.x - sprite_rect.position.x, visible_rect.position.y + visible_rect.size.y - (sprite_rect.position.y + sprite_rect.size.y))
		_:
			return Vector2(visible_rect.position.x + _explicit_position.x * visible_rect.size.x, visible_rect.position.y + _explicit_position.y * visible_rect.size.y)

func _align_to(align: Vector2, sprite_rect: Rect2, visible_rect: Rect2) -> Vector2:
	# Align the sprite rect to the requested viewport anchor.
	var x := visible_rect.position.x + visible_rect.size.x * align.x - (sprite_rect.position.x + sprite_rect.size.x * align.x)
	var y := visible_rect.position.y + visible_rect.size.y * align.y - (sprite_rect.position.y + sprite_rect.size.y * align.y)
	return Vector2(x, y)

func _align_to_anchors(screen_anchor: Vector2, sprite_anchor: Vector2, sprite_rect: Rect2, visible_rect: Rect2) -> Vector2:
	var x := visible_rect.position.x + visible_rect.size.x * screen_anchor.x - (sprite_rect.position.x + sprite_rect.size.x * sprite_anchor.x)
	var y := visible_rect.position.y + visible_rect.size.y * screen_anchor.y - (sprite_rect.position.y + sprite_rect.size.y * sprite_anchor.y)
	return Vector2(x, y)

func _print_debug(sprite: Sprite2D) -> void:
	var visible_rect := get_viewport().get_visible_rect()
	var sprite_rect := _get_sprite_rect(sprite)
	var global_rect := _get_global_rect(sprite, sprite_rect)
	var texture_size := Vector2.ZERO
	if sprite.texture:
		texture_size = sprite.texture.get_size()
	prints(
		"[CharacterPositioner]",
		"mode=", _positioning_mode,
		"predef=", _explicit_predef,
		"explicit=", _explicit_position,
		"visible_rect=", visible_rect,
		"sprite_rect=", sprite_rect,
		"global_rect=", global_rect,
		"texture_size=", texture_size,
		"centered=", sprite.centered,
		"offset=", sprite.offset,
		"region_enabled=", sprite.region_enabled,
		"region_rect=", sprite.region_rect,
		"hframes=", sprite.hframes,
		"vframes=", sprite.vframes,
		"frame=", sprite.frame,
		"flip_h=", sprite.flip_h,
		"flip_v=", sprite.flip_v
	)

func _get_global_rect(sprite: Sprite2D, rect: Rect2) -> Rect2:
	var xform := sprite.get_global_transform()
	var p1: Vector2 = xform * rect.position
	var p2: Vector2 = xform * (rect.position + Vector2(rect.size.x, 0))
	var p3: Vector2 = xform * (rect.position + Vector2(0, rect.size.y))
	var p4: Vector2 = xform * (rect.position + rect.size)
	var min_x: float = min(p1.x, p2.x, p3.x, p4.x)
	var min_y: float = min(p1.y, p2.y, p3.y, p4.y)
	var max_x: float = max(p1.x, p2.x, p3.x, p4.x)
	var max_y: float = max(p1.y, p2.y, p3.y, p4.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _log_viewport(tag: String) -> void:
	if debug_positioning:
		var vp := get_viewport()
		prints(
			"[ViewportDebug][CharacterPositioner]",
			tag,
			"viewport_size=", vp.size,
			"visible_rect=", vp.get_visible_rect(),
			"window_size=", get_window().size
		)
