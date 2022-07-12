extends Node2D
class_name Bullet


var target: Area2D
var velocity: int
var damage: int


func _physics_process(delta: float):
	if target == null:
		queue_free()
		return
	if target.is_queued_for_deletion():
		return
	if target.get_parent().is_queued_for_deletion() || not target.get_parent().alive:
		queue_free()
		return
	self.look_at(target.global_position)
	self.global_position  = self.global_position.move_toward(target.global_position, velocity * delta)
