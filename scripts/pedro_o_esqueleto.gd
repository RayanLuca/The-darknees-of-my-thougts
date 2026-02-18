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
const OSSO_DO_PEDRINHO = preload("uid://dyd80leaeu50o")
@onready var collision_shape: CollisionShape2D = $hitbox/CollisionShape2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const SPEED = 30.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState 

var directrion = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()
	
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state()
		SkeletonState.dead:
			dead_state()

	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	animated_sprite_2d.play("walk")
	
	
	
	
func go_to_attack_state():
	status = SkeletonState.attack
	animated_sprite_2d.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	
	
	
	
	
	
func go_to_dead_state():
	status = SkeletonState.dead
	animated_sprite_2d.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO

	
	
	
	
	
	
func walk_state(delta):
	if animated_sprite_2d.frame == 3 or animated_sprite_2d.frame == 4:
		velocity.x = SPEED * directrion
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		scale.x *= -1
		directrion *= -1
		return
	if not ground_detector.is_colliding():
		scale.x *= -1
		directrion *= -1
		return
	
	if player_detector.is_colliding():
		go_to_attack_state()
		return
	
func attack_state():
	if animated_sprite_2d.frame == 2 && can_throw:
		throw_bone()
		can_throw = false
	
func dead_state():
	pass
	
	
func take_damage():
	go_to_dead_state()

func throw_bone():
	var new_bone = OSSO_DO_PEDRINHO.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(self.directrion)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		go_to_walk_state()
		return
