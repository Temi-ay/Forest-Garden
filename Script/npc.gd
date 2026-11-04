extends Interactable

@export_file("*.json") var dialogue_file: String

func interact(_player: Node) -> void:
	if dialogue_file != "":
		DialogueManager.start(dialogue_file)
