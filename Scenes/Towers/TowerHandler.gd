extends Node2D
class_name TowerHandler


enum tower_enum {
	CLUBS,
	DIAMONDS,
	SPADES,
}
onready var towers := {
	tower_enum.CLUBS: preload("res://Scenes/Towers/ClubsTower.tscn"),
	tower_enum.DIAMONDS: preload("res://Scenes/Towers/DiamondsTower.tscn"),
	tower_enum.SPADES: preload("res://Scenes/Towers/SpadesTower.tscn"),
}
onready var towers_data := {
	tower_enum.CLUBS: ResourceLoader.load("res://Resources/Towers/ClubsTowerData.tres", "", true),
	tower_enum.DIAMONDS: ResourceLoader.load("res://Resources/Towers/DiamondsTowerData.tres", "", true),
	tower_enum.SPADES: ResourceLoader.load("res://Resources/Towers/SpadesTowerData.tres", "", true),
}

onready var drag_tower_type := {
	tower_enum.CLUBS: preload("res://Assets/Towers/suit_clubs.png"),
	tower_enum.DIAMONDS: preload("res://Assets/Towers/suit_diamonds.png"),
	tower_enum.SPADES: preload("res://Assets/Towers/suit_spades.png"),
}

var build_cell_position: Vector2
var build_invalid_color = Color("ccffaaaa")
var build_mode := false
var build_position: Vector2
var build_valid := false
var build_valid_color = Color("ccaaffaa")
var drag_tower = preload("res://Scenes/Towers/DragTower.tscn")

var exclusion_tilemap: TileMap
var drag_tower_inst: Node2D

var tower_type: int


func _process(_delta: float):
	if build_mode:
		_move_tower_preview()


func init_build_mode(tower_index: String):
	tower_type = int(tower_index)
	if build_mode:
		cancel_build_mode()
	$SFX/SoundButtonClick.play()

	drag_tower_inst = drag_tower.instance()
	drag_tower_inst.get_node("Type").texture = drag_tower_type[tower_type]
	drag_tower_inst.modulate = build_invalid_color

	var tower_stats: TowerData = towers_data[tower_type]
	var range_instance = drag_tower_inst.get_node("RangePreview")
	var scaling: float = float(tower_stats.fire_range) / range_instance.texture.get_height()
	range_instance.scale = Vector2(scaling, scaling)

	add_child(drag_tower_inst)
	drag_tower_inst.global_position = get_global_mouse_position()

	build_mode = true


func cancel_build_mode():
	build_mode = false
	build_valid = false
	drag_tower_inst.queue_free()


func _move_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = exclusion_tilemap.world_to_map(mouse_position)
	var tile_position = exclusion_tilemap.map_to_world(current_tile)

	drag_tower_inst.global_position = tile_position

	if exclusion_tilemap.get_cellv(current_tile) == TileMap.INVALID_CELL:
		drag_tower_inst.modulate = build_valid_color
		build_valid = true
		build_position = tile_position
		build_cell_position = current_tile
	else:
		drag_tower_inst.modulate = build_invalid_color
		build_valid = false


func can_build() -> bool:
	return (
		build_mode
		&& build_valid
	)


func get_tower_stats() -> TowerData:
	return towers_data[tower_type]


func get_towers_stats() -> Dictionary:
	return towers_data


func build():
	var new_tower: Tower = towers[tower_type].instance()
	new_tower.stats = towers_data[tower_type]
	$SFX/SoundPlaceTower.play(0.3)
	new_tower.position = build_position
	new_tower.real = true
	add_child(new_tower)
	exclusion_tilemap.set_cellv(build_cell_position, 5)


func increase_tower_cost(wave: int):
	for data in towers_data.values():
		if wave >= data.wave:
			data.cost = round(data.cost * 1.2)
