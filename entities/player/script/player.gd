extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

enum PlayerState {
	idle,
	walk,
	jump,
	duck
}

var status: PlayerState



func _ready() -> void:
	go_to_idle_state()
	pass 
	
	
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta	
	
	
	match status:
		PlayerState.idle:
			idle_state()
			
		PlayerState.walk:
			walk_state()			
	
		PlayerState.jump:
			jump_state()	
			
		PlayerState.duck:	
			duck_state()				
			
	move_and_slide()			
	pass	
	
	
#---------------------------
#Movement 
#---------------------------		
	
func move():
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)		
	
	flip(direction)
	
#---------------------------
#Movement - states
#---------------------------	

func go_to_idle_state():
	status = PlayerState.idle
	animated_sprite_2d.play("idle")
	pass

func idle_state():
	move()
	
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_pressed("duck") and is_on_floor():
		go_to_duck_state()
		return		
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return	
	pass



func go_to_walk_state():
	status = PlayerState.walk
	animated_sprite_2d.play("walk")
	pass
	
func walk_state():
	move()
	
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return			
	pass
	
	
	
func go_to_jump_state():
	status = PlayerState.jump
	animated_sprite_2d.play("jump")
	velocity.y = JUMP_VELOCITY
	pass
		
func jump_state():
	move()
	
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()	
		return
	pass	

func go_to_duck_state():
	status = PlayerState.duck
	animated_sprite_2d.play("duck")
	pass

func duck_state():
	if Input.is_action_just_released("duck") and is_on_floor():
		go_to_idle_state()
		return
		
	pass	




func flip(direction: float) -> void:
	if direction > 0:
		animated_sprite_2d.flip_h = false
		#animated_sprite_2d.play("walk")
	elif direction < 0:
		animated_sprite_2d.flip_h = true	
		#animated_sprite_2d.play("walk")
	else: 
		print("")
		#animated_sprite_2d.play("idle")
		










func _physics_process_v1(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


	if is_on_floor():
		flip(direction)
	else: 	animated_sprite_2d.play("jump")

	move_and_slide()
			
