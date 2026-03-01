extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var destroy_timer: Timer = $DestroyerTimer

@export var speed: float = 80
@export var max_health: int = 1
@export var damage: int = 1

var health: int
var direction: int = 1
var is_dead: bool = false

func _ready():
	health = max_health
	add_to_group("Enemies")

func _process(delta):
	if is_dead:
		return
		
	position.x += speed * delta * direction

func set_direction(new_direction):
	direction = new_direction
	
	if direction < 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

# =========================
# DANO
# =========================
func take_damage(amount: int = 1):
	if is_dead:
		return
		
	health -= amount
	
	if health <= 0:
		die()

func die():
	is_dead = true
	animated_sprite.play("dead")
	destroy_timer.start()

# =========================
# COLISÕES
# =========================
func _on_body_entered(body):
	if is_dead:
		return
		
	if body.is_in_group("Player"):
		body.take_damage(damage)

func _on_area_entered(area):
	if is_dead:
		return
		
	# Se colidir com algo que não seja o player, pode decidir o que fazer
	if not area.is_in_group("Player"):
		queue_free()

func _on_destroyer_timer_timeout():
	queue_free()
