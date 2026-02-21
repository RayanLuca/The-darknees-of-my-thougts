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

#---------------------------------------------------------------
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var reload_timer: Timer = $ReloadTimer

#---------------------------------------------------------------
@export var max_speed = 80.0
@export var aceleration = 80
@export var deceleration = 80

const JUMP_VELOCITY = -300.0

var direction = 0
var status: PlayerState

#===============================================================
# MOVIMENTO
#===============================================================

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

#===============================================================
# INICIALIZAÇÃO
#===============================================================

func _ready() -> void:
	go_to_idle_state()
	add_to_group("Player")

#===============================================================
# LOOP PRINCIPAL
#===============================================================

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

#===============================================================
# TROCA DE ESTADOS
#===============================================================

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
	
func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")
	hitbox.monitoring = false   # imunidade ativada

func exit_from_duck_state():
	hitbox.monitoring = true    # imunidade desativada

func go_to_dead_state():
	if status == PlayerState.dead:
		return
		
	status = PlayerState.dead
	anim.play("dead")
	velocity = Vector2.ZERO
	reload_timer.start()

#===============================================================
# ESTADOS
#===============================================================

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
	
	# Sai automaticamente quando animação termina
	if not anim.is_playing():
		go_to_idle_state()

func duck_state(_delta):
	update_direction()
	
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()

func dead_state(_delta):
	pass

#===============================================================
# SINAIS
#===============================================================

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	if status == PlayerState.duck:
		return
	
	if area.is_in_group("Enemis"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if status == PlayerState.duck:
		return
	
	if body.is_in_group("LethalArea"):
		go_to_dead_state()

#===============================================================
# DANO
#===============================================================

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		go_to_dead_state()
	
func hit_lethal_area():
	go_to_dead_state()
