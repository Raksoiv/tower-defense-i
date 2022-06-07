extends Resource
class_name TowerData


export(int) var fire_range
export(float) var fire_rate
export(int) var damage
export(int) var bullet_velocity


func _init(_fire_range: int = 300, _fire_rate: float = 1, _damage : int = 10, _bullet_velocity: int = 1):
	fire_range = _fire_range
	fire_rate = _fire_rate
	damage = _damage
	bullet_velocity = _bullet_velocity
