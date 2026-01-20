extends RKSExtension

var vnk = VisualNovelKit

const Audio := "audio"
const PlayAudio := "play audio"
const SeekAudio := "seek audio"
const StopAudio := "stop audio"

const regex := {
	PlayAudio: "play +({NAME})( +{NUMERIC})?",
	SeekAudio: "seek +({NAME})( +{NUMERIC})",
	StopAudio: "stop +({NAME})",
}

func _group_name() -> StringName:
	return Audio

func _ready():
	for key in regex: Rakugo.add_custom_regex(key, regex[key])
	super._ready()

func _on_custom_regex(key: String, result: RegExMatch):
	if key not in regex: return
	if result.get_group_count() == 0:
		push_error(err_mess_01 % [key, group_name])
		return
	
	var node := rk_get_node(result.get_string(1)) # as AudioStreamPlayer
	if node is AudioStreamPlayer: pass
	elif node is AudioStreamPlayer2D: pass
	elif node is AudioStreamPlayer3D: pass
	else:
		push_error("unsupported AudioStreamPlayer Node type") 
		return

	match key:
		PlayAudio:
			var str_speed := result.get_string(2).strip_edges()
			var speed := float(str_speed)
			if str_speed.is_empty(): speed = 1
			
			if speed <= 0:
				push_error("you try to play audio with speed <= 0")
				return

			# Rakugo.set_variable(node.name, "play:%f" % speed)
			node.finished.connect( func(): # Rakugo.set_variable(node.name, "stop"))
			node.play(speed)

		SeekAudio:
			var str_pos := result.get_string(2).strip_edges()
			# Rakugo.set_variable(node.name, "seek:%s" % str_pos)
			node.seek(float(str_pos))

		StopAudio:
			node.stop()
			# Rakugo.set_variable(node.name, "stop")