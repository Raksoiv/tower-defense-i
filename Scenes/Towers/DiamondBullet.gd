extends Bullet
class_name DiamondBullet


func init_bullet():
	look_at(global_position + direction)


func move_bullet(delta: float):
	velocity = int(floor(velocity * acceleration))

	if life_span != null and life_span.time_left <= 0:
		queue_free()
	elif life_span == null:
		life_span = get_tree().create_timer(.4)

	global_position += direction * velocity * delta
