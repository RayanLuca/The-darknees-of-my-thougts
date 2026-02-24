extends CharacterBody2D

# =========================
# ENUM DE ESTADOS DO PLAYER
# =========================
enum PlayerState{
	idel,
	walk,
	jump,
	fall,
	duck,
	slide,
	dead
}

# =========================
# NÓS DA CENA



# =========================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var hitbox_collision_shape: CollisionShape2D = $hitbox/CollisionShape2D


# =========================
# CONFIGURAÇÕES DE MOVIMENTO
# =========================
@export var max_speed = 80.0
@export var aceleration = 80
@export var deceleration =80
@export var slide_deceleration = 20

# =========================
# CONSTANTES E VARIÁVEIS
# =========================
const JUMP_VELOCITY = -300.0

var jump_count=0
var max_jump_count = 2
var direction = 0
var status: PlayerState

# =========================
# MOVIMENTO HORIZONTAL
# =========================
func move(delta): 
	update_direction()
	
	if direction:
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

# =========================
# INICIALIZAÇÃO
# =========================
func _ready() -> void:
	go_to_idle_state()
	add_to_group("Player")


# =========================
# LOOP PRINCIPAL DE FÍSICA
# =========================
func _physics_process(delta: float) -> void:
	
	# aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# máquina de estados
	match status:
		PlayerState.idel:
			idel_state(delta)
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
	
	# movimento real do corpo
	move_and_slide()

# =========================
# FUNÇÕES DE TROCA DE ESTADO
# =========================
func go_to_idle_state():
	status = PlayerState.idel
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("wolk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 3
	
func exit_from_dunk_state():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_slide_state():
	status = PlayerState.slide
	anim.play("slide")
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 2
	
	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 3

func exit_from_slide_state():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

func go_to_dead_state():
	if status == PlayerState.dead:
		return
		
	status = PlayerState.dead
	anim.play("dead")
	velocity.x = 0
	reload_timer.start()
	
# =========================
# ESTADOS DO PERSONAGEM
# =========================
func idel_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if velocity.x !=0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if Input.is_action_pressed("duck"):
		go_to_duck_state()	
		return

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
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && jump_count < max_jump_count:
		go_to_jump_state()
		return
		
	if velocity.y > 0:
		go_to_fall_state()

func duck_state(_delta):
	update_direction()
	
	if Input.is_action_just_released("duck"):
		go_to_idle_state()
		exit_from_dunk_state()
	return

func fall_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && jump_count < max_jump_count:
		go_to_jump_state()
		return
		
	if is_on_floor():
		jump_count = 0
		if velocity.x ==0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func slide_state(delta):
	velocity.x =move_toward(velocity.x,0, slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_dunk_state()
		go_to_walk_state()
		return	
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return

func dead_state(_delta):
	pass
	
	
# =========================
# DIREÇÃO DO PERSONAGEM
# =========================
func update_direction():
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemis"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_dead_state()
	
	
	
	
	
func hit_enemy(area: Area2D):
	var enemy = area.get_parent()
	
	# centro do player comparado ao topo do inimigo
	if global_position.y < enemy.global_position.y:
		enemy.take_damage()
		velocity.y = JUMP_VELOCITY * 0.7  # pequeno pulo de retorno
	else:
		go_to_dead_state()
	
func hit_lethal_area():
	go_to_dead_state()
	
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
