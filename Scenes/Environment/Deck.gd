extends Node2D


func _on_Area2D_area_entered(area: Area2D):
	area.get_parent().queue_free()
