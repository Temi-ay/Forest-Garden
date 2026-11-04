extends Node

signal line_changed(speaker: String, text: String, choices: Array)
signal dialogue_ended

var data: Dictionary = {}
var current: Dictionary = {}
var active: bool = false

func start(path: String) -> void:
	if active:
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Dialogue file not found: " + path)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Bad dialogue JSON: " + path)
		return
	data = parsed
	var node_id := _pick_entry()
	if node_id == "":
		return
	active = true
	GameState.input_locked = true
	_show(node_id)

func say(text: String, speaker: String = "") -> void:
	if active:
		return
	data = {"nodes": {"line": {"speaker": speaker, "text": text}}}
	active = true
	GameState.input_locked = true
	_show("line")

func advance() -> void:
	if not active or current.has("choices"):
		return
	var next: String = current.get("next", "")
	if next == "":
		end()
	else:
		_show(next)
	
func choose(index: int) -> void:
	var choices: Array = current.get("choices", [])
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	_apply_actions(choice)
	var next: String = choice.get("next", "")
	if next == "":
		end()
	else:
		_show(next)

func end() -> void:
	active = false
	current = {}
	GameState.input_locked = false
	dialogue_ended.emit()

func _show(node_id: String) -> void:
	var node: Dictionary = data.get("nodes", {}).get(node_id, {})
	if node.is_empty():
		end()
		return
	current = node
	_apply_actions(node)
	line_changed.emit(node.get("speaker", ""), node.get("text", ""), node.get("choices", []))

# Actions shared by dialogue lines and choices
func _apply_actions(d: Dictionary) -> void:
	if d.has("set_flag"):
		GameState.set_flag(d["set_flag"])
	if d.has("give_item"):
		Inventory.add(d["give_item"])
	if d.has("take_item"):
		Inventory.remove(d["take_item"])
	if d.has("start_quest"):
		QuestManager.start(d["start_quest"])
	if d.has("complete_quest"):
		QuestManager.complete(d["complete_quest"])
	if d.has("give_item_once"):
		Inventory.give_once(d["give_item_once"])

func _pick_entry() -> String:
	for entry in data.get("entry", []):
		if _conditions_met(entry):
			return entry.get("node", "")
	return ""

func _conditions_met(entry: Dictionary) -> bool:
	if entry.has("if_flag") and not GameState.has_flag(entry["if_flag"]):
		return false
	if entry.has("not_flag") and GameState.has_flag(entry["not_flag"]):
		return false
	if entry.has("min_day") and GameState.day < int(entry["min_day"]):
		return false
	if entry.has("has_item") and not Inventory.has_item(entry["has_item"]):
		return false
	if entry.has("quest_ready") and not QuestManager.is_ready(entry["quest_ready"]):
		return false
	return true

func reset() -> void:
	active = false
	current = {}
