extends Node

const PATH := "user://settings.cfg"

var volumes := {"Master": 1.0, "Music": 1.0, "SFX": 1.0}
var fullscreen := false

func _ready() -> void:
	load_settings()
	for bus_name in volumes:
		_apply_volume(bus_name)
	if fullscreen and not OS.has_feature("web"):
		set_fullscreen(true)
		
func set_volume(bus_name: String, value: float) -> void:
	volumes[bus_name] = value
	_apply_volume(bus_name)
	
func _apply_volume(bus_name: String) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var v: float = volumes[bus_name]
	AudioServer.set_bus_mute(idx, v <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.001)))

func set_fullscreen(value: bool) -> void:
	fullscreen = value
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func save_settings() -> void:
	var cfg := ConfigFile.new()
	for bus_name in volumes:
		cfg.set_value("audio", bus_name, volumes[bus_name])
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.save(PATH)
	
func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	for bus_name in volumes:
		volumes[bus_name] = cfg.get_value("audio", bus_name, 1.0)
	fullscreen = cfg.get_value("display", "fullscreen", false)
