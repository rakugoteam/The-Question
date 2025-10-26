extends RKSExtension

var vnk = VisualNovelKit

const Anim := "anim"
const PlayAnim := "play anim"
const PauseAnim := "pause anim"
const StopAnim := "stop anim"

const regex := {
	PlayAnim: "play +({NAME}) +({NAME})( +{NUMERIC})?",
	PauseAnim: "pause +({NAME})",
	StopAnim: "stop +({NAME})",
}

func _group_name() -> StringName:
	return Anim

func _ready():
	for key in regex: Rakugo.add_custom_regex(key, regex[key])
	super._ready()

func _on_custom_regex(key: String, result: RegExMatch):
	if key not in regex: return
	if result.get_group_count() == 0:
		push_error(err_mess_01 % [key, group_name])
		return
	
	match key:
		PlayAnim:
			var node := rk_get_node(result.get_string(1))
			if !node: return

			var anim_name := result.get_string(2)
			var speed := float(result.get_string(3))
			if result.get_string(3).is_empty(): speed = 1
			
			if speed == 0:
				push_error("you try to play animation with 0 speed")
				return

			if speed > 0: node.play(anim_name, speed)
			elif speed < 0: node.play(anim_name, speed, true)

		PauseAnim:
			var node := rk_get_node(result.get_string(1))
			if !node: return
			node.pause()
		
		StopAnim:
			var node := rk_get_node(result.get_string(1))
			if !node: return
			node.stop()
