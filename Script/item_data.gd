class_name ItemData
extends Resource
enum  Type {CONSUMABLE, KEY, QUEST, COLLECTIBLE, MATERIAL}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var type: Type = Type.MATERIAL
@export var max_stack: int = 99
