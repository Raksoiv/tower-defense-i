extends PathFollow2D
class_name Enemy


export(Resource) var stats


var speed
var health


func _ready():
	var body: Area2D = get_node("Body")
	var error = body.connect("area_entered", self, "_on_bullet_enetered")
	if error:
		print_debug("[ERROR] Enemy bullet entered not conected properly")

	speed = stats.speed
	health = stats.health

	$HealthBar.max_value = stats.health
	$HealthBar.value = stats.health


func _physics_process(delta: float):
	_move(delta)


func _move(delta: float):
	set_offset(get_offset() + speed * delta)


func _take_damage(damage: int):
	health -= damage
	$HealthBar.value -= damage
	if health <= 0:
		queue_free()


func _on_bullet_enetered(area: Area2D):
	if area.get_collision_layer_bit(1):
		var bullet: Bullet = area.get_parent()
		_take_damage(bullet.damage)
		bullet.queue_free()
