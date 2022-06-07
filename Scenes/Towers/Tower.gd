extends Node2D
class_name Tower


export(Resource) var stats


onready var bullet = preload("res://Scenes/Towers/Bullet.tscn")


var real = false
var ready = true
var enemy_list = []
var enemy_target: Enemy = null


func _ready():
	if real:
		var range_obj: Area2D = self.get_node("Range")
		range_obj.get_node("CollisionShape2D").get_shape().radius = 0.5 * stats.fire_range

		var error = range_obj.connect("area_entered", self, "_on_area_entered")
		if error:
			print_debug("[ERROR] Tower area entered not conected properly")

		error = range_obj.connect("area_exited", self, "_on_area_exited")
		if error:
			print_debug("[ERROR] Tower area entered not conected properly")


func _physics_process(_delta: float):
	if enemy_target and ready:
		_shoot()


func _shoot():
	var new_bullet: Bullet = _create_bullet()
	add_child(new_bullet, true)
	move_child(new_bullet, 0)
	ready = false
	yield(get_tree().create_timer(stats.fire_rate), "timeout")
	ready = true


func _create_bullet():
	var new_bullet: Bullet = bullet.instance()
	new_bullet.velocity = stats.bullet_velocity
	new_bullet.damage = stats.damage
	new_bullet.target = enemy_target
	new_bullet.position = Vector2(32, 32)

	# Set bullet type
	var bullet_type: Sprite = Sprite.new()
	bullet_type.texture = $Type.texture
	bullet_type.scale = Vector2(0.15, 0.15)
	bullet_type.rotation_degrees = 90
	bullet_type.modulate = Color("333333")
	new_bullet.add_child(bullet_type)

	return new_bullet


func _select_enemy(enemy: Enemy = null):
	if enemy_list.size() == 0:
		return null

	if enemy != null:
		if enemy_target != null:
			if enemy.offset > enemy_target.offset:
				enemy_target = enemy
		else:
			enemy_target = enemy
	else:
		var best_enemy: Enemy = enemy_list[0]
		for enemy in enemy_list.slice(1, enemy_list.size()):
			if enemy.offset > best_enemy.offset:
				best_enemy = enemy
		enemy_target = best_enemy


func _on_area_entered(area: Area2D):
	var enemy: Enemy = area.get_parent()
	enemy_list.append(enemy)
	_select_enemy(enemy)


func _on_area_exited(area: Area2D):
	var enemy: Enemy = area.get_parent()
	enemy_list.erase(enemy)
	if enemy_target == enemy:
		enemy_target = null
		_select_enemy()
