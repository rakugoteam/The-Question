extends RKSExtension

var vnk = VisualNovelKit

const Video := "video"
const PlayVideo := "play video"
const StopVideo := "stop video"

const regex := {
	PlayVideo: "play +({NAME})",
	StopVideo: "stop +({NAME})",
}

func _group_name() -> StringName:
	return Video

func _ready():
	for key in regex: Rakugo.add_custom_regex(key, regex[key])
	super._ready()

func _on_custom_regex(key: String, result: RegExMatch):
	if key not in regex: return
	if result.get_group_count() == 0:
		push_error(err_mess_01 % [key, group_name])
		return
	
	match key:
		PlayVideo:
			var node := rk_get_node(result.get_string(1)) as VideoStreamPlayer
			if !node: return
			node.finished.connect(_on_video_finished.bind(node))
			# Rakugo.set_variable(node.name, "play:%s" % [true])
			node.play()
		
		StopVideo:
			var node := rk_get_node(result.get_string(1)) as VideoStreamPlayer
			if !node: return
			# Rakugo.set_variable(node.name, "stop:%s" % [true])
			node.stop()

func _on_video_finished(node: VideoStreamPlayer):
	# Rakugo.set_variable(node.name, "stop:%s" % [true])
