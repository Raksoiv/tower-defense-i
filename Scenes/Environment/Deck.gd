extends Node2D


signal enemy_reach_end(enemy_data)


func _on_Area2D_area_entered(area: Area2D):
	var enemy: Enemy = area.get_parent()
	emit_signal("enemy_reach_end", enemy.stats)
	enemy.queue_free()
