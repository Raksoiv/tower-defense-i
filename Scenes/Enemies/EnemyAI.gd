extends Path2D
class_name EnemyAI


signal enemy_dead(enemy_data)
signal wave_end


enum enemies_enum {
	PAWN,
	KNIGHT,
}
onready var enemies := {
	enemies_enum.PAWN: preload("res://Scenes/Enemies/Pawn.tscn"),
	enemies_enum.KNIGHT: preload("res://Scenes/Enemies/Knight.tscn"),
}
onready var enemy_data_dict := {
	enemies_enum.PAWN: ResourceLoader.load("res://Resources/Enemies/PawnData.tres", "", true),
	enemies_enum.KNIGHT: ResourceLoader.load("res://Resources/Enemies/KnightData.tres", "", true),
}

const stats_upgrade := {
	"speed": 1.2,
	"health": 1.4,
	"cooldown": .8,
}

var next_money: float = 0
var current_money: float = 100
var saved_money: float = 0
const upgrade_cost: int = 50

var wave_active = false
var current_wave = 0

var wave_upgrade = 3
var alter_upgrade = true


func _process(_delta: float):
	if _check_wave_end():
		end_wave()


func next_wave():
	wave_active = true
	current_wave += 1
	buy_upgrade()
	buy_enemies()


func buy_upgrade():
	var choiced_enemy_data: EnemyData = enemy_data_dict[_choose_enemy()]

	if current_wave != wave_upgrade:
		if current_wave == 1:
			return
		current_money -= choiced_enemy_data.cost * 1.5
	else:
		wave_upgrade += 3 if alter_upgrade else 2
		alter_upgrade = !alter_upgrade

	var choiced_stat: String = _choose_stat()

	choiced_enemy_data.set(
		choiced_stat,
		choiced_enemy_data.get(choiced_stat) * stats_upgrade[choiced_stat]
	)


func buy_enemies():
	while true:
		# Choice a random enemy
		var choiced_enemy: int = _choose_enemy()

		# Check if can afford
		if enemy_data_dict[choiced_enemy].cost > current_money:
			# Check if savings can afford
			if enemy_data_dict[choiced_enemy].cost > saved_money:
				break

			# Check if want to use saved money
			var chances = {
				0: 10,
				1: 0,
				2: 0,
				3: 2,
				4: 5,
			}
			var rand_value = randi() % 10
			if rand_value < chances[current_wave % 5]:
				saved_money -= enemy_data_dict[choiced_enemy].cost
				current_money += enemy_data_dict[choiced_enemy].cost
			else:
				break

		# Pay for the enemy
		current_money -= enemy_data_dict[choiced_enemy].cost

		# Create and prepare the enemy
		var enemy: Enemy = enemies[choiced_enemy].instance()
		enemy.stats = enemy_data_dict[choiced_enemy]
		var err = enemy.connect("dead", self, "_on_Enemy_dead")
		if err > 0:
			print_debug("[ERROR] Error connecting towers build event in GameScene")
		add_child(enemy)

		# Wait for enemy cooldown
		yield(get_tree().create_timer(enemy.stats.cooldown, false), "timeout")


func end_wave():
	current_money += next_money
	next_money = 0

	var max_cost_available = _get_max_cost_available()
	saved_money += max_cost_available
	current_money += 1 * max_cost_available

	emit_signal("wave_end")


func _get_max_cost_available() -> int:
	var max_cost = 0

	for enemy in enemy_data_dict.keys():
		if current_wave < enemy_data_dict[enemy].wave:
			continue

		var data = enemy_data_dict[enemy]
		if max_cost < data.cost:
			max_cost = data.cost

	return max_cost


func _choose_enemy() -> int:
	var available_enemies := []

	for enemy in enemies_enum.values():
		if enemy_data_dict[enemy].cost > current_money:
			continue
		if current_wave >= enemy_data_dict[enemy].wave:
			available_enemies.append(enemy)

	if available_enemies.size() > 0:
		return available_enemies[randi() % available_enemies.size()]
	return enemies_enum.PAWN


func _choose_stat() -> String:
	match randi() % 6:
		0, 1, 2:
			return "health"
		3, 4:
			return "speed"
		_:
			return "cooldown"



func _check_wave_end() -> bool:
	if !wave_active:
		return false

	if get_child_count() == 0:
		wave_active = false
		return true

	return false

func _on_Enemy_dead(var enemy_data: EnemyData):
	next_money += enemy_data.cost

	emit_signal("enemy_dead", enemy_data)
