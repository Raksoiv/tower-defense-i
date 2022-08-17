extends Node2D
class_name GameScene


var player_money := 300
var player_lives := 5


var seconds_between_waves = 5
var game_start = false


var enemy_ai: EnemyAI
var wave_active = false


onready var build_bar = $UI/HUD/BuildBar
onready var map_node = $DemoMap
onready var tower_handler: TowerHandler = $DemoMap/TowerHandler


func _ready():
	# Build buttons
	for container in build_bar.get_children():
		var button = container.get_node("TowerButton")
		var err = button.connect("pressed", tower_handler, "init_build_mode", [container.get_name()])
		if err > 0:
			print_debug("[ERROR] Error connecting towers build event in GameScene")

	# Enemy reach end signal
	var end = map_node.get_node("Deck")
	end.connect("enemy_reach_end", self, "_on_enemy_reach_end")

	# EnemyAI signals
	enemy_ai = map_node.get_node("EnemyAI")
	var err = enemy_ai.connect("enemy_dead", self, "_on_EnemyAI_enemy_dead")
	if err > 0:
		print_debug("[ERROR] Error connecting enemy dead event in GameScene")
	err = enemy_ai.connect("wave_end", self, "_on_EnemyAI_wave_end")
	if err > 0:
		print_debug("[ERROR] Error connecting wave end event in GameScene")

	# TowerHandler init
	tower_handler.exclusion_tilemap = $DemoMap/Exclusion

	# Prepare labels and buttons
	update_ui()

func _process(_delta: float):
	if wave_active:
		$UI/HUD/WaveBar/Sec2NextWave.text = str(ceil($WaveTimer.time_left))


func _unhandled_input(event: InputEvent):
	if tower_handler.build_mode:
		if event.is_action_released("ui_cancel"):
			tower_handler.cancel_build_mode()
		elif event.is_action_released("ui_accept"):
			_build()
			tower_handler.cancel_build_mode()
	else:
		if event.is_action_released("ui_cancel"):
			$UI/Menu.pause_menu()


##
## Wave Functions
##
func start_next_wave():
	game_start = true
	wave_active = true
	$UI/HUD/WaveBar.visible = false
	enemy_ai.next_wave()
	$UI/HUD/Stats/Waves.text = str(enemy_ai.current_wave)


func _on_EnemyAI_wave_end():
	$WaveTimer.start(seconds_between_waves)
	$UI/HUD/WaveBar.visible = true
	$UI/HUD/WaveBar/Sec2NextWave.text = str(seconds_between_waves)

	if enemy_ai.current_wave % 5 == 0:
		tower_handler.increase_tower_cost(enemy_ai.current_wave)
		update_ui()


func _on_WaveTimer_timeout():
	wave_active = false
	start_next_wave()


func update_ui():
	var towers_data: Dictionary = tower_handler.get_towers_stats()
	$UI.unlock_towers(enemy_ai.current_wave, towers_data)
	$UI.update_tower_costs(towers_data)
	$UI.update_money(player_money)
	$UI.update_towers_available(player_money, enemy_ai.current_wave, towers_data)



##
## Build Functions
##
func _build():
	var new_tower_stats: TowerData = tower_handler.get_tower_stats()
	if player_money >= new_tower_stats.cost and tower_handler.can_build():
		tower_handler.build()

		player_money -= new_tower_stats.cost
		var towers_data: Dictionary = tower_handler.get_towers_stats()
		$UI.update_money(player_money)
		$UI.update_towers_available(player_money, enemy_ai.current_wave, towers_data)


##
## Player Functions
##
func _on_EnemyAI_enemy_dead(enemy_data: EnemyData):
	player_money += enemy_data.reward
	var towers_data: Dictionary = tower_handler.get_towers_stats()
	$UI.update_money(player_money)
	$UI.update_towers_available(player_money, enemy_ai.current_wave, towers_data)


func _on_enemy_reach_end(enemy_data: EnemyData):
	player_lives -= enemy_data.damage
	$UI.update_lives()
	if player_lives <= 0:
		$UI/Menu.game_over_menu(enemy_ai.current_wave)
