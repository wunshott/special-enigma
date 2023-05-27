extends Area2D
signal token_death
signal movement_done



var tile_size = 32
@export var animation_speed = 2 #how fast the token moves
var x_movement: int 
var y_movement: int
var unit_x: int
var unit_y:int
var x_goes_first: bool = false
var y_goes_first: bool = false
var movement_pool: int
var moving = false
var ray_array: Array


var inputs = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN
}

@onready var ray = $RayCast2D
@onready var movement_timer: Node = $Timer
@onready var token_animations: Node = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size / 2# centers the player
	
	# spawns rays in each direction

@export var composure: int = 5: # health
	get:
		return composure
		
	set(new_composure):
		composure = clamp(new_composure,0,5)
		if composure == 0:
			end_convo()

		

func take_damage(damage) -> void:
		composure -= damage



func end_convo():
	#animate all cards returning back to deck
	#return all cards back to your deck
	emit_signal("token_death")
	print("you died")
	#end scene
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	print(movement_timer.get_time_left())
	pass

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir) and movement_pool > 0:
			move(dir)
			movement_pool -= 1
		elif  event.is_action_pressed(dir) and movement_pool == 0:
			print("out of movement. play next card")
			
func move(dir):
	#position += inputs[dir] * tile_size
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", position + inputs[dir] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
			moving = true
			await tween.finished
			moving = false
	elif ray.is_colliding():
		print("collide")
#		token_animations.play("knockback")
		take_damage(1)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position - inputs[dir] * tile_size, .5/animation_speed).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position", position, .5/animation_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		#choose if you want to move the sprite or the whole token
		
#		await token_animations.animation_finished
		# take damage
		# get.collider() to differentiate between walls and traps
		# play knockback animation
		# prevent future movement

func move2(dir:Vector2):
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", position + (dir * tile_size), 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
			moving = true
			await tween.finished
			moving = false
	elif ray.is_colliding():
		print("collision")
		
		# take damage
		# get.collider() to differentiate between walls and traps
		# play knockback animation
		# prevent future movement?
		return

func move3(card_movement_input:Vector2) -> void:
	# input is x only or y only vector
	# moves and points in that direction only
	# moves and uses await function
	if card_movement_input.y == 0: # empty y vector
		ray.target_position = Vector2(card_movement_input.x/abs(card_movement_input.x),0) * tile_size # points ray in proper direction
		ray.force_raycast_update()
		for tile in card_movement_input.x:
			# for each number of movement, tween in that dierction 
			if !ray.is_colliding():
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", position + (Vector2(card_movement_input.x/abs(card_movement_input.x),0) * tile_size), 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
				await tween.finished
		
		emit_signal("movement_done")

		
		
	elif card_movement_input.x == 0: # empty x in vector
		ray.target_position = Vector2(0,card_movement_input.y/abs(card_movement_input.y)) * tile_size # points ray in proper direction
		ray.force_raycast_update()
		# for each number of movement, tween in that dierction 
		for tile in card_movement_input.y:
			if !ray.is_colliding():
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", position + (Vector2(0,card_movement_input.y/abs(card_movement_input.y)) * tile_size), 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
				await tween.finished
				
		emit_signal("movement_done")
	

# 2 types of movement
# basic - xyz order determined by card
# freedom_direciton - pool movement and let player disperse it
#fix all this movement with state machine?
func _on_cards_card_played_move_token(card_movement:Vector2, movement_order: Array, freedom_direction:bool) -> void:
	if freedom_direction == true: #movement pool
		movement_pool = (abs(card_movement.x) + abs(card_movement.y)) # creates movement pool
		print("move token with keys. You have " + str(movement_pool) + " points")

	else: #basic movement without timer. use await
# call move3 function while there are still movement points in that direction
		if movement_order.find(1) == 0: # x goes first
			move3(Vector2(card_movement.x,0))
			var movemenet_done_signal = movement_done
			await movemenet_done_signal
			move3(Vector2(0,card_movement.y))
		elif movement_order.find(1) == 1: # y goes first
			move3(Vector2(0,card_movement.y))
			var movemenet_done_signal = movement_done
			await movemenet_done_signal
			move3(Vector2(card_movement.x,0))
		else:
			print("movement error")
			
			
#	else: #basic movement can revamp with await. emit a signal once the position is reached, then go to next action?
#		var first_movement_dierction = movement_order.find(1) # returns index of which xyz is first
#		print("the first movement direction is " + str(first_movement_dierction))
#
#		if first_movement_dierction == 0: # if index of 1 is 0, x goes first
#			x_goes_first = true
#			x_movement = card_movement.x # initializs x movement
#			unit_x = x_movement/card_movement.x # useless? just create the number 1
#			#position += Vector2(unit_x,0) * tile_size # moves in x direction by tile size
#
#			move2(Vector2(unit_x,0))
#			x_movement -= 1 # subtracts 1 from total movement
#			y_movement = card_movement.y # initializs y movement
#			unit_y = y_movement/card_movement.y
#			movement_timer.start()
##			elif ray.is_colliding():
##				pass
#
#		elif first_movement_dierction == 1: # y must go first, fix for z direction
#			y_goes_first = true
#			y_movement = card_movement.y # initializs y movement
#			unit_y = y_movement/card_movement.y
#			#position += Vector2(0,unit_y) * tile_size # moves in y direction by tile size
#
#			move2(Vector2(0,unit_y))
#			y_movement -= 1 # subtracts 1 from total movement
#			x_movement = card_movement.x # initializs x movement
#			unit_x = x_movement/card_movement.x # useless? just create the number 1
#			movement_timer.start()
##			elif ray.is_colliding():
##				print("collision")
##				pass
			


#useless now
func _on_timer_timeout() -> void: #ALL of this breaks with negative numbers
	# move all of this to a function
	if x_goes_first == true:
		if x_movement > 0: # moves token in the x direction until all movement is used up
			#has a timer in between movement
			#position += Vector2(unit_x,0) * tile_size
			move2(Vector2(unit_x,0))
			x_movement -= 1
			movement_timer.start()
		elif x_movement == 0 and y_movement > 0:
			move2(Vector2(0,unit_y))
			y_movement -= 1
			movement_timer.start()
		elif y_movement == 0 and x_movement == 0:
			print("jobs done")
			x_goes_first = false
			y_goes_first = false
	elif y_goes_first == true:
		if y_movement > 0:
			move2(Vector2(0,unit_y))
			y_movement -= 1
			movement_timer.start()
		elif y_movement == 0 and x_movement > 0:
			move2(Vector2(unit_x,0))
			x_movement -= 1
			movement_timer.start()
		elif y_movement == 0 and x_movement == 0:
			print("jobs done")
			x_goes_first = false
			y_goes_first = false
	else:
		print("timer error")
		return
