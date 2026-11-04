extends CanvasLayer

const TITLE_SCENE := "res://Scene/main_menu.tscn"
const FINAL_QUEST := "mira_quest"

@onready var title_button: Button = %EndButton

func _ready() -> void:
	hide()
	QuestManager.quest_completed.connect(_on_quest_completed)
	title_button.pressed.connect(func(): get_tree().change_scene_to_file(TITLE_SCENE))
	
func _on_quest_completed(id: String) -> void:
	if id != FINAL_QUEST:
		return
	if DialogueManager.active:
		await DialogueManager.dialogue_ended
	await get_tree().create_timer(1.2).timeout
	show()
	GameState.input_locked = true
	title_button.grab_focus()
