extends KitTest

const notif_panel_scene = "res://scenes/DialogueUI/notify_panel.tscn"
const file_path = "res://Test/TestUI/Testnotify.rk"

var file_base_name = get_file_base_name(file_path)

func test_notif_ui():
	var notif_panel := add_from_scene(notif_panel_scene) as NotificationPanel
	var nodes := [
		notif_panel,
		notif_panel.notification_label,
		notif_panel.timer
	]
	for node in nodes:
		assert_not_null(node)

	watch_rakugo_signals()
	watch_custom_statments()
	
	await wait_parse_and_execute_script(file_path)

	wait_do_step("start")

	assert_false(notif_panel.visible)
	await wait_for_custom_statement("notification", 0.2)
	await wait_visblity(notif_panel)
	await wait_for_signal(notif_panel.notify_ready, 0.2)
	assert_adv_text(notif_panel.notification_label, "some notification")
	assert_true(notif_panel.visible)
	await wait_for_signal(notif_panel.timer.timeout, 0.5)

	wait_do_step()

	assert_false(notif_panel.visible)
	await wait_for_custom_statement("notification", 0.2)
	await wait_for_signal(notif_panel.notify_ready, 0.2)
	assert_adv_text(notif_panel.notification_label,
		"some shorter time notification")
	assert_true(notif_panel.visible)
	await wait_for_signal(notif_panel.timer.timeout, 0.3)
	await wait_visblity(notif_panel, false)
	
	wait_do_step("end")
	await wait_execute_script_finished(file_base_name)
