extends Node2D
class_name Bullet


var target: Node2D
var velocity: int
var damage: int


func _physics_process(delta: float):
	if target.is_queued_for_deletion():
		queue_free()
	self.look_at(target.global_position)
	self.global_position  = self.global_position.move_toward(target.global_position, velocity * delta)
