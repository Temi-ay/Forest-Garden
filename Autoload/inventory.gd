extends Node

signal changed

const ITEM_DIR := "res://Data/Items/"

var db: Dictionary = {}       # id -> ItemData
var counts: Dictionary = {}   # id -> amount carried

func _ready() -> void:
	for file in DirAccess.get_files_at(ITEM_DIR):
		file = file.trim_suffix(".remap")   # exported builds rename resources
		if file.ends_with(".tres"):
			var item := load(ITEM_DIR + file) as ItemData
			if item:
				db[item.id] = item

func add(id: String, amount: int = 1) -> bool:
	if not db.has(id):
		push_error("Unknown item id: " + id)
		return false
	var item: ItemData = db[id]
	if counts.get(id, 0) >= item.max_stack:
		return false
	counts[id] = mini(counts.get(id, 0) + amount, item.max_stack)
	changed.emit()
	return true

func remove(id: String, amount: int = 1) -> bool:
	if count(id) < amount:
		return false
	counts[id] -= amount
	if counts[id] <= 0:
		counts.erase(id)
	changed.emit()
	return true

func count(id: String) -> int:
	return counts.get(id, 0)

func has_item(id: String) -> bool:
	return count(id) > 0


func give_once(id: String, amount: int = 1) -> bool:
	var key := "given:" + id
	if GameState.collected.has(key):
		return false
	if not add(id, amount):
		return false
	GameState.collected[key] = true
	return true
	
func reset() -> void:
	counts.clear()
	changed.emit()
