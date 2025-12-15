extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var speed = 60
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * direction * delta 
	pass
	
func set_direction(skeleton_direction):
	self.direction = skeleton_direction
	animated_sprite_2d.flip_h = skeleton_direction < 0 
	pass	

#---------------------------
#Signals
#------------------------

func _on_self_destruct_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_area_entered(_area: Area2D) -> void:
	queue_free()
	pass # Replace with function body.


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
	pass # Replace with function body.
