extends CharacterBody2D

@export var speed: float = 80.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var tilemap: TileMapLayer = get_parent().get_node_or_null("Ground")
@onready var interaction_area: Area2D = $InteractionArea

var facing: String = "Down"  
var nearby: Array[Interactable] = []

func _ready() -> void:
	if tilemap != null:
		var rect := tilemap.get_used_rect()
		var ts := tilemap.tile_set.tile_size
		camera.limit_left = rect.position.x * ts.x
		camera.limit_top = rect.position.y * ts.y
		camera.limit_right = rect.end.x * ts.x
		camera.limit_bottom = rect.end.y * ts.y

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	if not GameState.input_locked:
		input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_dir * speed
	move_and_slide()
	_update_animation(input_dir)


func _update_animation(input_dir: Vector2) -> void:
	if input_dir != Vector2.ZERO:
		if abs(input_dir.x) > abs(input_dir.y):
			facing = "Right" if input_dir.x > 0 else "Left"
		else:
			facing = "Down" if input_dir.y > 0 else "Up"
	
	var prefix = "walk_" if input_dir != Vector2.ZERO else "idle_"
	var anim_name = prefix + facing
	
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
			


func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area is Interactable:
		nearby.append(area)
		_refresh_prompt()

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby.erase(area)
		area.show_prompt(false)
		_refresh_prompt()
		

func _unhandled_input(event: InputEvent) -> void:
	if GameState.input_locked:
		return
	if event.is_action_pressed("Interact"):
		var target := _get_closest()
		if target != null:
			target.interact(self)

func _clean_nearby() -> void:
	for i in nearby.duplicate():
		if not is_instance_valid(i):
			nearby.erase(i)

func _refresh_prompt() -> void:
	_clean_nearby()
	var closest := _get_closest()
	for i in nearby:
		i.show_prompt(i == closest)

func _get_closest() -> Interactable:
	_clean_nearby()
	var best: Interactable = null
	for i in nearby:
		if best == null or global_position.distance_to(i.global_position) < global_position.distance_to(best.global_position):
			best = i
	return best
