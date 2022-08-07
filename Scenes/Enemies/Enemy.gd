extends PathFollow2D
class_name Enemy


var stats: EnemyData
var speed: float
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

	_sfx_choice()


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


func _emit_hit_effect(position: Vector2):
	if not $HitEffect.is_emitting():
		$HitEffect.global_position = position
		$HitEffect.set_emitting(true)


func _die():
	alive = false
	$AnimationPlayer.play("Die")
	emit_signal("dead", stats)


func _on_bullet_enetered(area: Area2D):
	if alive and area.get_collision_layer_bit(1):
		var bullet: Bullet = area.get_parent()
		_emit_hit_effect(bullet.get_node("HitPoint").global_position)
		_take_damage(bullet.damage)
		bullet.queue_free()
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("TakeDamage")


func _sfx_choice():
	var effect_n = randi() % 5

	$SoundHit.stream = load("res://Assets/Sounds/EnemyHit/light_" + str(effect_n) + ".ogg")
