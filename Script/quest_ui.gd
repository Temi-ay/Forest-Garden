extends CanvasLayer

@onready var list: VBoxContainer = %QuestList
@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescrLabel
@onready var obj_label: Label = %ObjLabel

func _ready() -> void:
	hide()
	QuestManager.quest_updated.connect(func(): if visible: _refresh())
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Quests"):
		if visible:
			_close()
		elif not GameState.input_locked:
			_open()
		else:
			return
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()

func _open() -> void:
	show()
	_refresh()
	GameState.input_locked = true
		
func _close() -> void:
	hide()
	GameState.input_locked = false
		
func _refresh() -> void:
	for child in list.get_children():
		child.queue_free()
	title_label.text = ""
	desc_label.text = ""
	obj_label.text = ""
	var first := true
	for id in QuestManager.state:
		var quest: QuestData = QuestManager.db[id]
		var button := Button.new()
		button.text = quest.title + (" (done)" if QuestManager.state[id] == "complete" else "")
		button.focus_entered.connect(_show_quest.bind(quest))
		button.mouse_entered.connect(_show_quest.bind(quest))
		list.add_child(button)
		if first:
			button.grab_focus.call_deferred()
			first = false
func _show_quest(quest: QuestData) -> void:
	title_label.text = quest.title
	desc_label.text = quest.description
	var finished: bool = QuestManager.state.get(quest.id, "") == "complete"
	var lines: PackedStringArray = []
	for objective in quest.objectives:
		lines.append(("[x] " if finished or objective.is_done() else "[ ] ") + objective.progress_text())
	if QuestManager.is_ready(quest.id):
		lines.append("")
		lines.append("Ready to turn in.")
	obj_label.text = "\n".join(lines)
