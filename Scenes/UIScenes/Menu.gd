extends Control


onready var game_settings: GameSettings = preload("res://Resources/Game/GameSettings.tres")


func _ready():
	$CenterContainer/Settings/MasterSlider.value = game_settings.master_vol_real()
	$CenterContainer/Settings/MusicSlider.value = game_settings.music_vol_real()
	$CenterContainer/Settings/SFXSlider.value = game_settings.sound_vol_real()


func activate_menu():
	visible = true
	get_tree().paused = true
	$CenterContainer/Main/ResumeB.visible = true
	$CenterContainer/Main/Subtitle.visible = false


func pause_menu():
	activate_menu()
	$CenterContainer/Main/Title.text = "Pause Menu"


func game_over_menu(wave: int):
	activate_menu()
	$CenterContainer/Main/ResumeB.visible = false
	$CenterContainer/Main/Title.text = "Game Over"
	$CenterContainer/Main/Subtitle.text = "You survive " + str(wave) + " waves"
	$CenterContainer/Main/Subtitle.visible = true


func _on_ResumeB_button_up():
	visible = false
	get_tree().paused = false


func _on_RestartB_button_up():
	get_tree().root.get_node("SceneHandler").restart_level()


func _on_QuitB_button_up():
	get_tree().root.get_node("SceneHandler").main_menu()


func _on_SettingsB_button_up():
	$CenterContainer/Main.visible = false
	$CenterContainer/Settings.visible = true


func _on_BackB_button_up():
	$CenterContainer/Main.visible = true
	$CenterContainer/Settings.visible = false


func _on_SFXSlider_value_changed(value:float):
	game_settings.sound_vol = value


func _on_MusicSlider_value_changed(value:float):
	game_settings.music_vol = value


func _on_MasterSlider_value_changed(value:float):
	game_settings.master_vol = value
