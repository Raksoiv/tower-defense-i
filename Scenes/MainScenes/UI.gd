extends CanvasLayer


var player_data: PlayerData


var build_valid_color = Color("ccaaffaa")
var build_invalid_color = Color("ccffaaaa")

var button_disabled_color = Color("ccc")
var button_enabled_color = Color("333")


onready var towers: Dictionary = {
	"ClubsTower": preload("res://Scenes/Towers/ClubsTower.tscn"),
	"DiamondsTower": preload("res://Scenes/Towers/DiamondsTower.tscn"),
	"SpadesTower": preload("res://Scenes/Towers/SpadesTower.tscn"),
}
onready var range_texture: StreamTexture = preload("res://Assets/UI/BaseRange.png")


func _ready():
	update_tower_costs()
	update_money()
	update_lives()

	$HUD/Stats/Waves.text = "0"

##
## Game Controls Functions
##

func _on_PlayPause_pressed():
	$SoundButtonClick.play()
	var game_scene: GameScene = get_parent()

	if game_scene.build_mode:
		game_scene.cancel_build_mode()

	if get_tree().is_paused():
		get_tree().paused = false
	elif !game_scene.game_start:
		game_scene.start_next_wave()
	else:
		get_tree().paused = true


func _on_FastForward_pressed():
	$SoundButtonClick.play()
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)


##
## Build Functions
##

func set_tower_preview(tower_name: String, mouse_position: Vector2):
	var drag_tower: Tower = towers[tower_name].instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = build_invalid_color

	var range_instance = Sprite.new()
	range_instance.set_name("RangePreview")
	range_instance.position = Vector2(32, 32)
	range_instance.texture = range_texture
	range_instance.modulate = build_invalid_color
	var scaling: float = float(drag_tower.stats.fire_range) / range_texture.get_height()
	range_instance.scale = Vector2(scaling, scaling)

	var control = Control.new()
	control.add_child(drag_tower)
	control.add_child(range_instance)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child(control, 0)


func update_tower_preview(new_position: Vector2, valid: bool):
	var color = build_invalid_color
	if valid:
		color = build_valid_color

	if get_node("TowerPreview").rect_position != new_position:
		get_node("TowerPreview").rect_position = new_position
	if get_node("TowerPreview/DragTower").modulate != color:
		get_node("TowerPreview/DragTower").modulate = color
		get_node("TowerPreview/RangePreview").modulate = color


func delete_tower_preview():
	get_node("TowerPreview").free()



##
## Money Functions
##
func update_money():
	$HUD/Stats/Money.text = str(get_parent().player_money)
	update_towers_available()


func update_towers_available():
	var player_money: int = get_parent().player_money
	var tower := "ClubsTower"
	var button: TextureButton = get_node("HUD/BuildBar/" + tower + "/TowerButton")
	var button_icon: TextureRect = button.get_node("Icon")
	var tower_cost := int(get_node("HUD/BuildBar/" + tower + "/Cost/Label").text)

	if tower_cost > player_money:
		button.disabled = true
		button_icon.modulate = button_disabled_color
	else:
		button.disabled = false
		button_icon.modulate = button_enabled_color


##
## Lives Functions
##
func update_lives():
	$HUD/Stats/Lives.text = str(get_parent().player_lives)


##
## Tower Functions
##
func update_tower_costs():
	var tower = "ClubsTower"
	var label = get_node("HUD/BuildBar/" + tower + "/Cost/Label")
	label.text = str(towers[tower].instance().stats.cost)
