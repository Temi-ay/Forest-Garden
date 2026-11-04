extends Interactable

func interact(_player: Node) -> void:
	if GameState.has_flag("mira_quest_started") and not GameState.has_flag("mira_quest_done"):
		GameState.set_flag("ornament_found")
		Inventory.add("ornament")
		DialogueManager.say(" Here is the ornament. Mira is too careless, hopefully she doesn't lose it again")
	else:
		DialogueManager.say("An old man.")
