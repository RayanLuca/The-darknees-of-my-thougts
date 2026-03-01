extends CharacterBody2D

enum PlayerState{
	walk,
	idle,
	jump,
	fall,
	attack,
	duck,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var reload_timer: Timer = $ReloadTimer
@onready var bone_start_position: Marker2D = $BoneStartPosition

const FIRE = preload("uid://dldvg2lsyhvyf")

# ===============================================================
# SISTEMA DE VIDA
# ===============================================================

@export var max_health: int = 3
var health: int
signal health_changed(current_health)

@export var invincible_time: float = 0.8
var is_invincible: bool = false

# ===============================================================
# MOVIMENTO
# ===============================================================

@export var max_speed = 60
@export var aceleration = 60
@export var deceleration = 80

const JUMP_VELOCITY = -350.0

var direction = 0
var status: PlayerState
var can_throw = false

func move(delta): 
	update_direction()
	
	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * max_speed,
			aceleration * delta
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

# ===============================================================
# INICIALIZAÇÃO
# ===============================================================

func _ready() -> void:
	health = max_health
	emit_signal("health_changed", health)
	go_to_idle_state()
	add_to_group("Player")
	anim.animation_finished.connect(_on_animation_finished)

# ===============================================================
# LOOP PRINCIPAL
# ===============================================================

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.walk:
			walk_state(delta)
		PlayerState.idle:
			idle_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.attack:
			attack_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.dead:
			dead_state(delta)

	move_and_slide()

# ===============================================================
# TROCA DE ESTADOS
# ===============================================================

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	
func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")
	
func go_to_attack_state():
	status = PlayerState.attack
	anim.play("attack")
	velocity.x = 0
	can_throw = true

func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")

func exit_from_duck_state():
	pass

func go_to_dead_state():
	if status == PlayerState.dead:
		return
		
	status = PlayerState.dead
	anim.play("dead")
	velocity = Vector2.ZERO
	reload_timer.start()

# ===============================================================
# ESTADOS
# ===============================================================

func walk_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return
	
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if !is_on_floor():
		go_to_fall_state()

func idle_state(delta):
	move(delta)

	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if velocity.x != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_pressed("duck"):
		go_to_duck_state()

func jump_state(delta):
	move(delta)
		
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta):
	move(delta)
		
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()

func attack_state(_delta):
	velocity.x = 0
	
	if anim.frame == 5 and can_throw:
		throw_bone()
		can_throw = false

func duck_state(_delta):
	update_direction()
	
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		
func dead_state(_delta):
	pass

# ===============================================================
# SINAIS
# ===============================================================

func _on_animation_finished():
	if status == PlayerState.attack:
		go_to_idle_state()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if status == PlayerState.duck:
		return
	go_to_dead_state()

# ===============================================================
# SISTEMA DE DANO
# ===============================================================

func take_damage(amount: int):
	if status == PlayerState.dead:
		return
		
	if is_invincible:
		return
		
	# NÃO RECEBE DANO EM DUCK
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

	modulate = Color(1, 1, 1)
	is_invincible = false

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		var enemy = area.get_parent()
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage()
		go_to_jump_state()
	else:
		take_damage(1)
	
func hit_lethal_area():
	take_damage(1)

# ===============================================================
# ATAQUE À DISTÂNCIA
# ===============================================================

func throw_bone():
	if bone_start_position == null:
		return
		
	var new_bone = FIRE.instantiate()
	get_tree().current_scene.add_child(new_bone)

	var dir = direction
	
	if dir == 0:
		dir = -1 if anim.flip_h else 1

	var spawn_position = bone_start_position.global_position
	
	if dir < 0:
		spawn_position.x -= 16

	new_bone.global_position = spawn_position
	new_bone.set_direction(dir)
	
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
