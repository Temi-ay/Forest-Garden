extends Node

signal quest_updated
signal quest_completed(id: String)
const QUEST_DIR := "res://Data/Quests/"

var db: Dictionary = {}      # id -> QuestData
var state: Dictionary = {}   # id -> "active" or "complete"

func _ready() -> void:
	for file in DirAccess.get_files_at(QUEST_DIR):
		file = file.trim_suffix(".remap")
		if file.ends_with(".tres"):
			var quest := load(QUEST_DIR + file) as QuestData
			if quest:
				db[quest.id] = quest
	Inventory.changed.connect(func(): quest_updated.emit())

func start(id: String) -> void:
	if not db.has(id) or state.has(id):
		return
	state[id] = "active"
	GameState.set_flag(id + "_started")
	quest_updated.emit()

func complete(id: String) -> void:
	if state.get(id, "") != "active":
		return
	state[id] = "complete"
	GameState.set_flag(id + "_done")
	var quest: QuestData = db[id]
	if quest.reward_item_id != "":
		Inventory.add(quest.reward_item_id, quest.reward_amount)
	quest_updated.emit()
	Audio.sfx("quest_complete")
	quest_completed.emit(id)

func is_ready(id: String) -> bool:
	if state.get(id, "") != "active":
		return false
	for objective in db[id].objectives:
		if not objective.is_done():
			return false
	return true
	
func reset() -> void:
	state.clear()
	quest_updated.emit()
