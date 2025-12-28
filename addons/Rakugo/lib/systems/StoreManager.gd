extends RefCounted

var save_folder_path: String

#store rakugo variables
var variables: Dictionary

#store rakugo characters
var characters: Dictionary

var parsed_scripts: Dictionary

func _init():
	save_folder_path = ProjectSettings.get_setting(Rakugo.save_folder, "user://saves")

## Rk
func load_rk(path: String) -> PackedStringArray:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("can't open file : " + path)
		return PackedStringArray()
	
	var lines = PackedStringArray()
	
	while file.get_position() < file.get_length():
		lines.push_back(file.get_line())
	
	file.close()

	return lines
