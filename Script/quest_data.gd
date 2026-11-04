class_name QuestData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var objectives: Array[QuestObj] = []
@export var reward_item_id: String = ""
@export var reward_amount: int = 1
