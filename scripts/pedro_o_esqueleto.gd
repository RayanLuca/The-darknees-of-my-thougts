extends CharacterBody2D

enum SkeletonState{
	walk,
	attack,
	dead
}

@onready var bone_start_position: Node2D = $BoneStartPosition
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var hitbox_collision: CollisionShape2D = $hitbox/CollisionShape2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D

const OSSO_DO_PEDRINHO = preload("uid://dyd80leaeu50o")
const SPEED = 30.0

var status: SkeletonState
var direction = 1
var can_throw = true
var is_dead = false

func _ready():
	add_to_group("Enemies")
	go_to_walk_state()

func _physics_process(delta):
	if status == SkeletonState.dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state()

	move_and_slide()

# =========================
# ESTADOS
# =========================

func go_to_walk_state():
	status = SkeletonState.walk
	animated_sprite_2d.play("walk")

func go_to_attack_state():
	status = SkeletonState.attack
	animated_sprite_2d.play("attack")
	velocity = Vector2.ZERO
	can_throw = true

func go_to_dead_state():
	if is_dead:
		return
		
	is_dead = true
	status = SkeletonState.dead
	animated_sprite_2d.play("dead")
	velocity = Vector2.ZERO
	
	# desativa colisões completamente
	hitbox.monitoring = false
	hitbox.set_deferred("monitorable", false)
	hitbox_collision.set_deferred("disabled", true)
	body_collision.set_deferred("disabled", true)
	
	remove_from_group("Enemies")

# =========================
# LÓGICA DOS ESTADOS
# =========================

func walk_state(_delta):
	if animated_sprite_2d.frame == 3 or animated_sprite_2d.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding() or not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		return
	
	if player_detector.is_colliding():
		go_to_attack_state()

func attack_state():
	if animated_sprite_2d.frame == 2 and can_throw:
		throw_bone()
		can_throw = false

# =========================
# DANO
# =========================

func take_damage():
	if is_dead:
		return
	go_to_dead_state()

# =========================
# ATAQUE
# =========================

func throw_bone():
	var new_bone = OSSO_DO_PEDRINHO.instantiate()
	get_tree().current_scene.add_child(new_bone)
	new_bone.global_position = bone_start_position.global_position
	new_bone.set_direction(direction)

# =========================
# SINAIS
# =========================

func _on_animated_sprite_2d_animation_finished():
	if status == SkeletonState.attack:
		go_to_walk_state()

func _on_hitbox_area_entered(area: Area2D):
	if is_dead:
		return
		
	if area.is_in_group("AttackPlayer"):
		take_damage()
