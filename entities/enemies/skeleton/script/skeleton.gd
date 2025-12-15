extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector


const SPEED = 30.0
const JUMP_VELOCITY = -400.0


enum SkeletonState {
	walk,
	dead
}


var status: SkeletonState
var direction = 1


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
	
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
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
	
#---------------------------
#Damage
#---------------------------	


func take_damage():
	go_to_dead_state()
	pass	
