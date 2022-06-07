extends Node

onready var game_scene = preload("res://Scenes/MainScenes/GameScene.tscn")

func _ready():
	get_node("MainMenu/M/VB/NewGame").connect("pressed", self, "_on_new_game_pressed")
	get_node("MainMenu/M/VB/Quit").connect("pressed", self, "_on_quit_pressed")
	

func _on_new_game_pressed():
	get_node("MainMenu").queue_free()
	add_child(game_scene.instance())
	

func _on_quit_pressed():
	get_tree().quit()
