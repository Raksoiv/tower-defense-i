extends Enemy


var positions := []
var last_direction: Vector2
var current_position: Vector2

var boost_multiplier := 1.8
var boost_speed : int
var boost_timer : SceneTreeTimer
var boost_length := .5


func _ready():
	boost_timer = get_tree().create_timer(0)
	boost_speed = int(round(speed * boost_multiplier))


func _physics_process(_delta: float):
	positions.append(global_position)

	if positions.size() > 2:
		var change = (positions[1] - positions[0]).angle_to(positions[2] - positions[1])
		if change > .01:
			if boost_timer.time_left <= 0:
				boost_timer = get_tree().create_timer(boost_length, false)
			else:
				boost_timer.time_left = boost_length
		positions.remove(0)

	if boost_timer.time_left <= 0:
		speed = stats.speed
	else:
		speed = boost_speed
