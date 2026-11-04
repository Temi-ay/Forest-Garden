extends Node

const MUSIC_DIR := "res://Audio/Music/"
const SFX_DIR := "res://Audio/SFX/"
const EXTENSIONS := ["ogg", "wav", "mp3"]
const SFX_VOICES := 8

var music_player := AudioStreamPlayer.new()
var sfx_players: Array[AudioStreamPlayer] = []
var cache: Dictionary = {}
var unlocked: bool = not OS.has_feature("web")   # browsers allow sound only after the first click or key

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = "Music"
	add_child(music_player)
	for i in SFX_VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)
	get_tree().node_added.connect(_on_node_added)

func _input(event: InputEvent) -> void:
	if unlocked:
		return
	if (event is InputEventMouseButton or event is InputEventKey) and event.pressed:
		unlocked = true
		if music_player.stream != null:
			music_player.play()   # restart once, now that the browser allows sound

func music(track: String) -> void:
	var stream := _find(MUSIC_DIR, track)
	if stream == null or (music_player.stream == stream and music_player.playing):
		return
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func sfx(sound: String, pitch_variation: float = 0.0) -> void:
	var stream := _find(SFX_DIR, sound)
	if stream == null:
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
			p.play()
			return

func _find(dir: String, base: String) -> AudioStream:
	var key := dir + base
	if cache.has(key):
		return cache[key]
	var stream: AudioStream = null
	for ext in EXTENSIONS:
		var path := "%s%s.%s" % [dir, base, ext]
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	if stream == null:
		push_warning("Audio file not found: " + key)   # shows in the editor and the browser console (F12)
	cache[key] = stream
	return stream

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(sfx.bind("click"))
