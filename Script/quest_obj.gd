class_name QuestObj
extends Resource

enum Kind { HAVE_ITEM, FLAG }

@export var description: String = ""
@export var kind: Kind = Kind.HAVE_ITEM
@export var target: String = ""   # an item id, or a flag name
@export var amount: int = 1

func is_done() -> bool:
	match kind:
		Kind.HAVE_ITEM:
			return Inventory.count(target) >= amount
		Kind.FLAG:
			return GameState.has_flag(target)
	return false

func progress_text() -> String:
	if kind == Kind.HAVE_ITEM and amount > 1:
		return "%s (%d/%d)" % [description, mini(Inventory.count(target), amount), amount]
	return description
