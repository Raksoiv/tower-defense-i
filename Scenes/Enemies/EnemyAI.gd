extends Path2D
class_name EnemyAI


signal enemy_dead(enemy_data)
signal wave_end


enum enemies_enum {
	PAWN,
}
onready var enemies := {
	enemies_enum.PAWN: preload("res://Scenes/Enemies/Pawn.tscn"),
}
onready var enemy_data_dict := {
	enemies_enum.PAWN: ResourceLoader.load("res://Resources/Enemies/PawnData.tres", "", true),
}

const stats_list = [
	"speed",
	"health",
	"cooldown",
]
const stats_upgrade = [
	1.2,
	1.4,
	.8,
]

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
	if current_wave != wave_upgrade:
		if current_wave == 1:
			return
		current_money -= _get_max_cost_available() * 1.5
	else:
		wave_upgrade += 3 if alter_upgrade else 2
		alter_upgrade = !alter_upgrade

	var choiced_enemy: int = enemies_enum.PAWN
	var choiced_stat_index: int = randi() % ((stats_list.size() * 2) - 2)
	var choiced_stat: String = stats_list[choiced_stat_index % stats_list.size()]

	enemy_data_dict[choiced_enemy].set(
		choiced_stat,
		enemy_data_dict[choiced_enemy].get(choiced_stat) * stats_upgrade[choiced_stat_index % stats_list.size()]
	)


func buy_enemies():
	while true:
		# Choice a random enemy
		var choiced_enemy: int = enemies_enum.PAWN

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


func _get_max_cost_available():
	return enemy_data_dict[enemies_enum.PAWN].cost


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
