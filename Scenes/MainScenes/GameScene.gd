extends Node2D


var current_wave = 0
var enemies_in_wave = 0


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
	for button in build_bar.get_children():
		var err = button.connect("pressed", self, "_initiate_build_mode", [button.get_name()])
		if err > 0:
			print_debug("[ERROR] Error connecting towers build event in GameScene")


func _process(_delta: float):
	if build_mode:
		_update_tower_preview()


func _unhandled_input(event: InputEvent):
	if build_mode:
		if event.is_action_released("ui_cancel"):
			cancel_build_mode()
		elif event.is_action_released("ui_accept"):
			_build()
			cancel_build_mode()


##
## Wave Functions
##

func start_next_wave():
	var wave_data = _retrieve_wave_data()
	yield(get_tree().create_timer(0.2), "timeout")
	_spawn_enemies(wave_data)


func _retrieve_wave_data() -> Array:
	var wave_data = [["Pawn", 0.7], ["Pawn", 0.7], ["Pawn", 0.7], ["Pawn", 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data


func _spawn_enemies(wave_data: Array):
	for enemy in wave_data:
		var new_enemy: Enemy = enemies[enemy[0]].instance()
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(enemy[1]), "timeout")


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


func _build():
	if build_mode && build_valid:
		var new_tower: Tower = towers[build_type].instance()
		new_tower.position = build_position
		new_tower.real = true
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("Exclusion").set_cellv(build_cell_position, 5)
