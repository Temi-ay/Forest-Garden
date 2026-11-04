class_name Interactable
extends Area2D

@onready var prompt: Label = $PromptLabel

func _ready() -> void:
	prompt.visible = false

func show_prompt(value: bool) -> void:
	prompt.visible = value

func interact(_player: Node) -> void:
	pass
