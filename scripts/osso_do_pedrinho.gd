extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 80
var direction = 1
 
func _process(delta: float) -> void:
	position.x += speed * delta * direction

func set_direction(skeleton_direction):
	direction = skeleton_direction
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.flip_h = true
		


func _on_destroyertimer_timeout() -> void:
	queue_free()
	
	



func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
