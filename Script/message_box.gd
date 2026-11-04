extends CanvasLayer

@onready var speaker_label: Label = $PanelContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $PanelContainer/VBoxContainer/TextLabel
@onready var choices_box: VBoxContainer = $PanelContainer/VBoxContainer/ChoicesBox

var tween: Tween

func _ready() -> void:
	hide()
	DialogueManager.line_changed.connect(_on_line_changed)
	DialogueManager.dialogue_ended.connect(hide)
	
func _on_line_changed(speaker: String, text: String, choices: Array) -> void:
	show()
	speaker_label.text = speaker
	speaker_label.visible = speaker !=""
	text_label.text = text
	_type_text()
	for child in choices_box.get_children():
		child.queue_free()
	for i in choices.size():
		var button := Button.new()
		button.text = choices[i].get("text","...")
		button.pressed.connect(DialogueManager.choose.bind(i))
		choices_box.add_child(button)
		if i == 0:
			button.grab_focus.call_deferred()

func _type_text() -> void:
	if tween:
		tween.kill()
	text_label.visible_ratio = 0.0
	tween = create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, text_label.text.length() / 40.0)
	
func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("Interact"):
		return
	get_viewport().set_input_as_handled()
	if tween and tween.is_running():
		tween.kill()
		text_label.visible_ratio = 1.0
	else:
		DialogueManager.advance()
