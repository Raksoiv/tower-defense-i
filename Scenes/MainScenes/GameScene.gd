extends Node2D
class_name GameScene


var player_money = 300
var player_lives = 5


var current_wave = 0
var enemy_stats: EnemyData
var last_wave = 0
var seconds_between_waves = 5
var wave_active = false
var waves = [
	["Pawn", "Pawn", "Pawn"],
	["Pawn", "Pawn", "Pawn", "Pawn", "Pawn"],
	["Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn"],
	["Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn"],
	[
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
	],
	[
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
	],
	[
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
		"Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn", "Pawn",
	]
]


var build_mode = false
var build_valid = false
var build_position: Vector2
var build_type: String
var build_cell_position: Vector2


onready var build_bar = $UI/HUD/BuildBar
onready var map_node = $DemoMap
onready var towers = {
	"ClubsTower": preload("res://Scenes/Towers/ClubsTower.tscn"),
	"DiamondsTower": preload("res://Scenes/Towers/DiamondsTower.tscn"),
	"SpadesTower": preload("res://Scenes/Towers/SpadesTower.tscn"),
}
onready var enemies = {
	"Pawn": preload("res://Scenes/Enemies/Pawn.tscn"),
}


func _ready():
	# Initializing
	enemy_stats = ResourceLoader.load("res://Resources/Enemies/PawnData.tres", "", true)

	# Build buttons
	for container in build_bar.get_children():
		var button = container.get_node("TowerButton")
		var err = button.connect("pressed", self, "_initiate_build_mode", [container.get_name()])
		if err > 0:
			print_debug("[ERROR] Error connecting towers build event in GameScene")

	# Enemy reach end signal
	var end = map_node.get_node("Deck")
	end.connect("enemy_reach_end", self, "_on_enemy_reach_end")


func _process(_delta: float):
	# Build
	if build_mode:
		_update_tower_preview()

	# Waves
	if wave_active and _get_active_enemies() == 0:
		if current_wave != len(waves):
			_start_wave_pause()
		else:
			$UI/Menu.win_menu()
	elif current_wave != last_wave and not wave_active:
		$UI/HUD/WaveBar/Sec2NextWave.text = str(ceil($WaveTimer.time_left))
		if $WaveTimer.is_stopped():
			start_next_wave()


func _unhandled_input(event: InputEvent):
	if build_mode:
		if event.is_action_released("ui_cancel"):
			cancel_build_mode()
		elif event.is_action_released("ui_accept"):
			_build()
			cancel_build_mode()
	else:
		if event.is_action_released("ui_cancel"):
			$UI/Menu.pause_menu()


##
## Wave Functions
##
func start_next_wave():
	$UI/HUD/WaveBar.visible = false
	last_wave = current_wave
	var wave_data = _retrieve_wave_data()
	yield(get_tree().create_timer(0.2), "timeout")
	_spawn_enemies(wave_data)


func _start_wave_pause():
	wave_active = false
	$WaveTimer.start(seconds_between_waves)
	$UI/HUD/WaveBar.visible = true
	$UI/HUD/WaveBar/Sec2NextWave.text = str(seconds_between_waves)


func _retrieve_wave_data() -> Array:
	return waves[current_wave]


func _spawn_enemies(wave_data: Array):
	if current_wave > 2:
		enemy_stats.health += enemy_stats.health * 0.3
		enemy_stats.cooldown -= enemy_stats.cooldown * 0.2
		enemy_stats.speed += enemy_stats.speed * 0.05

	for enemy in wave_data:
		var new_enemy: Enemy = enemies[enemy].instance()
		new_enemy.stats = enemy_stats
		map_node.get_node("Path").add_child(new_enemy, true)
		var err = new_enemy.connect("dead", self, "_on_enemy_dead")
		if err > 0:
			print_debug("[ERROR] Error connecting towers build event in GameScene")
		yield(get_tree().create_timer(new_enemy.stats.cooldown), "timeout")

	current_wave += 1
	wave_active = true


func _get_active_enemies():
	return map_node.get_node("Path").get_child_count()


##
## Build Functions
##
func _initiate_build_mode(tower_name: String):
	if build_mode:
		cancel_build_mode()
	$UI.set_tower_preview(tower_name, get_global_mouse_position())
	build_type = tower_name
	build_mode = true


func _update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var exlusion_obj: TileMap = $DemoMap/Exclusion
	var current_tile = exlusion_obj.world_to_map(mouse_position)
	var tile_position = exlusion_obj.map_to_world(current_tile)

	if exlusion_obj.get_cellv(current_tile) == TileMap.INVALID_CELL:
		$UI.update_tower_preview(tile_position, true)
		build_valid = true
		build_position = tile_position
		build_cell_position = current_tile
	else:
		$UI.update_tower_preview(tile_position, false)
		build_valid = false


func cancel_build_mode():
	build_mode = false
	build_valid = false
	$UI.delete_tower_preview()


func _can_build(new_tower: Tower) -> bool:
	return (
		build_mode
		&& build_valid
		&& player_money >= new_tower.stats.cost
	)


func _build():
	var new_tower: Tower = towers[build_type].instance()
	if _can_build(new_tower):
		$SFX/SoundPlaceTower.play(0.3)
		new_tower.position = build_position
		new_tower.real = true
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("Exclusion").set_cellv(build_cell_position, 5)

		player_money -= new_tower.stats.cost
		$UI.update_money()


##
## Player Functions
##
func _on_enemy_dead(enemy_data: EnemyData):
	player_money += enemy_data.reward
	$UI.update_money()


func _on_enemy_reach_end(enemy_data: EnemyData):
	player_lives -= enemy_data.damage
	$UI.update_lives()
	if player_lives <= 0:
		$UI/Menu.game_over_menu()
