extends PathFollow2D
class_name Enemy


export(Resource) var stats


func _ready():
	var body: Area2D = get_node("Body")
	var error = body.connect("area_entered", self, "_on_bullet_enetered")
	if error:
		print_debug("[ERROR] Enemy bullet entered not conected properly")


func _physics_process(delta: float):
	_move(delta)


func _move(delta: float):
	set_offset(get_offset() + stats.speed * delta)


func _take_damage(damage: int):
	stats.health -= damage
	if stats.health <= 0:
		queue_free()


func _on_bullet_enetered(area: Area2D):
	if area.get_collision_layer_bit(1):
		var bullet: Bullet = area.get_parent()
		_take_damage(bullet.damage)
		bullet.queue_free()
