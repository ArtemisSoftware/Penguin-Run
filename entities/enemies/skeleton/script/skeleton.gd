extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


enum SkeletonState {
	walk,
	dead
}


var status: SkeletonState


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
	#move(delta)
	#
	#if velocity.x == 0:
		#go_to_idle_state()
		#return
		#
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#go_to_jump_state()
		#return	
		#
	#if Input.is_action_just_pressed("duck") and is_on_floor():	
		#go_to_slide_state()
		#return
		#
	#if not is_on_floor():
		#jump_count += 1 # one extra jump when falling
		#go_to_fall_state()	
		#return		
		#
			#
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
