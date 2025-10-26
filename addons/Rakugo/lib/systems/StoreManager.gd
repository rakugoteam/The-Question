extends RefCounted

#store rakugo variables
var variables: Dictionary

#store rakugo characters
var characters: Dictionary

var parsed_scripts: Dictionary

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

func get_save_data(thread_data: Dictionary) -> Dictionary:
	var save_data = {"variables": variables, "characters": characters}

	if !thread_data.is_empty():
		thread_data["path"] = parsed_scripts[thread_data["file_base_name"]]["path"]

		save_data["thread_data"] = thread_data
	
	return save_data

func load_save_data(save_data: Dictionary) -> Dictionary:
	if save_data.is_empty(): return {}

	variables = save_data["variables"]
	characters = save_data["characters"]
	return save_data.get("thread_data", {})