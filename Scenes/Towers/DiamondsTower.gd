extends Tower


onready var dbullet = preload("res://Scenes/Towers/DiamondBullet.tscn")


func _spawn_bullet():
	if !is_instance_valid(enemy_target):
		return

	var bullets_directions = [
		Vector2(1, 1),
		Vector2(-1, -1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(0, 1),
		Vector2(0, -1),
		Vector2(1, 0),
		Vector2(-1, 0),
	]

	for bullet_direction in bullets_directions:
		var new_bullet: Bullet = dbullet.instance()
		new_bullet.velocity = stats.bullet_velocity
		new_bullet.damage = stats.damage
		new_bullet.direction = bullet_direction.normalized()
		new_bullet.position = Vector2(32, 32)

		# Set bullet type
		var bullet_type: Sprite = Sprite.new()
		bullet_type.texture = $Type.texture
		bullet_type.scale = Vector2(0.15, 0.15)
		bullet_type.rotation_degrees = 90
		bullet_type.modulate = Color("333333")
		new_bullet.add_child(bullet_type)

		add_child(new_bullet, true)
