extends Node

var day: int = 1
var flags: Dictionary = {}
var input_locked: bool = false
var menu_open: bool = false
var collected: Dictionary = {}

func set_flag(flag: String, value: bool = true) -> void:
	flags[flag] = value
	
func has_flag(flag: String) -> bool:
	return flags.get(flag, false)

func reset() -> void:
	day = 1
	flags.clear()
	collected.clear()
	input_locked = false
	menu_open = false
