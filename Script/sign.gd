extends Interactable

@export_multiline var message: String = "The forest feels different at night"

func interact(_player: Node) -> void:
	DialogueManager.say(message)
