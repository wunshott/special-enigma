class_name Token
extends CharacterBody2D

@export var SPEED: float = 300.0
@export var drag_factor: float = 0.12
@onready var target = position
@onready var targetx: Vector2
@onready var targety: Vector2
@onready var state = Idle
@onready var freedom_order_button: Node = $InputOrderButton
@onready var x_button: Node = $InputOrderButton/X
@onready var y_button: Node = $InputOrderButton/Y
@onready var z_button: Node = $InputOrderButton/Z

@onready var collision: Node = $CollisionShape2D
@onready var area_detection: Node = $Area2D
var start_collision_layer := collision_layer
var start_collision_mask := collision_mask

var tile_size = 32
var allowed_to_move: bool = false # variable that gets tripped after player prompts so token can move
var x_input: bool = false
var y_input: bool = false
var z_input: bool = false
var x_pressed: bool = false
var y_pressed: bool = false
var x_goes_first: bool
var y_goes_first: bool

var movement_pool: float 
var old_state

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
enum{
	Idle, #0 Card is not moving
	Moving, #1 token is moving
	Prompt, #2 prompting player for movement
	InfinitePrompt, #3
	MoveY, #4
	MoveX #5
	
}
func _ready() -> void:
	print(position)
	position = position.snapped(Vector2.ONE * tile_size) # snaps token to nearest grid
	print(position)
	position += Vector2.ONE * tile_size/2 #places token in the center of the grid
	print(position)
	# places the token on a tile center

func _physics_process(delta: float) -> void:
	match state:
		Moving:
			if position.distance_to(target) > 10:
				velocity = position.direction_to(target) * SPEED
				move_and_slide()
				if old_state == InfinitePrompt and abs(position.y - target.y) <= 10 and abs(position.x - target.x) <= 10:
					_unpush_x()
					_unpush_y()
					movement_pool -= 1  # subtract from movement pool
					state = InfinitePrompt
				elif abs(position.y - target.y) <= 10 and abs(position.x - target.x) <= 10:
					state = Idle
				
	match state:
		Idle: # should reset everything
			freedom_order_button.hide()
			_unpush_x()
			_unpush_y()
			collision_layer = start_collision_layer
			collision_mask = start_collision_mask

	match state:
		Prompt:
			freedom_order_button.show()
			if x_input == true:
				if abs(position.x - target.x) > 10:
					velocity = position.direction_to(Vector2(target.x,position.y)) * SPEED
					move_and_slide()

			if y_input == true: # make sure you don't click the buttons fast
				if abs(position.y - target.y) > 10:
					velocity = position.direction_to(Vector2(position.x,target.y)) * SPEED
					move_and_slide()
					
					
					
			if x_pressed and y_pressed == true and abs(position.y - target.y) <= 10 and abs(position.x - target.x) <= 10:
				state = Idle
				
	match state:
		InfinitePrompt: 
			freedom_order_button.show() # show buttons
			if movement_pool > 0:
				if x_input == true: # if you click x button
					target = position + Vector2(100,0) # set target to position + 1 x unit
					old_state = InfinitePrompt # set old state so you can go back to this state after moving
					state = Moving # moves to new position
				if y_input == true:
					target = position + Vector2(0,-100) # set target to position + 1 x unit
					old_state = InfinitePrompt # set old state so you can go back to this state after moving
					state = Moving # moves to new position
			if movement_pool == 0:
				freedom_order_button.hide()
				state = Idle
						
			

	match state:
		MoveY:
			if abs(position.y - targety.y) > 10:
				velocity = position.direction_to(targety) * SPEED
				move_and_slide()
			if abs(position.y - targety.y) <= 10 and y_goes_first == true:
				state = MoveX
			
			# need to set state back to idle somehow
	match state:
		MoveX:
			if abs(position.x - targetx.x) > 10:
				velocity = position.direction_to(targetx) * SPEED
				move_and_slide()
				
			if abs(position.x - targetx.x) <= 10 and x_goes_first == true:
				state = MoveY
			# need to set state back to idle somehow
			
				
				
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_velocity := SPEED * direction
	var steering := desired_velocity - velocity
	velocity += steering * drag_factor
	move_and_slide()




func _on_cards_move_token(Input_var:Vector2,freedom_of_movement:bool) -> void:
#	if freedom_of_movement == true:
		
	state = Prompt
	target = position + Input_var

		
#	else:
#		state = MoveX
#		targetx = position + Vector2(Input_var.x,0)
#		targety = targetx + Vector2(0,Input_var.y)


			#figure out way 

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if body is the wall,trap
	#do the thing
	print("token collided with wall")




func _on_cards_prompt() -> void:
	allowed_to_move = true
	state = Prompt

func _on_cards_free_movement(Input_var:Vector2) -> void:
	movement_pool = (abs(Input_var.x) + abs(Input_var.y))/100 # add up all movement points, y is negative and remove the factor of 100
	state = InfinitePrompt# set prompt state
	# go to move state, save old state, if old state was infinite prompt, go back to infinite prompt
	# click input and subtract from pool
	# set to move state
	#  set back to idle
	pass # Replace with function body.

func _on_cards_basic_movement(Input_var:Vector2,Order:Array) -> void: # breaks when you add z direction
	var first_movement = Order.find(1) # returns index
	if first_movement ==  0: # if index of 1 is 0, do x first then y
		x_goes_first = true
		
		targetx = position + Vector2(Input_var.x,0)
		targety = targetx + Vector2(0,Input_var.y)
		state = MoveX
	else: # otherwise do y first then x
		y_goes_first = true
		
		targety = position + Vector2(0,Input_var.y)
		targetx = targety + Vector2(Input_var.x,0)
		state = MoveY
	# pick input var based on movement order
	# look in array for 1
	# get index for 1
	
	
	
func _on_cards_ghost() -> void: # turns off collision for node
	#turns off token collision if state is a moving
	match state: 
		Moving,MoveY,MoveX: #if state is moving, turn on ghosting
			collision_layer = 0
			collision_mask = 0





func _on_x_pressed() -> void:
	x_input = true
	x_pressed = true
	x_button.disabled = true
	match state:
		InfinitePrompt:
			x_button.disabled = false #lets you keep clicking the button
	
func _unpush_x() -> void:
	x_input = false
	x_pressed = false
	x_button.disabled = false

func _on_y_pressed() -> void:
	y_input = true
	y_pressed = true
	y_button.disabled = true
	match state:
		InfinitePrompt:
			y_button.disabled = false #lets you keep clicking the button
	
func _unpush_y() -> void:
	y_input = false
	y_pressed = false
	y_button.disabled = false
	
func _on_z_pressed() -> void:
	pass # Replace with function body.







