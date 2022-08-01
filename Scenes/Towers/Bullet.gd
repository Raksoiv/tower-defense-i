extends Node2D
class_name Bullet


var target: Area2D
var velocity: int
var damage: int

var acceleration := 1.05
var direction: Vector2
var life_span: SceneTreeTimer


func _ready():
	direction = (target.global_position - global_position).normalized()


func _physics_process(delta: float):
	velocity = int(floor(velocity * acceleration))
	if is_instance_valid(target) and target.get_parent().alive:
		direction = (target.global_position - global_position).normalized()
	elif life_span != null and life_span.time_left <= 0:
		queue_free()
	elif life_span == null:
		life_span = get_tree().create_timer(1)

	self.look_at(global_position + direction)
	global_position += direction * velocity * delta
