extends Control


func activate_menu():
	visible = true
	get_tree().paused = true
	$CenterContainer/VBoxContainer/ResumeB.visible = true


func pause_menu():
	activate_menu()
	$CenterContainer/VBoxContainer/Title.text = "Pause Menu"


func game_over_menu():
	activate_menu()
	$CenterContainer/VBoxContainer/ResumeB.visible = false
	$CenterContainer/VBoxContainer/Title.text = "Game Over"


func win_menu():
	game_over_menu()
	$CenterContainer/VBoxContainer/Title.text = "Congratulations!"


func _on_ResumeB_button_up():
	visible = false
	get_tree().paused = false


func _on_RestartB_button_up():
	get_tree().root.get_node("SceneHandler").restart_level()


func _on_QuitB_button_up():
	get_tree().root.get_node("SceneHandler").main_menu()
