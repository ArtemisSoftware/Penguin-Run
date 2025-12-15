extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

const SPINNING_BONE = preload("res://entities/enemies/skeleton/scene/spinning_bone.tscn")


const SPEED = 30.0
const JUMP_VELOCITY = -400.0


enum SkeletonState {
	walk,
	attack,
	dead
}


var status: SkeletonState
var direction = 1
var can_throw = true


func _ready() -> void:
	go_to_walk_state()
	pass 
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta	
	
	
	match status:

		SkeletonState.walk:
			walk_state(delta)			
			
		SkeletonState.dead:	
			dead_state(delta)	
			
		SkeletonState.attack:	
			attack_state(delta)															
			
	move_and_slide()		
	
pass	

#---------------------------
#Movement - states
#---------------------------	


func go_to_walk_state():
	status = SkeletonState.walk
	animated_sprite_2d.play("walk")
	pass
	
func walk_state(delta: float):
	
	if animated_sprite_2d.frame == 3 or animated_sprite_2d.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if player_detector.is_colliding():
		go_to_attack_state()	
	pass
	

func go_to_dead_state():
	status = SkeletonState.dead
	animated_sprite_2d.play("dead")
	#update_collision_state()
	velocity = Vector2.ZERO
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	pass

func dead_state(delta: float):
	
	pass	
	
func go_to_attack_state():
	status = SkeletonState.attack
	animated_sprite_2d.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	pass

func attack_state(delta: float):
	
	if animated_sprite_2d.frame == 2 && can_throw:
		throw_bone()
		can_throw = false
	pass		
	
#---------------------------
#Damage
#---------------------------	


func take_damage():
	go_to_dead_state()
	pass	

func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(direction)
	pass	

#---------------------------
#Signals
#------------------------

func _on_animated_sprite_2d_animation_finished() -> void:
	
	match status:			
		SkeletonState.attack:	
			go_to_walk_state()
				
		_:
			return		
			
	#match animated_sprite_2d.animation:			
		#"attack":	
			#go_to_walk_state()
				#
		#_:
			#return					
	pass # Replace with function body.
