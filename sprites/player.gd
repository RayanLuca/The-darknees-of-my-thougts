extends CharacterBody2D

# =========================
# ENUM
# =========================
enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	dead
}

# =========================
# NÓS
# =========================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var hitbox_collision_shape: CollisionShape2D = $hitbox/CollisionShape2D

# =========================
# VIDA
# =========================
@export var max_health: int = 3
var health: int
signal health_changed(current_health)

@export var invincible_time: float = 0.8
var is_invincible: bool = false

# =========================
# MOVIMENTO
# =========================
@export var max_speed = 80.0
@export var acceleration = 80
@export var deceleration = 80
@export var slide_deceleration = 20

const JUMP_VELOCITY = -300.0

var jump_count = 0
var max_jump_count = 2
var direction = 0
var status: PlayerState

# Valores originais da colisão
var normal_radius
var normal_height
var normal_position_y

var normal_hitbox_height
var normal_hitbox_position_y

# =========================
# READY
# =========================
func _ready():
	# Duplica shapes para evitar problemas com Resource compartilhado
	collision_shape.shape = collision_shape.shape.duplicate()
	hitbox_collision_shape.shape = hitbox_collision_shape.shape.duplicate()

	# Guarda valores originais
	normal_radius = collision_shape.shape.radius
	normal_height = collision_shape.shape.height
	normal_position_y = collision_shape.position.y

	normal_hitbox_height = hitbox_collision_shape.shape.size.y
	normal_hitbox_position_y = hitbox_collision_shape.position.y

	health = max_health
	emit_signal("health_changed", health)
	go_to_idle_state()
	add_to_group("Player")

# =========================
# PHYSICS
# =========================
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.dead:
			dead_state(delta)

	move_and_slide()

# =========================
# MOVIMENTO BASE
# =========================
func move(delta):
	update_direction()

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * max_speed,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			deceleration * delta
		)

func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

# =========================
# TROCA DE ESTADOS
# =========================
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")

	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 5

func exit_from_duck_state():
	collision_shape.shape.radius = normal_radius
	collision_shape.shape.height = normal_height
	collision_shape.position.y = normal_position_y

	hitbox_collision_shape.shape.size.y = normal_hitbox_height
	hitbox_collision_shape.position.y = normal_hitbox_position_y

func go_to_slide_state():
	status = PlayerState.slide
	anim.play("slide")
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3

	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 5


	
func go_to_dead_state():
	if status == PlayerState.dead:
		return

	status = PlayerState.dead
	anim.play("dead")
	velocity = Vector2.ZERO
	reload_timer.start()

# =========================
# ESTADOS
# =========================
func idle_state(delta):
	move(delta)

	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_duck_state()

func walk_state(delta):
	move(delta)

	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
		return

	if not is_on_floor():
		go_to_fall_state()

func jump_state(delta):
	move(delta)

	if Input.is_action_just_pressed("jump") and jump_count < max_jump_count:
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta):
	move(delta)

	if Input.is_action_just_pressed("jump") and jump_count < max_jump_count:
		go_to_jump_state()
		return

	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()

func duck_state(_delta):
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()

func slide_state(delta):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	
	if velocity.x == 0:
		go_to_idle_state()
		collision_shape.shape.radius = normal_radius
		collision_shape.shape.height = normal_height
		collision_shape.position.y = normal_position_y
	
		hitbox_collision_shape.shape.size.y = normal_hitbox_height
		hitbox_collision_shape.position.y = normal_hitbox_position_y


func dead_state(_delta):
	pass

# =========================
# DANO
# =========================
func take_damage(amount: int):
	if status == PlayerState.dead:
		return

	if is_invincible:
		return

	if status == PlayerState.duck:
		return

	health -= amount
	emit_signal("health_changed", health)

	if health <= 0:
		go_to_dead_state()
	else:
		start_invincibility()

func start_invincibility():
	is_invincible = true
	modulate = Color(1, 0.6, 0.6)

	await get_tree().create_timer(invincible_time).timeout

	modulate = Color(1,1,1)
	is_invincible = false

# =========================
# HITBOX
# =========================
func _on_hitbox_area_entered(area):

	if area.is_in_group("LethalArea"):
		take_damage(1)
		return

	var enemy = area.get_parent()

	if enemy != null and enemy.is_in_group("Enemies"):

		if velocity.y > 150:
			if enemy.has_method("take_damage"):
				enemy.take_damage()
			velocity.y = JUMP_VELOCITY * 0.7
		else:
			take_damage(1)

func _on_hitbox_body_entered(body: Node2D):
	if status == PlayerState.duck:
		return
		
	go_to_dead_state()

# =========================
# RELOAD
# =========================
func _on_reload_timer_timeout():
	get_tree().reload_current_scene()
