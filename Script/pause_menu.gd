extends CanvasLayer

const TITLE_SCENE := "res://Scene/main_menu.tscn"

@onready var buttons: Control = %PausePanel
@onready var resume_button: Button = %ResumeButton
@onready var controls_button: Button = %Instructions
@onready var title_button: Button = %TitleButton
@onready var controls_panel: Control = %ControlsPanel
@onready var back_button: Button = %BackButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	controls_panel.hide()
	resume_button.pressed.connect(_resume)
	controls_button.pressed.connect(_show_controls)
	back_button.pressed.connect(_hide_controls)
	title_button.pressed.connect(_to_title)
	
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		if controls_panel.visible:
			_hide_controls()
		else:
			_resume()
	elif not GameState.input_locked and not GameState.menu_open:
		_pause()
	else:
		return
	get_viewport().set_input_as_handled()
		
func  _pause() -> void:
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func _resume() -> void:
	hide()
	get_tree().paused = false
	
func _show_controls() -> void:
	buttons.hide()
	controls_panel.show()
	back_button.grab_focus()
	
func _hide_controls() -> void:
	controls_panel.hide()
	buttons.show()
	controls_button.grab_focus()

func _to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)
