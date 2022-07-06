extends PathFollow2D
class_name Enemy


var stats: EnemyData
var speed: int
var health: int
var alive := true


signal dead(enemy_data)


func _ready():
	var body: Area2D = get_node("Body")
	var error = body.connect("area_entered", self, "_on_bullet_enetered")
	if error:
		print_debug("[ERROR] Enemy bullet entered not conected properly")

	speed = stats.speed
	health = stats.health

	$HealthBar.max_value = stats.health
	$HealthBar.value = stats.health
	$HealthBar.set_visible(false)

	_sfx_choice(stats.level)


func _physics_process(delta: float):
	if alive:
		_move(delta)


func _move(delta: float):
	set_offset(get_offset() + speed * delta)


func _take_damage(damage: int):
	health -= damage
	$HealthBar.value -= damage
	if not $HealthBar.is_visible():
		$HealthBar.set_visible(true)
	if health <= 0 and alive:
		_die()


func _die():
	alive = false
	emit_signal("dead", stats)
	$DeathEffect.set_emitting(true)
	$Sprite.set_visible(false)
	$Body.set_visible(false)
	$HealthBar.set_visible(false)
	yield(get_tree().create_timer($DeathEffect.lifetime), "timeout")
	queue_free()


func _on_bullet_enetered(area: Area2D):
	if alive and area.get_collision_layer_bit(1):
		var bullet: Bullet = area.get_parent()
		$SoundHit.play()
		if not $HitEffect.is_emitting():
			$HitEffect.global_position = bullet.get_node("HitPoint").global_position
			$HitEffect.set_emitting(true)
		_take_damage(bullet.damage)
		bullet.queue_free()


func _sfx_choice(level: int):
	var effect_n = randi() % 5

	match level:
		1:
			$SoundHit.stream = load("res://Assets/Sounds/EnemyHit/light_" + str(effect_n) + ".ogg")
