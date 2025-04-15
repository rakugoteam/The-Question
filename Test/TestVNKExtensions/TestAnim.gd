extends KitTest

const file_path = "res://Test/TestVNKExtensions/TestAnim.rk"
const scene_path := "res://Test/TestVNKExtensions/animation_test.tscn"
var file_base_name = get_file_base_name(file_path)

func assert_anim_playing(
	anim_node: Node, anim_name: String, speed := 1.0):
	if anim_node is AnimationPlayer:
		assert_eq(anim_node.current_animation, anim_name)
	else: assert_eq(anim_node.animation, anim_name)
	# assert_eq(anim_node.speed_scale, speed,
	# "\n-- play %s %s %d --" % [anim_node.name, anim_name, speed])
	assert_true(anim_node.is_playing())

func _assert_anim(anim_node: Node, mode := "pause"):
	assert_false(anim_node.is_playing())
	var pos := 0.0
	var length := 1.0

	if anim_node is AnimationPlayer:
		if anim_node.current_animation:
			pos = anim_node.current_animation_position
			length = anim_node.current_animation_length
	else: pos = anim_node.frame_progress

	# match mode:
	# 	"pause": assert_almost_ne(pos, 0.0, 0.1)
	# 	"stop": assert_almost_eq(pos, 0.0, 0.1)
	# assert_almost_ne(pos, length, 0.1,
	# 	"\n-- %s %s" % [mode, anim_node.name])

func assert_anim_pause(anim_node: Node):
	_assert_anim(anim_node, "pause")

func assert_anim_stop(anim_node: Node):
	_assert_anim(anim_node, "stop")

func test_anim():
	var scene := load(scene_path)
	var root_node := add_node(scene.instantiate()) as Node2D
	var animation_player := root_node.get_node("AnimationPlayer") as AnimationPlayer
	var animated_sprite2d := root_node.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var animated_sprite3d := root_node.get_node("AnimatedSprite3D") as AnimatedSprite3D
	
	for ch: Node in root_node.get_children():
		if ch.name == "WindowIcon": continue
		ch.add_to_group("anim")
		watch_signals(ch)

	await wait_frames(1)
	watch_rakugo_signals()
	watch_custom_statments()
	await wait_parse_and_execute_script(file_path)

	await wait_do_step("start")
	await wait_anim_node(animation_player)
	await wait_do_step()
	await wait_anim_node(animated_sprite2d)
	await wait_do_step()
	await wait_anim_node(animated_sprite3d)
	await wait_do_step("end")

func wait_anim_node(anim_node: Node):
	await wait_for_custom_statement(RKSAnim.PlayAnim, 0.2)
	await wait_seconds(0.1)
	assert_anim_playing(anim_node, "test")
	await wait_do_step()

	await wait_for_custom_statement(RKSAnim.PauseAnim, 0.2)
	await wait_seconds(0.1)
	assert_anim_pause(anim_node)
	await wait_do_step()

	await wait_for_custom_statement(RKSAnim.PlayAnim, 0.2)
	await wait_seconds(0.1)
	assert_anim_playing(anim_node, "test", 2)
	await wait_do_step()

	await wait_for_custom_statement(RKSAnim.PauseAnim, 0.2)
	await wait_seconds(0.1)
	assert_anim_pause(anim_node)
	await wait_do_step()

	await wait_for_custom_statement(RKSAnim.PlayAnim, 0.2)
	assert_anim_playing(anim_node, "test", -1)
	await wait_seconds(0.1)
	await wait_do_step()

	await wait_for_custom_statement(RKSAnim.StopAnim, 0.2)
	await wait_seconds(0.1)
	assert_anim_stop(anim_node)
