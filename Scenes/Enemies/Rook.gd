extends Enemy


var positions := []

var acceleration := 125
var boost_multiplier := 3
var boost_speed: float

var cooldown_timer: SceneTreeTimer
var cooldown_time := .6


func _ready():
	cooldown_timer = get_tree().create_timer(0)
	boost_speed = speed * boost_multiplier


func _physics_process(delta: float):
	positions.append(global_position)

	if positions.size() > 2:
		var change = (positions[1] - positions[0]).angle_to(positions[2] - positions[1])
		if change > .01:
			if cooldown_timer.time_left <= 0:
				cooldown_timer = get_tree().create_timer(cooldown_time, false)
			else:
				cooldown_timer.time_left = cooldown_time
		positions.remove(0)

	if cooldown_timer.time_left <= 0:
		speed = move_toward(speed, boost_speed, acceleration * delta)
	else:
		speed = stats.speed
