extends Node2D

func _ready() -> void:
	Audio.music("Music")
	await get_tree().create_timer(0.6).timeout
	DialogueManager.start("res://Data/Dialogue/intro.json")
