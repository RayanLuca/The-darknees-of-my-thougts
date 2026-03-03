extends CharacterBody2D
class_name PlayerBase

@export var max_health: int = 3
var health: int
signal health_changed(current_health)

func _ready():
	health = max_health
	emit_signal("health_changed", health)

func _enter_tree():
	add_to_group("Player")
