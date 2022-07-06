extends Node

onready var game_scene = preload("res://Scenes/MainScenes/GameScene.tscn")
onready var game_settings = preload("res://Resources/Game/GameSettings.tres")

func _ready():
	get_node("MainMenu/Main/HBoxContainer/VB/NewGame").connect("pressed", self, "_on_new_game_pressed")
	get_node("MainMenu/Main/HBoxContainer/VB/Quit").connect("pressed", self, "_on_quit_pressed")

	# Game Settings
	AudioServer.set_bus_volume_db(0, game_settings.master_vol)
	AudioServer.set_bus_volume_db(1, game_settings.music_vol)
	AudioServer.set_bus_volume_db(2, game_settings.sound_vol)


func clean_modifiers():
	get_tree().paused = false
	Engine.set_time_scale(1.0)


func restart_level():
	clean_modifiers()
	get_child(get_child_count() - 1).queue_free()
	var game_scene_instance = game_scene.instance()
	game_scene_instance.name = "GameScene"
	add_child(game_scene_instance)


func main_menu():
	$MusicPlayer.play()
	clean_modifiers()
	get_child(get_child_count() - 1).queue_free()
	$MainMenu.visible = true


func _on_new_game_pressed():
	$MusicPlayer.stop()
	$SoundButtonClick.play()
	$MainMenu.visible = false
	var game_scene_instance = game_scene.instance()
	game_scene_instance.name = "GameScene"
	add_child(game_scene_instance)


func _on_quit_pressed():
	$SoundButtonClick.play()
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit()
