extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 100
var direction = 1

func _ready():
	add_to_group("AttackPlayer")

# AGORA recebe a direção corretamente
func set_direction(new_direction):
	direction = new_direction
	
	if direction > 0:
		animated_sprite_2d.flip_h = false   # direita
	else:
		animated_sprite_2d.flip_h = true    # esquerda

func _physics_process(delta):
	position.x += direction * speed * delta

func _on_destroyertimer_timeout():
	queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("Enemies"):
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
