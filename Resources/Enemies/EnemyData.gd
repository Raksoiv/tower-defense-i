extends Resource
class_name EnemyData


export(int) var speed
export(int) var health


func _init(_speed: int = 300):
	speed = _speed
