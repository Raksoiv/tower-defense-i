extends Control


onready var game_settings = preload("res://Resources/Game/GameSettings.tres")


func _ready():
	read_game_settings()


func read_game_settings():
	$"Settings/VBoxContainer/MarginContainer/VBoxContainer/Master Slider".value = game_settings.master_vol_real()
	$"Settings/VBoxContainer/MarginContainer/VBoxContainer/Music Slider".value = game_settings.music_vol_real()
	$"Settings/VBoxContainer/MarginContainer/VBoxContainer/Sound Slider".value = game_settings.sound_vol_real()


func _on_Settings_button_up():
	$SoundButtonClick.play()
	read_game_settings()
	$Main.visible = false
	$Settings.visible = true


func _on_Back_button_up():
	$SoundButtonClick.play()
	$Settings.visible = false
	$Main.visible = true


func _on_Master_Slider_value_changed(value: float):
	game_settings.master_vol = value


func _on_Music_Slider_value_changed(value: float):
	game_settings.music_vol = value


func _on_Sound_Slider_value_changed(value: float):
	game_settings.sound_vol = value
