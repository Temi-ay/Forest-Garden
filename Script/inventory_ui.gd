extends CanvasLayer

@onready var grid: GridContainer = %ItemGrid
@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel

func _ready() -> void:
	hide()
	Inventory.changed.connect(_refresh)
	DialogueManager.line_changed.connect(_on_dialogue_line)

func _on_dialogue_line(_speaker: String, _text:String, _choices:Array) -> void:
	if visible:
		_close()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
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
	GameState.menu_open = true

func _close() -> void:
	hide()
	GameState.menu_open = false

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	name_label.text = ""
	desc_label.text = ""
	var first := true
	for id in Inventory.counts:
		var item: ItemData = Inventory.db[id]
		var amount: int = Inventory.counts[id]
		var button := Button.new()
		button.custom_minimum_size = Vector2(40, 40)
		button.icon = item.icon
		button.expand_icon = true
		button.text = ("x%d" % amount) if amount > 1 else ""
		if item.icon == null:
			button.text = item.display_name.left(3) + (" x%d" % amount if amount > 1 else "")
		button.focus_entered.connect(_show_details.bind(item))
		button.mouse_entered.connect(_show_details.bind(item))
		grid.add_child(button)
		if first and visible:
			button.grab_focus.call_deferred()
			first = false
			

func _show_details(item: ItemData) -> void:
	name_label.text = item.display_name
	desc_label.text = item.description
