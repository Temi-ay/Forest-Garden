extends Interactable

@export var item_id: String = ""
@export var amount: int = 1

var pickup_key: String = ""

func _ready() -> void:
	super()
	pickup_key = str(get_path())
	if GameState.collected.has(pickup_key):
		queue_free()

func interact(_player: Node) -> void:
	if GameState.collected.has(pickup_key):
		return
	if not Inventory.add(item_id, amount):
		DialogueManager.say("You can't carry any more of those.")
		return
	GameState.collected[pickup_key] = true
	Audio.sfx("tap", 0.05)
	var item: ItemData = Inventory.db[item_id]
	DialogueManager.say("Picked up %s." % item.display_name)
	queue_free()
