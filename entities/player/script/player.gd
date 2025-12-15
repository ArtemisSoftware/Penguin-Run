extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D

@export var max_jump_count = 2
@export var acceleration = 400
@export var deceleration = 400
@export var max_speed = 100.0
@export var slide_deceleration = 100
@onready var reload_timer: Timer = $ReloadTimer

const JUMP_VELOCITY = -300.0

enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	fall,
	slide,
	dead
}

var direction = 0
var status: PlayerState
var jump_count = 0




func _ready() -> void:
	go_to_idle_state()
	pass 
	
	
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta	
	
	
	match status:
		PlayerState.idle:
			idle_state(delta)
			
		PlayerState.walk:
			walk_state(delta)			
	
		PlayerState.jump:
			jump_state(delta)	
			
		PlayerState.duck:	
			duck_state()			
			
		PlayerState.fall:	
			fall_state(delta)	
			
		PlayerState.slide:	
			slide_state(delta)	
			
		PlayerState.dead:	
			dead_state(delta)												
			
	move_and_slide()			
	pass	
	
	
#---------------------------
#Movement 
#---------------------------		
	
func move(delta: float):
	
	flip()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)	
		#velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)		
	
	pass
	

func flip() -> void:
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("left", "right")	
	
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true	

func can_jump_again() -> bool:
	return jump_count < max_jump_count	
	
#---------------------------
#Movement - states
#---------------------------	

func go_to_idle_state():
	status = PlayerState.idle
	animated_sprite_2d.play("idle")
	pass

func idle_state(delta: float):
	move(delta)
	
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
	
func walk_state(delta: float):
	move(delta)
	
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
		return	
		
	if Input.is_action_just_pressed("duck") and is_on_floor():	
		go_to_slide_state()
		return
		
	if not is_on_floor():
		jump_count += 1 # one extra jump when falling
		go_to_fall_state()	
		return		
		
			
	pass
	
	
	
func go_to_jump_state():
	status = PlayerState.jump
	animated_sprite_2d.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	pass
		
func jump_state(delta: float):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump_again():
		go_to_jump_state()
		return
		
	if velocity.y > 0:
		go_to_fall_state()
		return	
	
	pass	
	
func go_to_fall_state():
	status = PlayerState.fall
	animated_sprite_2d.play("fall")
	pass

func fall_state(delta: float):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump_again():
		go_to_jump_state()
		return	
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()	
		return
		

			
		
	pass		

func go_to_duck_state():
	status = PlayerState.duck
	animated_sprite_2d.play("duck")
	update_collision_state()
	pass

func duck_state():
	flip()
	
	if Input.is_action_just_released("duck") and is_on_floor():
		go_to_idle_state()
		update_collision_state()
		return
		
	pass	

func go_to_slide_state():
	status = PlayerState.slide
	animated_sprite_2d.play("slide")
	update_collision_state()
	pass

func slide_state(delta: float):
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)	
	
	if Input.is_action_just_released("duck") and is_on_floor():	
		go_to_walk_state()
		return
		
	if velocity.x == 0:
		go_to_duck_state()
		return
		
	pass	


func go_to_dead_state():
	if status == PlayerState.dead:
		return 
		
	status = PlayerState.dead
	animated_sprite_2d.play("dead")
	update_collision_state()
	velocity.x = 0
	reload_timer.start()
	pass

func dead_state(_delta: float):
	
	pass	



#---------------------------
#Collisions
#---------------------------	
	
func update_collision_state() -> void:
	
	match status:			
		PlayerState.duck, PlayerState.slide:	
			update_collision(5, 10, 3)
			update_hitbox_collision(10, 3)
		_:
			update_collision(6, 16, 0)	
			update_hitbox_collision(15, 0.5)			
	pass	
	
	
func update_collision(radius, height, y) -> void:
	collision_shape_2d.shape.radius = radius
	collision_shape_2d.shape.height = height
	collision_shape_2d.position.y = y
	pass	
	
func update_hitbox_collision(size, y) -> void:
	hitbox_collision_shape_2d.shape.size.y = size
	hitbox_collision_shape_2d.position.y = y
	pass		

#---------------------------
#Signals
#---------------------------	

func _on_hitbox_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):	
		hit_lethal_area()
	
	pass # Replace with function body.



func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):	
		hit_lethal_area()
	pass # Replace with function body.


#------------------------------
#Hit
#---------------------------	

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		#kill enemy
		#area.get_parent().queue_free()
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		go_to_dead_state()		
	pass
	
func hit_lethal_area():
	go_to_dead_state()
	pass	


#func _physics_process_v1(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("left", "right")
	#if direction:
		#velocity.x = direction * max_speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, max_speed)
#
#
	#if is_on_floor():
		#flip()
	#else: 	animated_sprite_2d.play("jump")
#
	#move_and_slide()
			#
