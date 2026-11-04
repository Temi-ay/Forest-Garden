extends Control

const GAME_SCENE := "res://Scene/game.tscn"

@onready var play_button: Button = %Play
@onready var howto_button: Button = %Instructions
@onready var settings_button: Button = %Settings
@onready var quit_button: Button = %Quit
@onready var howto_panel: Control = %HowToPanel
@onready var settings_panel: Control = %SettingsPanel
@onready var howto_close: Button = %BackButton
@onready var settings_close: Button = %SettingsClose
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var fullscreen_check: CheckBox = %FullscreenCheck

func _ready() -> void:
	Audio.music("Music")
	howto_panel.hide()
	settings_panel.hide()

	play_button.pressed.connect(_on_play)
	howto_button.pressed.connect(_open_panel.bind(howto_panel, howto_close))
	settings_button.pressed.connect(_open_panel.bind(settings_panel, settings_close))
	howto_close.pressed.connect(_close_panel.bind(howto_panel))
	settings_close.pressed.connect(_close_panel.bind(settings_panel))
	quit_button.pressed.connect(get_tree().quit)
	quit_button.visible = not OS.has_feature("web")   

	master_slider.value = Settings.volumes["Master"]
	music_slider.value = Settings.volumes["Music"]
	sfx_slider.value = Settings.volumes["SFX"]
	fullscreen_check.button_pressed = Settings.fullscreen
	master_slider.value_changed.connect(func(v: float): Settings.set_volume("Master", v))
	music_slider.value_changed.connect(func(v: float): Settings.set_volume("Music", v))
	sfx_slider.value_changed.connect(func(v: float): Settings.set_volume("SFX", v))
	fullscreen_check.toggled.connect(Settings.set_fullscreen)

	play_button.grab_focus()
	

func _open_panel(panel: Control, close_button: Button) -> void:
	panel.show()
	close_button.grab_focus()


func _close_panel(panel: Control) -> void:
	panel.hide()
	Settings.save_settings()
	play_button.grab_focus()

func _on_play() -> void:
	GameState.reset()
	Inventory.reset()
	QuestManager.reset()
	DialogueManager.reset()
	get_tree().change_scene_to_file(GAME_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if howto_panel.visible:
			_close_panel(howto_panel)
		elif settings_panel.visible:
			_close_panel(settings_panel)
